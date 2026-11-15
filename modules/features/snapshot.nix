{self, ...}: let
  builtinTargets = {
    hbox = {
      enable = true;
      slice = "hbox-backup-host";
      repoSubpath = "snapshots/persist";
      onCalendar = "weekly";
      randomizedDelaySec = "30m";
      persistent = true;
      keep = ["--keep-last" "1"];
    };
    gdrive = {
      enable = true;
      slice = "gdrive-backup-host";
      repoSubpath = "snapshots/persist";
      onCalendar = "weekly";
      randomizedDelaySec = "1h";
      persistent = true;
      keep = ["--keep-last" "5" "--keep-weekly" "4" "--keep-monthly" "3"];
    };
  };

  mergeBuiltinTargets = user:
    (builtins.mapAttrs (n: d: d // (user.${n} or {})) (
      builtins.intersectAttrs user builtinTargets
    ))
    // (builtins.removeAttrs builtinTargets (builtins.attrNames user))
    // (builtins.removeAttrs user (builtins.attrNames builtinTargets));
in {
  feature.snapshot = {
    description = "Atomic local Btrfs read-only snapshots paired with deduplicated restic off-site host snapshots and manual CLI triggers.";
    modules.snapshot = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.services.hostSnapshot;
      hostName = config.networking.hostName;

      targetSubmodule = lib.types.submodule ({name, ...}: let
        td = builtinTargets.${name} or {};
      in {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = td.enable or true;
            description = "Whether periodic and `all` snapshots run for this target.";
          };
          slice = lib.mkOption (
            {
              type = lib.types.str;
              description = "Storage slice name (`storage.slices.<name>`) backing this snapshot target.";
            }
            // lib.optionalAttrs (td ? slice) {default = td.slice;}
          );
          repoSubpath = lib.mkOption {
            type = lib.types.str;
            default = td.repoSubpath or "snapshots/persist";
            description = "Repository subpath beneath the slice root endpoint.";
          };
          onCalendar = lib.mkOption {
            type = lib.types.str;
            default = td.onCalendar or "weekly";
            description = "Systemd OnCalendar schedule expression for automated remote snapshots.";
          };
          randomizedDelaySec = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = td.randomizedDelaySec or "30m";
            description = "Random jitter added before automated snapshot runs (null to disable).";
          };
          persistent = lib.mkOption {
            type = lib.types.bool;
            default = td.persistent or true;
            description = "Whether missed snapshot timers execute immediately on next boot.";
          };
          keep = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = td.keep or ["--keep-last" "1"];
            description = "Retention arguments passed to `restic forget --prune`.";
          };
        };
      });

      enabledTargets = lib.filterAttrs (_: t: t.enable) cfg.targets;

      targetRepository = tCfg: let
        baseRclone =
          if (config.storage.slices or {}) ? ${tCfg.slice}
          then
            (self.lib.storage.resolveSlice {
              storageCfg = config.storage;
              sliceName = tCfg.slice;
              inherit hostName;
            })
            .endpoints
            .rclone
          else "${tCfg.slice}:";
      in
        if lib.hasSuffix ":" baseRclone
        then "rclone:${baseRclone}${tCfg.repoSubpath}"
        else "rclone:${baseRclone}/${tCfg.repoSubpath}";

      targetRepos = builtins.mapAttrs (_: targetRepository) enabledTargets;

      snapshotScript = pkgs.writeShellApplication {
        name = "nixconf-host-snapshot";
        runtimeInputs = [
          pkgs.btrfs-progs
          pkgs.coreutils
          pkgs.findutils
          pkgs.openssh
          pkgs.rclone
          pkgs.restic
          pkgs.util-linux
        ];
        meta = {
          description = "Take an atomic Btrfs read-only snapshot of /persist and push/prune it across restic targets.";
          mainProgram = "nixconf-host-snapshot";
        };
        text = ''
          export RCLONE_CONFIG="''${RCLONE_CONFIG:-/etc/rclone/rclone.conf}"
          export RESTIC_PASSWORD_FILE="''${RESTIC_PASSWORD_FILE:-${lib.escapeShellArg config.secrets.files.restic-password.path}}"

          cmd="''${1:-all}"
          subvol=${lib.escapeShellArg cfg.subvolume}
          snap_dir=${lib.escapeShellArg cfg.snapshotDir}
          staging="$snap_dir/staging"
          local_keep=${toString cfg.localKeep}
          exclude_args=(${lib.escapeShellArgs (lib.concatMap (p: ["--exclude" p]) cfg.exclude)})

          if [ "$cmd" = "list" ]; then
            echo "=== Local Btrfs snapshots ($snap_dir) ==="
            if [ -d "$snap_dir" ]; then
              find "$snap_dir" -maxdepth 1 -mindepth 1 -name 'local-*' | sort -r
            fi
            ${lib.concatStrings (lib.mapAttrsToList (tName: repo: ''
              echo "=== Target '${tName}' (${repo}) ==="
              restic -r ${lib.escapeShellArg repo} -o "rclone.program=${pkgs.rclone}/bin/rclone" --no-lock snapshots --tag host-snapshot || true
            '')
            targetRepos)}
            exit 0
          fi

          mkdir -p /run/lock
          exec 9>/run/lock/nixconf-host-snapshot.lock
          flock -x 9

          install -d -m 0700 "$snap_dir"

          cleanup_staging() {
            if btrfs subvolume show "$staging" >/dev/null 2>&1; then
              btrfs subvolume delete "$staging" >/dev/null || true
            fi
          }
          trap cleanup_staging EXIT

          create_local_snapshot() {
            local ts local_snap idx old_snap
            ts="$(date -u +%Y%m%dT%H%M%SZ)"
            local_snap="$snap_dir/local-$ts"
            if [ -e "$local_snap" ]; then
              local_snap="$snap_dir/local-$ts-$$"
            fi
            btrfs subvolume snapshot -r "$subvol" "$local_snap"
            echo "Created local read-only snapshot: $local_snap"

            mapfile -t local_snaps < <(find "$snap_dir" -maxdepth 1 -mindepth 1 -name 'local-*' | sort -r)
            idx=0
            for old_snap in "''${local_snaps[@]}"; do
              if [ "$idx" -ge "$local_keep" ]; then
                echo "Pruning old local snapshot: $old_snap"
                btrfs subvolume delete "$old_snap"
              fi
              idx=$((idx + 1))
            done
          }

          prepare_staging() {
            cleanup_staging
            btrfs subvolume snapshot -r "$subvol" "$staging"
          }

          run_target() {
            local tname="$1"
            local repo="$2"
            shift 2
            local -a keep_args=("$@")
            local rc

            set +e
            restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" cat config --no-lock >/dev/null 2>&1
            rc=$?
            set -e
            if [ "$rc" -eq 10 ]; then
              echo "Initializing restic repository '$repo'..."
              restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" init
            elif [ "$rc" -ne 0 ]; then
              echo "Error checking repository '$repo' (exit $rc)" >&2
              return "$rc"
            fi

            echo "Backing up '$staging' -> '$repo'..."
            restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" backup "$staging" \
              --tag host-snapshot \
              --tag "host:${hostName}" \
              --tag "target:$tname" \
              "''${exclude_args[@]}"

            echo "Pruning '$repo' with policy: ''${keep_args[*]}"
            restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" unlock || true
            restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" forget --prune "''${keep_args[@]}"
          }

          case "$cmd" in
            local)
              create_local_snapshot
              ;;
            all)
              create_local_snapshot
              ${lib.optionalString (enabledTargets != {}) ''
            prepare_staging
            ${lib.concatStrings (lib.mapAttrsToList (tName: tCfg: ''
                run_target ${lib.escapeShellArg tName} ${lib.escapeShellArg targetRepos.${tName}} ${lib.escapeShellArgs tCfg.keep}
              '')
              enabledTargets)}
          ''}
              ;;
            ${lib.concatStrings (lib.mapAttrsToList (tName: tCfg: ''
              ${lib.escapeShellArg tName})
                create_local_snapshot
                prepare_staging
                run_target ${lib.escapeShellArg tName} ${lib.escapeShellArg targetRepos.${tName}} ${lib.escapeShellArgs tCfg.keep}
                ;;
            '')
            enabledTargets)}
            *)
              echo "Usage: nixconf-host-snapshot [all|local|list|${lib.concatStringsSep "|" (builtins.attrNames enabledTargets)}]" >&2
              exit 2
              ;;
          esac
        '';
      };
    in {
      options.services.hostSnapshot = {
        enable = lib.mkEnableOption "atomic Btrfs host snapshots with restic off-site targets" // {default = true;};

        subvolume = lib.mkOption {
          type = lib.types.str;
          default = "/persist";
          description = "Btrfs subvolume mountpoint captured atomically on each snapshot run.";
        };

        snapshotDir = lib.mkOption {
          type = lib.types.str;
          default = "/persist/.snapshots";
          description = "Directory holding local read-only Btrfs snapshots and the transient remote-upload staging subvolume.";
        };

        localKeep = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 2;
          description = "Maximum number of local `local-*` read-only Btrfs snapshots retained under `snapshotDir`.";
        };

        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/persist/.snapshots/staging/.snapshots"
            "/persist/.snapshots/staging/system/var/cache"
          ];
          description = "Paths excluded when archiving the staged read-only Btrfs snapshot with `restic`.";
        };

        targets = lib.mkOption {
          type = lib.types.attrsOf targetSubmodule;
          default = {};
          apply = mergeBuiltinTargets;
          defaultText = lib.literalExpression "{ hbox = ...; gdrive = ...; }";
          description = "Named remote snapshot targets backed by `storage.slices`, systemd timers, and `restic forget --prune` retention policies.";
        };
      };

      config = lib.mkIf cfg.enable {
        secrets.files.restic-password = lib.mkDefault {
          store = "backup/restic";
          key = "password";
          testValue = "test-restic-password";
        };

        storage.activeSlices = lib.unique (lib.mapAttrsToList (_: t: t.slice) enabledTargets);

        environment.systemPackages = [snapshotScript];

        systemd.services = builtins.listToAttrs (lib.mapAttrsToList (tName: _: {
            name = "host-snapshot-${tName}";
            value = {
              description = "Create Btrfs snapshot of ${cfg.subvolume} and back up to '${tName}'";
              after = [
                "rclone-config.service"
                "sops-install-secrets.service"
                "network-online.target"
              ];
              requires = ["rclone-config.service"];
              wants = ["network-online.target"];
              environment = {
                RCLONE_CONFIG = "/etc/rclone/rclone.conf";
                RESTIC_PASSWORD_FILE = config.secrets.files.restic-password.path;
              };
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${lib.getExe snapshotScript} ${lib.escapeShellArg tName}";
              };
            };
          })
          enabledTargets);

        systemd.timers = builtins.listToAttrs (lib.mapAttrsToList (tName: tCfg: {
            name = "host-snapshot-${tName}";
            value = {
              description = "Periodic host Btrfs + restic snapshot timer for '${tName}'";
              wantedBy = ["timers.target"];
              timerConfig =
                {
                  OnCalendar = tCfg.onCalendar;
                  Persistent = tCfg.persistent;
                }
                // lib.optionalAttrs (tCfg.randomizedDelaySec != null) {
                  RandomizedDelaySec = tCfg.randomizedDelaySec;
                };
            };
          })
          enabledTargets);

        testing = {
          vm.allowedFailedUnits = ["host-snapshot-*.service"];

          snapshot = {
            description = "Declarative host Btrfs snapshot and restic target checks";
            evalChecks = {
              valid-target-slices = {
                assertion = lib.all (t: config.storage.slices ? ${t.slice}) (builtins.attrValues enabledTargets);
                message = "services.hostSnapshot.targets reference unknown storage slices.";
              };
              slices-registered = {
                assertion = lib.all (t: builtins.elem t.slice config.storage.activeSlices) (builtins.attrValues enabledTargets);
                message = "Enabled host snapshot target slices must be registered in storage.activeSlices.";
              };
              non-empty-keep = {
                assertion = lib.all (t: t.keep != []) (builtins.attrValues enabledTargets);
                message = "Enabled host snapshot targets must specify at least one restic keep retention flag.";
              };
            };
            inspectChecks = {
              snapshot-units-generated = {
                description = "Verify host-snapshot systemd services and timers exist in /etc/systemd/system";
                priority = 125;
                script =
                  lib.concatMapStrings (tName: ''
                    test -e "$etc/systemd/system/host-snapshot-${tName}.service"
                    test -e "$etc/systemd/system/host-snapshot-${tName}.timer"
                  '') (builtins.attrNames enabledTargets)
                  + ''
                    echo "Verified ${toString (builtins.length (builtins.attrNames enabledTargets))} host snapshot targets."
                  '';
              };
            };
          };
        };
      };
    };
  };
}
