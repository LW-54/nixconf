{
  internal.cgroups.mkVolumes = {
    self,
    config,
    cfg,
    lib,
    pkgs,
    options,
    utils,
    toBytes,
    filterNulls,
  }: let
    enabledVolumes = lib.filterAttrs (_: v: v.enable) cfg.volumes;
    tmpfsVolumes = lib.filterAttrs (_: v: v.mode == "tmpfs") enabledVolumes;
    mountedImgVolumes = lib.filterAttrs (_: v: v.mode != "tmpfs" && v.mountPoint != null) enabledVolumes;
    unmountedReserveVolumes = lib.filterAttrs (_: v: v.mode == "reserved" && v.mountPoint == null) enabledVolumes;

    enabledBudgets = lib.filterAttrs (_: b: b.enable) cfg.storageBudgets;
    budgetsActive = enabledBudgets != {} && (config.storage.enable or false);

    hasHostSnapshot = options ? services && options.services ? hostSnapshot;
    monEnabled = config.monitoring.enable or false;

    textfileDir = let
      d = config.monitoring.exporters.unix.textfileDirectory or null;
    in
      if d != null
      then d
      else "/var/lib/alloy/textfile";

    # Simple duration-to-seconds parser so shortest interval governs shared timer cadence.
    intervalToSec = s: let
      m = builtins.match "^([0-9]+)(s|m|h|d)?$" s;
    in
      if m == null
      then 21600
      else let
        n = lib.toIntBase10 (builtins.elemAt m 0);
        u = builtins.elemAt m 1;
        mul =
          if u == "s" || u == null
          then 1
          else if u == "m"
          then 60
          else if u == "h"
          then 3600
          else 86400;
      in
        n * mul;

    shortestBudgetInterval = let
      vals = builtins.attrValues enabledBudgets;
      sorted = lib.sort (a: b: (intervalToSec a.interval) < (intervalToSec b.interval)) vals;
    in
      if sorted == []
      then "6h"
      else (builtins.head sorted).interval;

    mkImgPrepService = vName: v: let
      escapedMount = utils.escapeSystemdPath v.mountPoint;
      mountUnit = "${escapedMount}.mount";
      imgPath = "${v.backingDir}/${vName}.img";
      volLabel = builtins.substring 0 16 "vol-${vName}";
      targetBytes = toString (toBytes v.size);
      seedSrc = "/persist/system${v.mountPoint}";
      prepScript = pkgs.writeShellApplication {
        name = "nixconf-volume-${vName}-prep";
        runtimeInputs = [pkgs.coreutils pkgs.e2fsprogs pkgs.util-linux];
        meta.description = "Create or grow loopback volume '${vName}' at ${imgPath}.";
        text = ''
          backing_dir=${lib.escapeShellArg v.backingDir}
          img=${lib.escapeShellArg imgPath}
          target_bytes=${lib.escapeShellArg targetBytes}
          seed_src=${lib.escapeShellArg seedSrc}
          mode=${lib.escapeShellArg v.mode}

          install -d -m 0700 "$backing_dir"
          chattr +C "$backing_dir" 2>/dev/null || true

          if [ ! -e "$img" ]; then
            tmp_img="$img.tmp.$$"
            tmp_mnt=""
            cleanup() {
              if [ -n "$tmp_mnt" ] && mountpoint -q "$tmp_mnt" 2>/dev/null; then
                umount "$tmp_mnt" || true
              fi
              if [ -n "$tmp_mnt" ] && [ -d "$tmp_mnt" ]; then
                rmdir "$tmp_mnt" || true
              fi
              rm -f "$tmp_img"
            }
            trap cleanup EXIT

            if [ "$mode" = "reserved" ]; then
              fallocate -l "$target_bytes" "$tmp_img" || truncate -s "$target_bytes" "$tmp_img"
              mkfs.ext4 -q -F -m 0 -E nodiscard -L ${lib.escapeShellArg volLabel} "$tmp_img"
            else
              truncate -s "$target_bytes" "$tmp_img"
              mkfs.ext4 -q -F -m 0 -L ${lib.escapeShellArg volLabel} "$tmp_img"
            fi

            if [ -d "$seed_src" ] && [ -n "$(ls -A "$seed_src" 2>/dev/null)" ]; then
              tmp_mnt="$(mktemp -d)"
              mount -o loop "$tmp_img" "$tmp_mnt"
              cp -a "$seed_src"/. "$tmp_mnt"/
              umount "$tmp_mnt"
              rmdir "$tmp_mnt"
              tmp_mnt=""
            fi

            mv -f "$tmp_img" "$img"
            trap - EXIT
          else
            current_bytes="$(stat -c '%s' "$img")"
            if [ "$target_bytes" -gt "$current_bytes" ]; then
              if [ "$mode" = "reserved" ]; then
                fallocate -l "$target_bytes" "$img" || truncate -s "$target_bytes" "$img"
              else
                truncate -s "$target_bytes" "$img"
              fi
              loop_dev="$(losetup -j "$img" -O NAME --noheadings | head -n 1 || true)"
              if [ -n "$loop_dev" ]; then
                losetup -c "$loop_dev"
                resize2fs "$loop_dev"
              else
                e2fsck -p -f "$img" || true
                resize2fs "$img"
              fi
            elif [ "$target_bytes" -lt "$current_bytes" ]; then
              echo "Warning: volume '${vName}' target ($target_bytes B) < current ($current_bytes B); online shrinking skipped." >&2
            fi
          fi
        '';
      };
    in {
      name = "resources-volume-${vName}";
      value = {
        description = "Prepare and size dedicated local volume '${vName}' (${v.mode}, ${toString v.size})";
        after = ["local-fs.target"];
        before = [mountUnit];
        requiredBy = [mountUnit];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe prepScript;
        };
      };
    };

    mkReserveService = vName: v: let
      reservePath = "${v.backingDir}/${vName}.reserve";
      targetBytes = toString (toBytes v.size);
      reserveScript = pkgs.writeShellApplication {
        name = "nixconf-volume-${vName}-reserve";
        runtimeInputs = [pkgs.coreutils pkgs.e2fsprogs pkgs.util-linux];
        meta.description = "Ensure preallocated space reservation block '${vName}' at ${reservePath}.";
        text = ''
          backing_dir=${lib.escapeShellArg v.backingDir}
          reserve_file=${lib.escapeShellArg reservePath}
          target_bytes=${lib.escapeShellArg targetBytes}

          install -d -m 0700 "$backing_dir"
          chattr +C "$backing_dir" 2>/dev/null || true

          current_bytes=0
          if [ -e "$reserve_file" ]; then
            current_bytes="$(stat -c '%s' "$reserve_file")"
          fi

          if [ ! -e "$reserve_file" ] || [ "$current_bytes" -ne "$target_bytes" ]; then
            fallocate -l "$target_bytes" "$reserve_file" || truncate -s "$target_bytes" "$reserve_file"
            chmod 0600 "$reserve_file"
          fi
        '';
      };
    in {
      name = "resources-volume-${vName}";
      value = {
        description = "Maintain unmounted local disk space reservation '${vName}' (${toString v.size})";
        wantedBy = ["multi-user.target"];
        after = ["local-fs.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe reserveScript;
        };
      };
    };

    mkPermsService = vName: v: let
      mountUnit = "${utils.escapeSystemdPath v.mountPoint}.mount";
    in {
      name = "resources-volume-${vName}-perms";
      value = {
        description = "Apply ownership and permissions for dedicated volume '${vName}'";
        wantedBy = ["multi-user.target"];
        after = [mountUnit];
        requires = [mountUnit];
        before = v.beforeUnits;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.coreutils}/bin/chown ${lib.escapeShellArg "${v.owner}:${v.group}"} ${lib.escapeShellArg v.mountPoint}
          ${pkgs.coreutils}/bin/chmod ${lib.escapeShellArg v.dirMode} ${lib.escapeShellArg v.mountPoint}
          ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix=${lib.escapeShellArg v.mountPoint} || true
        '';
      };
    };

    mountedVolumes = mountedImgVolumes // tmpfsVolumes;

    beforeUnitDeps = lib.mkMerge (
      lib.mapAttrsToList (vName: v:
        builtins.listToAttrs (
          map (u: {
            name = lib.removeSuffix ".service" u;
            value = {
              after = ["resources-volume-${vName}-perms.service"];
              requires = ["resources-volume-${vName}-perms.service"];
              unitConfig.RequiresMountsFor = [v.mountPoint];
            };
          }) (lib.filter (u: lib.hasSuffix ".service" u) v.beforeUnits)
        ))
      mountedVolumes
    );

    snapshotExcludes = lib.concatLists (
      lib.mapAttrsToList (vName: v: let
        excludeSnap =
          if v.excludeFromSnapshot != null
          then v.excludeFromSnapshot
          else (v.mountPoint == null);
        backingFile =
          if v.mountPoint == null
          then "${v.backingDir}/${vName}.reserve"
          else "${v.backingDir}/${vName}.img";
      in
        lib.optional (excludeSnap && lib.hasPrefix "/persist/" v.backingDir)
        "/persist/.snapshots/staging/${lib.removePrefix "/persist/" backingFile}")
      (mountedImgVolumes // unmountedReserveVolumes)
    );

    backupExcludes = lib.concatLists (
      lib.mapAttrsToList (_: v:
        lib.optional (v.excludeFromBackup && v.mountPoint != null) v.mountPoint)
      enabledVolumes
    );

    volumesPromContent =
      "# HELP nixconf_disk_volume_size_bytes Configured target size of declarative local volumes.\n"
      + "# TYPE nixconf_disk_volume_size_bytes gauge\n"
      + lib.concatStrings (
        lib.mapAttrsToList (vName: v: let
          mp =
            if v.mountPoint != null
            then v.mountPoint
            else "reserved-unmounted";
        in ''
          nixconf_disk_volume_size_bytes{volume=${builtins.toJSON vName},mode=${builtins.toJSON v.mode},mountpoint=${builtins.toJSON mp}} ${toString (toBytes v.size)}
        '')
        enabledVolumes
      );

    volumesPromFile = pkgs.writeText "volumes.prom" volumesPromContent;

    resolvedBudgetTargets =
      lib.mapAttrsToList (sName: b: let
        hasSlice = (config.storage.slices or {}) ? ${sName};
        resolved =
          if hasSlice
          then
            self.lib.storage.resolveSlice {
              storageCfg = config.storage;
              sliceName = sName;
              hostName = config.networking.hostName;
            }
          else null;
        rcloneTarget =
          if resolved != null
          then resolved.endpoints.rclone
          else "${sName}:";
        provider =
          if resolved != null
          then
            resolved.providerName or (
              if (resolved.kind or "") == "union"
              then "union"
              else "unknown"
            )
          else "unknown";
        scope =
          if resolved != null
          then resolved.scope or "shared"
          else "shared";
      in {
        slice = sName;
        inherit provider scope;
        endpoint = rcloneTarget;
        limitBytes = toBytes b.maxSize;
        warnPct = b.warnPercent;
        intervalSec = intervalToSec b.interval;
      })
      enabledBudgets;

    budgetMeasureScript = pkgs.writeShellApplication {
      name = "nixconf-storage-budgets";
      runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.rclone];
      meta.description = "Measure remote storage slice usage via rclone and export Prometheus budget metrics.";
      text = ''
        export RCLONE_CONFIG="''${RCLONE_CONFIG:-/run/rclone/rclone.conf}"
        textfile_dir=${lib.escapeShellArg textfileDir}
        cache_dir="''${RUNTIME_DIRECTORY:-/run/nixconf-storage-budgets}"
        mkdir -p "$textfile_dir" "$cache_dir"
        tmp_file="$(mktemp "$textfile_dir/.storage_budgets.XXXXXX")"
        work_dir="$(mktemp -d)"
        trap 'rm -rf "$tmp_file" "$work_dir"' EXIT
        now="$(date +%s)"

        used_buf="$work_dir/used"
        objs_buf="$work_dir/objs"
        limit_buf="$work_dir/limit"
        warn_buf="$work_dir/warn"
        ts_buf="$work_dir/ts"
        : > "$used_buf"
        : > "$objs_buf"
        : > "$limit_buf"
        : > "$warn_buf"
        : > "$ts_buf"

        emit_slice_usage() {
          local labels="$1"
          local used="$2"
          local objs="$3"
          local ts="$4"
          printf 'nixconf_storage_budget_used_bytes{%s} %s\n' "$labels" "$used" >> "$used_buf"
          printf 'nixconf_storage_budget_objects{%s} %s\n' "$labels" "$objs" >> "$objs_buf"
          printf 'nixconf_storage_budget_last_measured_timestamp_seconds{%s} %s\n' "$labels" "$ts" >> "$ts_buf"
        }

        had_error=0
        ${lib.concatMapStrings (t: let
            labelsStr = ''slice=${builtins.toJSON t.slice},provider=${builtins.toJSON t.provider},scope=${builtins.toJSON t.scope}'';
            labelsArg = lib.escapeShellArg labelsStr;
            minAge =
              if t.intervalSec > 600
              then t.intervalSec - 300
              else 0;
          in ''
            printf 'nixconf_storage_budget_limit_bytes{%s} %s\n' ${labelsArg} ${lib.escapeShellArg (toString t.limitBytes)} >> "$limit_buf"
            printf 'nixconf_storage_budget_warn_percent{%s} %s\n' ${labelsArg} ${lib.escapeShellArg (toString t.warnPct)} >> "$warn_buf"
            cache_file="$cache_dir/"${lib.escapeShellArg "${t.slice}.json"}
            use_cache=0
            last_ts=0
            if [ -s "$cache_file" ]; then
              last_ts="$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null || echo 0)"
              if [ "$((now - last_ts))" -lt ${toString minAge} ]; then
                use_cache=1
              fi
            fi
            if [ "$use_cache" -eq 1 ]; then
              used_bytes="$(jq -r '.bytes // 0' "$cache_file")"
              obj_count="$(jq -r '.count // 0' "$cache_file")"
              emit_slice_usage ${labelsArg} "$used_bytes" "$obj_count" "$last_ts"
            elif json_out="$(rclone --config "$RCLONE_CONFIG" --contimeout=10s --timeout=120s size --json ${lib.escapeShellArg t.endpoint})"; then
              used_bytes="$(printf '%s' "$json_out" | jq -r '.bytes // 0')"
              obj_count="$(printf '%s' "$json_out" | jq -r '.count // 0')"
              jq -n --argjson ts "$now" --argjson bytes "$used_bytes" --argjson count "$obj_count" \
                '{timestamp: $ts, bytes: $bytes, count: $count}' > "$cache_file.tmp"
              mv -f "$cache_file.tmp" "$cache_file"
              emit_slice_usage ${labelsArg} "$used_bytes" "$obj_count" "$now"
            else
              echo "Failed measuring remote storage slice '${t.slice}' (${t.endpoint})" >&2
              if [ -s "$cache_file" ]; then
                used_bytes="$(jq -r '.bytes // 0' "$cache_file")"
                obj_count="$(jq -r '.count // 0' "$cache_file")"
                emit_slice_usage ${labelsArg} "$used_bytes" "$obj_count" "$last_ts"
              fi
              had_error=1
            fi
          '')
          resolvedBudgetTargets}

        {
          if [ -s "$used_buf" ]; then
            printf '# HELP nixconf_storage_budget_used_bytes Measured size in bytes of remote storage slice.\n'
            printf '# TYPE nixconf_storage_budget_used_bytes gauge\n'
            cat "$used_buf"
          fi
          if [ -s "$objs_buf" ]; then
            printf '# HELP nixconf_storage_budget_objects Measured object count of remote storage slice.\n'
            printf '# TYPE nixconf_storage_budget_objects gauge\n'
            cat "$objs_buf"
          fi
          if [ -s "$limit_buf" ]; then
            printf '# HELP nixconf_storage_budget_limit_bytes Configured budget limit in bytes for remote storage slice.\n'
            printf '# TYPE nixconf_storage_budget_limit_bytes gauge\n'
            cat "$limit_buf"
          fi
          if [ -s "$warn_buf" ]; then
            printf '# HELP nixconf_storage_budget_warn_percent Configured warning percentage threshold for remote storage slice.\n'
            printf '# TYPE nixconf_storage_budget_warn_percent gauge\n'
            cat "$warn_buf"
          fi
          if [ -s "$ts_buf" ]; then
            printf '# HELP nixconf_storage_budget_last_measured_timestamp_seconds Unix timestamp of last successful remote storage slice measurement.\n'
            printf '# TYPE nixconf_storage_budget_last_measured_timestamp_seconds gauge\n'
            cat "$ts_buf"
          fi
        } > "$tmp_file"

        chmod 0644 "$tmp_file"
        mv -f "$tmp_file" "$textfile_dir/storage_budgets.prom"
        rm -rf "$work_dir"
        trap - EXIT
        exit "$had_error"
      '';
    };

    journalSettings = filterNulls {
      SystemMaxUse = cfg.disk.journalMaxSize;
      SystemKeepFree = cfg.disk.journalKeepFree;
    };
  in
    lib.mkMerge [
      {
        services.journald.settings.Journal = lib.mkIf (journalSettings != {}) journalSettings;

        nix.settings =
          (lib.optionalAttrs (cfg.disk.nixMinFree != null) {
            min-free = lib.mkDefault (toBytes cfg.disk.nixMinFree);
          })
          // (lib.optionalAttrs (cfg.disk.nixMaxFree != null) {
            max-free = lib.mkDefault (toBytes cfg.disk.nixMaxFree);
          });

        boot.kernelModules = lib.mkIf (mountedImgVolumes != {}) ["loop"];

        systemd = {
          mounts =
            (lib.mapAttrsToList (vName: v: {
                what = "${v.backingDir}/${vName}.img";
                where = v.mountPoint;
                type = "ext4";
                options =
                  if v.mode == "thin"
                  then "loop,noatime,discard"
                  else "loop,noatime";
                unitConfig.DefaultDependencies = false;
                conflicts = ["umount.target"];
                before = ["umount.target"];
                after = ["local-fs.target" "resources-volume-${vName}.service"];
                requires = ["resources-volume-${vName}.service"];
                wantedBy = ["multi-user.target"];
              })
              mountedImgVolumes)
            ++ (lib.mapAttrsToList (_: v: {
                what = "tmpfs";
                where = v.mountPoint;
                type = "tmpfs";
                options = "size=${toString v.size},mode=${v.dirMode}";
                wantedBy = ["local-fs.target"];
              })
              tmpfsVolumes);

          services = lib.mkMerge [
            (lib.mapAttrs' mkImgPrepService mountedImgVolumes)
            (lib.mapAttrs' mkReserveService unmountedReserveVolumes)
            (lib.mapAttrs' mkPermsService mountedVolumes)
            beforeUnitDeps
          ];

          tmpfiles.rules = lib.mkIf (monEnabled && enabledVolumes != {}) [
            "L+ ${textfileDir}/volumes.prom - - - - ${volumesPromFile}"
          ];
        };

        backup.exclude = lib.mkIf ((config.backup.enable or false) && backupExcludes != []) backupExcludes;
      }
      (lib.optionalAttrs hasHostSnapshot {
        services.hostSnapshot.exclude = lib.mkIf ((config.services.hostSnapshot.enable or false) && snapshotExcludes != []) snapshotExcludes;
      })
      (lib.mkIf budgetsActive {
        storage.activeSlices = builtins.attrNames enabledBudgets;

        systemd.services.resources-storage-budgets = {
          description = "Measure remote storage slice usage against declarative capacity budgets";
          after = ["rclone-config.service" "network-online.target"];
          wants = ["network-online.target"];
          requires = ["rclone-config.service"];
          serviceConfig = {
            Type = "oneshot";
            RuntimeDirectory = "nixconf-storage-budgets";
            RuntimeDirectoryPreserve = "yes";
            ExecStart = lib.getExe budgetMeasureScript;
          };
        };

        systemd.timers.resources-storage-budgets = {
          description = "Periodic remote storage budget measurement timer";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "5m";
            OnUnitActiveSec = shortestBudgetInterval;
            Persistent = true;
          };
        };

        resources.units."resources-storage-budgets.service" = {
          tier = "background";
          deferOnBattery = true;
        };

        testing.vm.allowedFailedUnits = ["resources-storage-budgets.service"];
      })
    ];
}
