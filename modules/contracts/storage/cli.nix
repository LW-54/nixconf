{
  self,
  lib,
  ...
}: let
  mkStoragePackage = {pkgs}: let
    hosts = self.nixosConfigurations or {};
    fleetManifest = {
      hosts =
        lib.mapAttrs (
          hostName: hostEval:
            self.lib.storage.resolveHostStorage {
              storageCfg = hostEval.config.storage;
              inherit hostName;
            }
        )
        hosts;
    };
    manifestFile = pkgs.writeText "storage-fleet-manifest.json" (builtins.toJSON fleetManifest);
    sopsWriteScript = self.lib.sops.mkWriteSecretScript {inherit pkgs;};
  in
    pkgs.writeShellApplication {
      name = "nixconf-storage";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.curl
        pkgs.git
        pkgs.gnugrep
        pkgs.jq
        pkgs.openssh
        pkgs.openssl
        pkgs.sops
        pkgs.sshpass
      ];
      meta = {
        description = "Declarative multi-provider storage reconciler and drift checker across all fleet hosts.";
        helpCommand = "nixconf-storage --help";
        usage = ''
          Inspect declared storage topology, audit SOPS secrets, and reconcile Hetzner Storage Box API state.

          ```bash
          # List evaluated providers, instances, shared/per-host slices, and endpoints
          nix run .#storage -- --list

          # Verify SOPS secrets and Hetzner Storage Box API state (read-only)
          nix develop .#storage-admin --command nixconf-storage --check

          # Reconcile Hetzner subaccounts, snapshot plans, and encrypted SOPS secrets
          nix develop .#storage-admin --command nixconf-storage --write
          ```
        '';
      };
      text = ''
        ${sopsWriteScript}

        MANIFEST="${manifestFile}"
        MODE="check"
        ASSUME_YES=0
        HOST_FILTER=""

        show_help() {
          cat <<'EOF'
        nixconf-storage — Declarative Storage Reconciler

        Usage:
          nixconf-storage [MODE] [OPTIONS]

        Modes:
          --check          Verify SOPS secrets and provider API state for drift (default).
          --write          Reconcile Hetzner Storage Box state and populate missing SOPS secrets.
          --list           Print evaluated fleet providers, instances, slices, and endpoints.
          --help, -h       Show this help text.

        Options:
          --host <name>    Restrict output/reconciliation to a single host.
          --yes, -y        Skip interactive confirmation before applying `--write` mutations.
          --json           Emit raw evaluated fleet manifest JSON (with `--list`).
        EOF
        }

        OUTPUT_JSON=0
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --check) MODE="check"; shift ;;
            --write) MODE="write"; shift ;;
            --list) MODE="list"; shift ;;
            --yes|-y) ASSUME_YES=1; shift ;;
            --json) OUTPUT_JSON=1; shift ;;
            --host)
              HOST_FILTER="''${2:-}"
              if [[ -z "$HOST_FILTER" ]]; then
                echo "error: --host requires an argument" >&2
                exit 2
              fi
              shift 2
              ;;
            --help|-h) show_help; exit 0 ;;
            *)
              echo "error: unknown argument '$1'" >&2
              show_help >&2
              exit 2
              ;;
          esac
        done

        REPO_ROOT="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

        host_names() {
          if [[ -n "$HOST_FILTER" ]]; then
            jq -e --arg h "$HOST_FILTER" '.hosts[$h] != null' "$MANIFEST" >/dev/null || {
              echo "error: unknown host '$HOST_FILTER'" >&2
              exit 2
            }
            printf '%s\n' "$HOST_FILTER"
          else
            jq -r '.hosts | keys[]' "$MANIFEST"
          fi
        }

        if [[ "$MODE" == "list" ]]; then
          if [[ "$OUTPUT_JSON" -eq 1 ]]; then
            if [[ -n "$HOST_FILTER" ]]; then
              jq --arg h "$HOST_FILTER" '.hosts[$h]' "$MANIFEST"
            else
              cat "$MANIFEST"
            fi
            exit 0
          fi

          while IFS= read -r host; do
            echo "=== Host: $host ==="
            echo "  Providers:"
            jq -r --arg h "$host" '
              .hosts[$h].providers | to_entries[] |
              "    - \(.key) (driver=\(.value.driver), store=secrets/\(.value.secretStore).yaml)"
            ' "$MANIFEST"
            echo "  Slices:"
            jq -r --arg h "$host" '
              .hosts[$h].slices | to_entries[] |
              (.value.secrets | map("secrets/\(.store).yaml") | unique | join(",")) as $stores |
              "    - \(.key): kind=\(.value.kind) scope=\(.value.scope) provider=\(.value.providerName) remote=\(.value.rcloneRemoteName) path=\(.value.resolvedPath) stores=[\($stores)]"
            ' "$MANIFEST"
            echo "  Mounts:"
            mounts_count="$(jq -r --arg h "$host" '.hosts[$h].mounts | length' "$MANIFEST")"
            if [[ "$mounts_count" -eq 0 ]]; then
              echo "    (none)"
            else
              jq -r --arg h "$host" '
                .hosts[$h].mounts | to_entries[] |
                "    - \(.key): \(.value.slice) -> \(.value.mountPoint) (protocol=\(.value.protocol))"
              ' "$MANIFEST"
            fi
          done < <(host_names)
          exit 0
        fi

        # ----------------------------------------------------------------------
        # Shared SOPS & Hetzner Helpers
        # ----------------------------------------------------------------------

        sops_has_key() {
          local store="$1"
          local key="$2"
          local file="$REPO_ROOT/secrets/''${store}.yaml"
          [[ -f "$file" ]] && grep -Eq "^''${key}:" "$file"
        }

        sops_can_decrypt_store() {
          local store="$1"
          local file="$REPO_ROOT/secrets/''${store}.yaml"
          [[ -f "$file" ]] && (cd "$REPO_ROOT" && sops --config "$REPO_ROOT/.sops.yaml" -d "$file" >/dev/null 2>&1)
        }

        sops_read_key() {
          local store="$1"
          local key="$2"
          local file="$REPO_ROOT/secrets/''${store}.yaml"
          local key_json val
          [[ -f "$file" ]] || return 1
          key_json="$(jq -Rn --arg k "$key" '$k')"
          val="$(cd "$REPO_ROOT" && sops --config "$REPO_ROOT/.sops.yaml" -d --extract "[''${key_json}]" "$file" 2>/dev/null)" || return 1
          if [[ -z "$val" ]] || [[ "$val" == CHANGE_ME* ]]; then
            return 1
          fi
          printf '%s' "$val"
        }

        hetzner_api() {
          local method="$1"
          local token="$2"
          local path="$3"
          local body="''${4:-}"
          local resp_file http_code
          resp_file="$(mktemp "$TMP_DIR/hetzner-resp.XXXXXX")"
          if [[ -n "$body" ]]; then
            http_code="$(curl -sSL -o "$resp_file" -w "%{http_code}" -X "$method" \
              -H "Authorization: Bearer $token" \
              -H "Content-Type: application/json" \
              --data "$body" \
              "https://api.hetzner.com/v1''${path}")"
          else
            http_code="$(curl -sSL -o "$resp_file" -w "%{http_code}" -X "$method" \
              -H "Authorization: Bearer $token" \
              "https://api.hetzner.com/v1''${path}")"
          fi
          if [[ "$http_code" -ge 400 ]]; then
            echo "  [ERROR] Hetzner API $method $path failed (HTTP $http_code):" >&2
            cat "$resp_file" >&2
            echo >&2
            rm -f "$resp_file"
            return 1
          fi
          cat "$resp_file"
          rm -f "$resp_file"
        }

        wait_hetzner_action() {
          local token="$1"
          local box_id="$2"
          local resp_json="$3"
          local act_id act_status act_err act_resp
          act_id="$(jq -r '.action.id // empty' <<< "$resp_json")"
          if [[ -z "$act_id" ]] || [[ "$act_id" == "null" ]]; then
            return 0
          fi
          for _ in $(seq 1 30); do
            act_resp="$(hetzner_api GET "$token" "/storage_boxes/$box_id/actions/$act_id")"
            act_status="$(jq -r '.action.status // empty' <<< "$act_resp")"
            if [[ "$act_status" == "success" ]]; then
              return 0
            elif [[ "$act_status" == "error" ]]; then
              act_err="$(jq -r '.action.error.message // "unknown action error"' <<< "$act_resp")"
              echo "  [ERROR] Hetzner action $act_id failed: $act_err" >&2
              return 1
            fi
            sleep 1
          done
          echo "  [ERROR] timed out waiting for Hetzner action $act_id" >&2
          return 1
        }

        resolve_hetzner_box_json() {
          local token="$1"
          local box_id="$2"
          local all_boxes
          all_boxes="$(hetzner_api GET "$token" "/storage_boxes")"
          jq -c --arg b "$box_id" '
            .storage_boxes[] |
            select((.username // "") == $b or (.name // "") == $b or ((.id | tostring) == $b))
          ' <<< "$all_boxes" | head -n1
        }

        find_subaccount_json() {
          local subs_json="$1"
          local desc="$2"
          local home_dir="$3"
          local clean_home="''${home_dir#/}"
          clean_home="''${clean_home%/}"
          jq -c --arg d "$desc" --arg h "$clean_home" '
            .subaccounts[] |
            select((.description // "") == $d or ((.home_directory // "") | ltrimstr("/") | rtrimstr("/")) == $h)
          ' <<< "$subs_json" | head -n1
        }

        gen_password() {
          printf '%sAa1!@-\n' "$(openssl rand -base64 24 | tr -d '/+=\n' | head -c 20)"
        }

        # Collect deduplicated secrets & reconcile items across selected hosts
        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_DIR"' EXIT

        SELECTED_HOSTS_JSON="$(host_names | jq -R . | jq -s .)"
        jq --argjson hs "$SELECTED_HOSTS_JSON" '
          [ $hs[] as $h | .hosts[$h].allSecrets[] ] |
          reduce .[] as $item ({seen: {}, out: []};
            ($item.store + ":" + $item.key) as $id |
            if .seen[$id] then . else {seen: (.seen + {($id): true}), out: (.out + [$item])} end
          ) | .out
        ' "$MANIFEST" > "$TMP_DIR/secrets.json"

        jq --argjson hs "$SELECTED_HOSTS_JSON" '
          [ $hs[] as $h | .hosts[$h].allReconcile[] ] |
          reduce .[] as $item ({seen: {}, out: []};
            (if $item.kind == "hetzner-snapshot-plan" then "plan:" + $item.providerName + ":" + $item.boxId
             elif $item.kind == "hetzner-subaccount" then "sub:" + $item.providerName + ":" + $item.boxId + ":" + $item.subaccount.description
             else "sops:" + $item.secretStore + ":" + $item.sliceName end) as $id |
            if .seen[$id] then . else {seen: (.seen + {($id): true}), out: (.out + [$item])} end
          ) | .out
        ' "$MANIFEST" > "$TMP_DIR/reconcile.json"

        run_driver_hooks() {
          local h_json dname hook_script
          h_json="$(jq -c --argjson hs "$SELECTED_HOSTS_JSON" '
            [ $hs[] as $h | .hosts[$h].driverHooks | to_entries[] ] |
            reduce .[] as $e ({}; . + {($e.key): $e.value})
          ' "$MANIFEST")"
          while IFS= read -r entry; do
            dname="$(jq -r '.key' <<< "$entry")"
            hook_script="$(jq -r '.value' <<< "$entry")"
            echo "==> Running driver hook ($dname, mode=$MODE)..."
            if ! NIXCONF_STORAGE_MODE="$MODE" NIXCONF_STORAGE_MANIFEST="$MANIFEST" bash -euo pipefail -c "$hook_script"; then
              echo "  [DRIFT] driver hook '$dname' failed"
              DRIFT=1
            fi
          done < <(jq -c 'to_entries[]' <<< "$h_json")
        }

        sync_hetzner_ssh_keys() {
          local ssh_store="$1" scope="$2" hname="$3" sub_user="$4" sub_host="$5" sub_port="$6" sub_pw="$7"
          local auth_file batch_file k keys_list val
          if [[ ! -f "$REPO_ROOT/secrets/''${ssh_store}.yaml" ]]; then
            return 0
          fi
          auth_file="$(mktemp "$TMP_DIR/authkeys.XXXXXX")"
          keys_list="master"
          if [[ "$scope" == "per-host" ]] && [[ -n "$hname" ]] && [[ "$hname" != "null" ]]; then
            keys_list="$keys_list"$'\n'"$hname"
          else
            while IFS= read -r k; do
              if [[ "$k" != "sops" ]] && [[ "$k" != "master" ]]; then
                keys_list="$keys_list"$'\n'"$k"
              fi
            done < <(grep -E '^[A-Za-z0-9_-]+:' "$REPO_ROOT/secrets/''${ssh_store}.yaml" | cut -d: -f1)
          fi
          while IFS= read -r k; do
            [[ -n "$k" ]] || continue
            if sops_has_key "$ssh_store" "$k"; then
              val="$(sops_read_key "$ssh_store" "$k" || true)"
              if [[ -n "$val" ]]; then
                printf '%s\n' "$val" >> "$auth_file"
              fi
            fi
          done <<< "$keys_list"
          if [[ ! -s "$auth_file" ]]; then
            return 0
          fi
          batch_file="$(mktemp "$TMP_DIR/sftp-batch.XXXXXX")"
          cat > "$batch_file" <<SFTP
        -mkdir .ssh
        put $auth_file .ssh/authorized_keys
        chmod 700 .ssh
        chmod 600 .ssh/authorized_keys
        SFTP
          if sshpass -p "$sub_pw" sftp -o BatchMode=no -o StrictHostKeyChecking=accept-new -o PubkeyAuthentication=no -P "$sub_port" -b "$batch_file" "''${sub_user}@''${sub_host}" >/dev/null 2>&1; then
            echo "  [SSH] synced .ssh/authorized_keys for ''${sub_user}"
          else
            echo "  [WARN] could not push .ssh/authorized_keys for ''${sub_user} (port ''${sub_port})" >&2
          fi
        }

        DRIFT=0

        if [[ "$MODE" == "check" ]]; then
          echo "==> Checking SOPS storage secrets..."
          while IFS= read -r item; do
            store="$(jq -r '.store' <<< "$item")"
            key="$(jq -r '.key' <<< "$item")"
            optional="$(jq -r '.optional' <<< "$item")"
            if sops_has_key "$store" "$key"; then
              if sops_can_decrypt_store "$store"; then
                if sops_read_key "$store" "$key" >/dev/null; then
                  echo "  [OK] secrets/''${store}.yaml : $key"
                elif [[ "$optional" == "true" ]]; then
                  echo "  [INFO] secrets/''${store}.yaml : $key (optional, placeholder/empty)"
                else
                  echo "  [DRIFT] placeholder not populated in secrets/''${store}.yaml : $key"
                  DRIFT=1
                fi
              else
                echo "  [OK] secrets/''${store}.yaml : $key (encrypted)"
              fi
            elif [[ "$optional" == "true" ]]; then
              echo "  [INFO] secrets/''${store}.yaml : $key (optional, not set)"
            else
              echo "  [DRIFT] missing secrets/''${store}.yaml : $key"
              DRIFT=1
            fi
          done < <(jq -c '.[]' "$TMP_DIR/secrets.json")

          echo "==> Checking Hetzner Storage Box API state..."
          while IFS= read -r prov; do
            pname="$(jq -r '.providerName' <<< "$prov")"
            box_id="$(jq -r '.boxId' <<< "$prov")"
            pstore="$(jq -r '.providerSecretStore' <<< "$prov")"
            tkey="$(jq -r '.apiTokenKey' <<< "$prov")"
            token=""
            if [[ -n "''${HETZNER_TOKEN:-}" ]]; then
              token="$HETZNER_TOKEN"
            elif sops_has_key "$pstore" "$tkey"; then
              token="$(sops_read_key "$pstore" "$tkey" || true)"
            fi
            if [[ -z "$token" ]]; then
              echo "  [SKIP] provider '$pname' ($box_id): unavailable token (store secrets/''${pstore}.yaml:$tkey or \$HETZNER_TOKEN; run inside 'nix develop .#storage-admin')"
              continue
            fi

            box_json="$(resolve_hetzner_box_json "$token" "$box_id" || true)"
            if [[ -z "$box_json" ]]; then
              echo "  [DRIFT] provider '$pname': Storage Box '$box_id' not found via api.hetzner.com/v1"
              DRIFT=1
              continue
            fi
            num_id="$(jq -r '.id' <<< "$box_json")"

            # Check snapshot plan
            want_snap_en="$(jq -r '.snapshotPlan.enable' <<< "$prov")"
            cur_snap="$(jq -c '.snapshot_plan // null' <<< "$box_json")"
            if [[ "$want_snap_en" == "true" ]]; then
              want_max="$(jq -r '.snapshotPlan.maxSnapshots' <<< "$prov")"
              want_hr="$(jq -r '.snapshotPlan.hour' <<< "$prov")"
              want_min="$(jq -r '.snapshotPlan.minute' <<< "$prov")"
              if [[ "$cur_snap" == "null" ]] || \
                 [[ "$(jq -r '.max_snapshots // -1' <<< "$cur_snap")" != "$want_max" ]] || \
                 [[ "$(jq -r '.hour // -1' <<< "$cur_snap")" != "$want_hr" ]] || \
                 [[ "$(jq -r '.minute // -1' <<< "$cur_snap")" != "$want_min" ]]; then
                echo "  [DRIFT] provider '$pname' ($box_id): snapshot_plan differs from Nix declaration"
                DRIFT=1
              else
                echo "  [OK] provider '$pname' ($box_id): snapshot_plan in sync"
              fi
            elif [[ "$cur_snap" != "null" ]]; then
              echo "  [DRIFT] provider '$pname' ($box_id): snapshot_plan enabled upstream, disabled in Nix"
              DRIFT=1
            fi

            # Check subaccounts
            subs_json="$(hetzner_api GET "$token" "/storage_boxes/$num_id/subaccounts")"
            while IFS= read -r sub_rec; do
              sdesc="$(jq -r '.subaccount.description' <<< "$sub_rec")"
              shome="$(jq -r '.subaccount.homeDirectory' <<< "$sub_rec")"
              w_ssh="$(jq -r '.subaccount.sshEnabled' <<< "$sub_rec")"
              w_dav="$(jq -r '.subaccount.webdavEnabled' <<< "$sub_rec")"
              w_smb="$(jq -r '.subaccount.sambaEnabled' <<< "$sub_rec")"
              w_ro="$(jq -r '.subaccount.readonly' <<< "$sub_rec")"
              w_ext="$(jq -r '.subaccount.reachableExternally' <<< "$sub_rec")"
              found_sub="$(find_subaccount_json "$subs_json" "$sdesc" "$shome" || true)"
              if [[ -z "$found_sub" ]]; then
                echo "  [DRIFT] provider '$pname' ($box_id): missing subaccount '$sdesc' (home=$shome)"
                DRIFT=1
              else
                match_flags="$(jq -r \
                  --argjson ssh "$w_ssh" --argjson dav "$w_dav" --argjson smb "$w_smb" \
                  --argjson ro "$w_ro" --argjson ext "$w_ext" '
                  ((.access_settings.ssh_enabled // false) == $ssh) and
                  ((.access_settings.webdav_enabled // false) == $dav) and
                  ((.access_settings.samba_enabled // false) == $smb) and
                  ((.access_settings.readonly // false) == $ro) and
                  ((.access_settings.reachable_externally // false) == $ext)
                ' <<< "$found_sub")"
                if [[ "$match_flags" == "true" ]]; then
                  echo "  [OK] subaccount '$sdesc' in sync (home=$shome)"
                else
                  echo "  [DRIFT] subaccount '$sdesc' access_settings differ from Nix"
                  DRIFT=1
                fi
              fi
            done < <(jq -c --arg p "$pname" --arg b "$box_id" '.[] | select(.kind == "hetzner-subaccount" and .providerName == $p and .boxId == $b)' "$TMP_DIR/reconcile.json")
          done < <(jq -c '.[] | select(.kind == "hetzner-snapshot-plan")' "$TMP_DIR/reconcile.json")

          run_driver_hooks

          if [[ "$DRIFT" -ne 0 ]]; then
            echo "Drift check FAILED. Run '--write' inside 'nix develop .#storage-admin' to reconcile." >&2
            exit 1
          fi
          echo "All checked storage resources are in sync."
          exit 0
        fi

        # ----------------------------------------------------------------------
        # Write / Reconciliation Mode
        # ----------------------------------------------------------------------
        echo "==> Reconciliation Plan (--write):"
        jq -r '
          .[] |
          if .kind == "hetzner-snapshot-plan" then
            "  - [Hetzner Snapshot] provider=\(.providerName) box=\(.boxId) enable=\(.snapshotPlan.enable) max=\(.snapshotPlan.maxSnapshots) at \(.snapshotPlan.hour):\(.snapshotPlan.minute) UTC"
          elif .kind == "hetzner-subaccount" then
            "  - [Hetzner Subaccount] provider=\(.providerName) box=\(.boxId) desc=\(.subaccount.description) home=\(.subaccount.homeDirectory) store=secrets/\(.subaccount.passwordStore).yaml"
          else
            "  - [SOPS Secret] slice=\(.sliceName) store=secrets/\(.secretStore).yaml"
          end
        ' "$TMP_DIR/reconcile.json"

        if [[ "$ASSUME_YES" -ne 1 ]]; then
          if [[ ! -t 0 ]]; then
            echo "error: non-interactive stdin; pass --yes to apply reconciliation" >&2
            exit 2
          fi
          read -r -p "Apply reconciliation plan? [y/N] " reply
          case "$reply" in
            y|Y|yes|YES) ;;
            *) echo "Aborted."; exit 1 ;;
          esac
        fi

        echo "==> Generating missing SOPS crypt/random secrets..."
        while IFS= read -r item; do
          store="$(jq -r '.store' <<< "$item")"
          key="$(jq -r '.key' <<< "$item")"
          gen="$(jq -r '.generate // ""' <<< "$item")"
          if [[ "$gen" == "random-password" ]] && ! sops_read_key "$store" "$key" >/dev/null; then
            # Skip subaccount passwords here unless not hetzner-subaccount managed
            if [[ "$key" != "password" ]]; then
              new_pw="$(gen_password)"
              sops_write_secret "$store" "$key" "$new_pw"
              echo "  [WROTE] secrets/''${store}.yaml : $key"
            fi
          fi
        done < <(jq -c '.[]' "$TMP_DIR/secrets.json")

        echo "==> Reconciling Hetzner Storage Box API resources..."
        while IFS= read -r prov; do
          pname="$(jq -r '.providerName' <<< "$prov")"
          box_id="$(jq -r '.boxId' <<< "$prov")"
          pstore="$(jq -r '.providerSecretStore' <<< "$prov")"
          tkey="$(jq -r '.apiTokenKey' <<< "$prov")"
          token=""
          if [[ -n "''${HETZNER_TOKEN:-}" ]]; then
            token="$HETZNER_TOKEN"
          elif sops_has_key "$pstore" "$tkey"; then
            token="$(sops_read_key "$pstore" "$tkey" || true)"
          fi
          if [[ -z "$token" ]]; then
            echo "  [WARN] skipping Hetzner API for '$pname' ($box_id): missing token in secrets/''${pstore}.yaml:$tkey or \$HETZNER_TOKEN" >&2
            continue
          fi

          box_json="$(resolve_hetzner_box_json "$token" "$box_id" || true)"
          if [[ -z "$box_json" ]]; then
            echo "  [ERROR] Storage Box '$box_id' not found on Hetzner API" >&2
            exit 1
          fi
          num_id="$(jq -r '.id' <<< "$box_json")"

          want_snap_en="$(jq -r '.snapshotPlan.enable' <<< "$prov")"
          if [[ "$want_snap_en" == "true" ]]; then
            snap_payload="$(jq -c '{
              max_snapshots: .snapshotPlan.maxSnapshots,
              hour: .snapshotPlan.hour,
              minute: .snapshotPlan.minute,
              day_of_week: .snapshotPlan.dayOfWeek,
              day_of_month: .snapshotPlan.dayOfMonth
            }' <<< "$prov")"
            act_json="$(hetzner_api POST "$token" "/storage_boxes/$num_id/actions/enable_snapshot_plan" "$snap_payload")"
            wait_hetzner_action "$token" "$num_id" "$act_json"
            echo "  [SYNCED] provider '$pname' ($box_id): snapshot_plan enabled"
          else
            act_json="$(hetzner_api POST "$token" "/storage_boxes/$num_id/actions/disable_snapshot_plan" '{}')"
            wait_hetzner_action "$token" "$num_id" "$act_json"
            echo "  [SYNCED] provider '$pname' ($box_id): snapshot_plan disabled"
          fi

          subs_json="$(hetzner_api GET "$token" "/storage_boxes/$num_id/subaccounts")"
          while IFS= read -r sub_rec; do
            sname="$(jq -r '.subaccount.name' <<< "$sub_rec")"
            sdesc="$(jq -r '.subaccount.description' <<< "$sub_rec")"
            shome="$(jq -r '.subaccount.homeDirectory' <<< "$sub_rec")"
            sub_host="$(jq -r '.host' <<< "$sub_rec")"
            sub_port="$(jq -r '.port' <<< "$sub_rec")"
            ssh_store="$(jq -r '.sshPublicKeysStore' <<< "$sub_rec")"
            sub_scope="$(jq -r '.scope' <<< "$sub_rec")"
            sub_hname="$(jq -r '.hostName // ""' <<< "$sub_rec")"
            w_ssh="$(jq -r '.subaccount.sshEnabled' <<< "$sub_rec")"
            w_dav="$(jq -r '.subaccount.webdavEnabled' <<< "$sub_rec")"
            w_smb="$(jq -r '.subaccount.sambaEnabled' <<< "$sub_rec")"
            w_ro="$(jq -r '.subaccount.readonly' <<< "$sub_rec")"
            w_ext="$(jq -r '.subaccount.reachableExternally' <<< "$sub_rec")"
            u_store="$(jq -r '.subaccount.usernameStore' <<< "$sub_rec")"
            u_key="$(jq -r '.subaccount.usernameKey' <<< "$sub_rec")"
            p_store="$(jq -r '.subaccount.passwordStore' <<< "$sub_rec")"
            p_key="$(jq -r '.subaccount.passwordKey' <<< "$sub_rec")"

            found_sub="$(find_subaccount_json "$subs_json" "$sdesc" "$shome" || true)"
            sub_pw=""
            if [[ -z "$found_sub" ]]; then
              if sops_read_key "$p_store" "$p_key" >/dev/null; then
                sub_pw="$(sops_read_key "$p_store" "$p_key")"
              else
                sub_pw="$(gen_password)"
                sops_write_secret "$p_store" "$p_key" "$sub_pw"
              fi
              create_payload="$(jq -nc \
                --arg name "$sname" \
                --arg home "$shome" \
                --arg pw "$sub_pw" \
                --arg desc "$sdesc" \
                --argjson ssh "$w_ssh" --argjson dav "$w_dav" --argjson smb "$w_smb" \
                --argjson ro "$w_ro" --argjson ext "$w_ext" '{
                  name: $name,
                  home_directory: $home,
                  password: $pw,
                  description: $desc,
                  access_settings: {
                    ssh_enabled: $ssh,
                    webdav_enabled: $dav,
                    samba_enabled: $smb,
                    readonly: $ro,
                    reachable_externally: $ext
                  }
                }')"
              created="$(hetzner_api POST "$token" "/storage_boxes/$num_id/subaccounts" "$create_payload")"
              wait_hetzner_action "$token" "$num_id" "$created"
              sub_id="$(jq -r '.subaccount.id' <<< "$created")"
              sub_detail="$(hetzner_api GET "$token" "/storage_boxes/$num_id/subaccounts/$sub_id")"
              sub_user="$(jq -r '.subaccount.username // empty' <<< "$sub_detail")"
              if [[ -z "$sub_user" ]] || [[ "$sub_user" == "null" ]]; then
                echo "  [ERROR] missing username for new subaccount id=$sub_id" >&2
                exit 1
              fi
              sops_write_secret "$u_store" "$u_key" "$sub_user"
              echo "  [CREATED] subaccount '$sdesc' (user=$sub_user, store=secrets/''${u_store}.yaml)"
            else
              sub_id="$(jq -r '.id' <<< "$found_sub")"
              sub_user="$(jq -r '.username' <<< "$found_sub")"
              if ! sops_read_key "$u_store" "$u_key" >/dev/null; then
                sops_write_secret "$u_store" "$u_key" "$sub_user"
              fi
              if sops_read_key "$p_store" "$p_key" >/dev/null; then
                sub_pw="$(sops_read_key "$p_store" "$p_key" || true)"
              fi
              access_payload="$(jq -nc \
                --argjson ssh "$w_ssh" --argjson dav "$w_dav" --argjson smb "$w_smb" \
                --argjson ro "$w_ro" --argjson ext "$w_ext" '{
                  ssh_enabled: $ssh,
                  webdav_enabled: $dav,
                  samba_enabled: $smb,
                  readonly: $ro,
                  reachable_externally: $ext
                }')"
              act_json="$(hetzner_api POST "$token" "/storage_boxes/$num_id/subaccounts/$sub_id/actions/update_access_settings" "$access_payload")"
              wait_hetzner_action "$token" "$num_id" "$act_json"
              echo "  [SYNCED] subaccount '$sdesc' (user=$sub_user)"
            fi
            if [[ "$w_ssh" == "true" ]] && [[ -n "$sub_pw" ]]; then
              sync_hetzner_ssh_keys "$ssh_store" "$sub_scope" "$sub_hname" "$sub_user" "$sub_host" "$sub_port" "$sub_pw"
            fi
          done < <(jq -c --arg p "$pname" --arg b "$box_id" '.[] | select(.kind == "hetzner-subaccount" and .providerName == $p and .boxId == $b)' "$TMP_DIR/reconcile.json")
        done < <(jq -c '.[] | select(.kind == "hetzner-snapshot-plan")' "$TMP_DIR/reconcile.json")

        run_driver_hooks
        if [[ "$DRIFT" -ne 0 ]]; then
          echo "Reconciliation finished with hook errors." >&2
          exit 1
        fi
        echo "Reconciliation complete."
      '';
    };
in {
  contract.storage = {
    packages = {pkgs, ...}: {
      storage = mkStoragePackage {inherit pkgs;};
    };

    devShells = {
      pkgs,
      self',
      ...
    }: let
      storagePkg = (self'.packages or {}).storage or (mkStoragePackage {inherit pkgs;});
      bwPkg = (self'.packages or {}).bw or pkgs.bitwarden-cli;
    in {
      storage-admin = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = bwPkg;
        packages = [
          storagePkg
          pkgs.age
          pkgs.curl
          pkgs.jq
          pkgs.restic
          pkgs.rclone
          pkgs.sops
        ];
        meta = {
          description = "Administrative storage reconciliation shell unlocking SOPS_AGE_KEY via Bitwarden and exposing nixconf-storage.";
          usage = ''
            Administrative shell for inspecting, reconciling, and bootstrapping declarative storage infrastructure.

            ```bash
            # Enter shell (unlocks SOPS_AGE_KEY via Bitwarden)
            nix develop .#storage-admin

            # Inspect fleet providers and resolved slices
            nixconf-storage --list

            # Verify SOPS secrets and Hetzner Storage Box API drift
            nixconf-storage --check

            # Reconcile Hetzner subaccounts, snapshot plans, and missing SOPS secrets
            nixconf-storage --write
            ```
          '';
        };
        shellHook = self.lib.bitwarden.mkValue {
          itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
          variable = "SOPS_AGE_KEY";
          jqFilter = ".notes | select(type == \"string\" and length > 0)";
        };
      };
    };
  };
}
