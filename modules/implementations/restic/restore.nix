{
  internal.restic.mkRestore = {
    lib,
    pkgs,
    resolvedUnits,
    passwordFile,
  }: let
    restorableUnits =
      lib.filterAttrs (
        _: u: u.unit.autoRestore && u.destinations != []
      )
      resolvedUnits;

    mkUnitRestore = uName: u: let
      uCfg = u.unit;
      destRepos = map (d: d.repository) u.destinations;

      script = pkgs.writeShellApplication {
        name = "nixconf-restic-restore-${uName}";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
          pkgs.jq
          pkgs.openssh
          pkgs.rclone
          pkgs.restic
        ];
        text = ''
          export RCLONE_CONFIG=/run/rclone/rclone.conf
          export RESTIC_PASSWORD_FILE=${lib.escapeShellArg passwordFile}

          force_latest=false
          case "''${1:-}" in
            --force-latest) force_latest=true ;;
            "") ;;
            *)
              echo "Usage: nixconf-restic-restore-${uName} [--force-latest]" >&2
              exit 2
              ;;
          esac

          state_dir="/var/lib/nixconf-backup/units"
          token_file="$state_dir/${uName}.json"
          incomplete_file="$state_dir/${uName}.incomplete"
          mkdir -p "$state_dir"

          unit_paths=(${lib.escapeShellArgs uCfg.paths})
          repos=(${lib.escapeShellArgs destRepos})

          missing_paths=()
          if [ "$force_latest" = true ]; then
            missing_paths=("''${unit_paths[@]}")
          else
            for p in "''${unit_paths[@]}"; do
              if [ -f "$incomplete_file" ] && grep -Fxq -- "$p" "$incomplete_file"; then
                echo "Path '$p' had an interrupted previous restore; scheduling re-restore."
                missing_paths+=("$p")
              elif [ ! -e "$p" ]; then
                missing_paths+=("$p")
              elif [ -d "$p" ]; then
                if [ -z "$(find "$p" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
                  missing_paths+=("$p")
                fi
              fi
            done
          fi

          paths_json=$(printf '%s\n' "''${unit_paths[@]}" | jq -R . | jq -s .)

          if [ "''${#missing_paths[@]}" -eq 0 ]; then
            if [ ! -f "$token_file" ]; then
              tmp_token=$(mktemp "$state_dir/.${uName}.json.XXXXXX")
              jq -n \
                --arg unit "${uName}" \
                --arg status "existing-local" \
                --argjson paths "$paths_json" \
                --arg checkedAt "$(date -Iseconds)" \
                '{unit: $unit, status: $status, paths: $paths, checkedAt: $checkedAt}' > "$tmp_token"
              mv "$tmp_token" "$token_file"
            fi
            echo "All paths for unit '${uName}' are present locally; skipping auto-restore."
            exit 0
          fi

          best_repo=""
          best_snap=""
          best_time=""
          best_epoch=-1
          reachable=0
          uninitialized=0
          failed=0

          for repo in "''${repos[@]}"; do
            set +e
            # Bound boot-time snapshot probes so unreachable backends (e.g. offline/DNS timeouts) do not stall multi-user.target.
            snap_json=$(timeout --kill-after=5s 20s restic -r "$repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" -o "rclone.args=serve restic --stdio --contimeout=5s --timeout=15s --retries=1 --low-level-retries=1" --no-lock snapshots --json --tag "unit:${uName}" 2>/dev/null)
            rc=$?
            set -e

            if [ "$rc" -eq 10 ]; then
              echo "Repository '$repo' is not initialized yet for '${uName}'."
              uninitialized=$((uninitialized + 1))
              continue
            elif [ "$rc" -ne 0 ]; then
              echo "Warning: failed to query snapshots from '$repo' for '${uName}' (exit $rc)." >&2
              failed=$((failed + 1))
              continue
            fi

            reachable=$((reachable + 1))
            latest=$(printf '%s\n' "$snap_json" | jq -e -r 'if type == "array" and length > 0 then (sort_by(.time) | last) | "\(.id)\t\(.time)" else empty end' 2>/dev/null || true)
            if [ -z "$latest" ]; then
              continue
            fi

            IFS=$'\t' read -r snap_id snap_time <<< "$latest"
            snap_epoch=$(date -d "$snap_time" +%s 2>/dev/null || echo 0)

            if [ -z "$best_snap" ] || [ "$snap_epoch" -gt "$best_epoch" ]; then
              best_epoch="$snap_epoch"
              best_snap="$snap_id"
              best_time="$snap_time"
              best_repo="$repo"
            fi
          done

          if [ -z "$best_snap" ]; then
            if [ "$reachable" -gt 0 ] || [ "$uninitialized" -gt 0 ]; then
              echo "No snapshots found for unit '${uName}' across reachable repositories; starting with fresh state."
              exit 0
            fi
            echo "Error: all configured repositories ($failed) failed to answer snapshot queries for '${uName}'." >&2
            exit 1
          fi

          tmp_inc=$(mktemp "$state_dir/.${uName}.incomplete.XXXXXX")
          printf '%s\n' "''${missing_paths[@]}" > "$tmp_inc"
          mv "$tmp_inc" "$incomplete_file"

          include_args=()
          for mp in "''${missing_paths[@]}"; do
            include_args+=(--include "$mp")
          done

          echo "Restoring missing/incomplete paths for unit '${uName}' from '$best_repo' snapshot '$best_snap' ($best_time): ''${missing_paths[*]}"
          restic -r "$best_repo" -o "rclone.program=${pkgs.rclone}/bin/rclone" --no-lock restore "$best_snap" --target / "''${include_args[@]}"

          restored_json=$(printf '%s\n' "''${missing_paths[@]}" | jq -R . | jq -s .)
          tmp_token=$(mktemp "$state_dir/.${uName}.json.XXXXXX")
          jq -n \
            --arg unit "${uName}" \
            --arg status "restored" \
            --arg repository "$best_repo" \
            --arg snapshotId "$best_snap" \
            --arg snapshotTime "$best_time" \
            --argjson restoredPaths "$restored_json" \
            --arg restoredAt "$(date -Iseconds)" \
            '{unit: $unit, status: $status, repository: $repository, snapshotId: $snapshotId, snapshotTime: $snapshotTime, restoredPaths: $restoredPaths, restoredAt: $restoredAt}' > "$tmp_token"
          mv "$tmp_token" "$token_file"
          rm -f "$incomplete_file"
        '';
      };
    in {
      package = script;
      serviceName = "restic-restore-${uName}";
      service = {
        description = "Boot-time restic auto-restore for backup unit '${uName}'";
        after = [
          "rclone-config.service"
          "sops-install-secrets.service"
          "network-online.target"
        ];
        wants = ["network-online.target"];
        requires = ["rclone-config.service"];
        before = uCfg.beforeUnits;
        wantedBy = lib.unique (["multi-user.target"] ++ uCfg.beforeUnits);
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe script;
        };
      };
    };

    builtUnits = lib.mapAttrs mkUnitRestore restorableUnits;

    restorePackages = lib.mapAttrsToList (_: v: v.package) builtUnits;

    restoreServices = builtins.listToAttrs (lib.mapAttrsToList (_: v: {
        name = v.serviceName;
        value = v.service;
      })
      builtUnits);

    restoreAllowedFailedUnits =
      lib.optional (restoreServices != {}) "restic-restore-*.service";
  in {
    inherit restorePackages restoreServices restoreAllowedFailedUnits;
  };
}
