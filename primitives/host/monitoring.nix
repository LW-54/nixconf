# Host monitoring module: baseline OS/process metrics, deployment annotations, systemd journal streaming, host alert rules, and core dashboards.
{...}: {
  _module.args = {
    hostMonitoringModule = {name}: {
      config,
      lib,
      pkgs,
      self,
      ...
    }: let
      d = self.lib.monitoring.dashboard;
      textfileDir = let
        t = config.monitoring.exporters.unix.textfileDirectory or null;
      in
        if t != null
        then t
        else "/var/lib/alloy/textfile";
      rawRev = config.system.configurationRevision or "unknown";
      deployRev =
        if rawRev == null || rawRev == ""
        then "unknown"
        else toString rawRev;

      storageScanScript = pkgs.writeShellApplication {
        name = "nixconf-storage-tree-scan";
        runtimeInputs = [pkgs.coreutils pkgs.jq pkgs.util-linux];
        meta.description = "Scan local service state, cache, home, and system directory sizes for the Storage Atlas treemap.";
        text = ''
          textfile_dir=${lib.escapeShellArg textfileDir}
          mkdir -p "$textfile_dir"
          tmp_file="$(mktemp "$textfile_dir/.storage_tree.XXXXXX")"
          rows_file="$(mktemp)"
          trap 'rm -f "$tmp_file" "$rows_file"' EXIT

          # Minimum size threshold in bytes (1 MiB) to keep metric cardinality bounded.
          min_bytes=1048576

          emit_row() {
            local bytes="$1"
            local cat="$2"
            local svc="$3"
            local path="$4"
            local parent="$5"
            local depth="$6"
            if [ "$bytes" -lt "$min_bytes" ]; then
              return 0
            fi
            printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$bytes" "$cat" "$svc" "$path" "$parent" "$depth" >> "$rows_file"
          }

          scan_root_children() {
            local base_dir="$1"
            local cat="$2"
            local svc_prefix="$3"
            local child_min="$4"
            [ -d "$base_dir" ] || return 0
            for d1 in "$base_dir"/*; do
              [ -d "$d1" ] || continue
              [ -L "$d1" ] && continue
              local name bytes
              name="$(basename "$d1")"
              bytes="$(du -B1 -s -x "$d1" 2>/dev/null | cut -f1 || echo 0)"
              [ -n "$bytes" ] || bytes=0
              if [ "$bytes" -lt "$min_bytes" ]; then
                continue
              fi
              local svc="''${svc_prefix}''${name}"
              emit_row "$bytes" "$cat" "$svc" "$d1" "$base_dir" "1"
              # Scan depth-2 subdirectories for sufficiently large directories, capped at top 10 per parent so one cache tree never crowds out other services.
              if [ "$bytes" -ge "$child_min" ]; then
                local sub_tmp
                sub_tmp="$(mktemp)"
                for d2 in "$d1"/*; do
                  [ -d "$d2" ] || continue
                  [ -L "$d2" ] && continue
                  local b2
                  b2="$(du -B1 -s -x "$d2" 2>/dev/null | cut -f1 || echo 0)"
                  [ -n "$b2" ] || b2=0
                  if [ "$b2" -ge "$child_min" ]; then
                    printf '%s\t%s\n' "$b2" "$d2" >> "$sub_tmp"
                  fi
                done
                if [ -s "$sub_tmp" ]; then
                  sort -t $'\t' -k1,1nr "$sub_tmp" | head -n 10 | while IFS=$'\t' read -r sb sp; do
                    emit_row "$sb" "$cat" "$svc" "$sp" "$d1" "2"
                  done
                fi
                rm -f "$sub_tmp"
              fi
            done
          }

          scan_single() {
            local target="$1"
            local cat="$2"
            local svc="$3"
            local parent="$4"
            [ -e "$target" ] || return 0
            local bytes
            bytes="$(du -B1 -s -x "$target" 2>/dev/null | cut -f1 || echo 0)"
            [ -n "$bytes" ] || bytes=0
            emit_row "$bytes" "$cat" "$svc" "$target" "$parent" "1"
          }

          scan_root_children "/var/lib" "service_state" "" 5242880
          scan_root_children "/var/cache" "service_cache" "" 5242880
          scan_root_children "/home" "home" "home:" 10485760

          if [ -d "/var/log" ]; then
            log_bytes="$(du -B1 -s -x /var/log 2>/dev/null | cut -f1 || echo 0)"
            emit_row "''${log_bytes:-0}" "logs" "logs" "/var/log" "/var" "1"
            for ld in /var/log/*; do
              [ -d "$ld" ] || continue
              [ -L "$ld" ] && continue
              lb="$(du -B1 -s -x "$ld" 2>/dev/null | cut -f1 || echo 0)"
              [ -n "$lb" ] || lb=0
              if [ "$lb" -ge 5242880 ]; then
                emit_row "$lb" "logs" "logs" "$ld" "/var/log" "2"
              fi
            done
          fi

          scan_single "/nix/store" "system" "nix-store" "/nix"
          scan_single "/boot" "system" "boot" "/"
          scan_single "/tmp" "system" "tmp" "/"
          scan_single "/root" "system" "root" "/"

          # Capture unmounted reserved volume files (e.g. emergency-headroom.img) without double-counting mounted loopbacks.
          if [ -d "/persist/.volumes" ]; then
            for img in /persist/.volumes/*.img; do
              [ -f "$img" ] || continue
              if losetup -j "$img" 2>/dev/null | grep -q .; then
                continue
              fi
              img_bytes="$(du -B1 -s "$img" 2>/dev/null | cut -f1 || echo 0)"
              img_name="$(basename "$img" .img)"
              emit_row "''${img_bytes:-0}" "reserved" "$img_name" "$img" "/persist/.volumes" "1"
            done
          fi

          now="$(date +%s)"
          {
            printf '# HELP nixconf_storage_dir_bytes Measured local directory size in bytes for Storage Atlas treemap.\n'
            printf '# TYPE nixconf_storage_dir_bytes gauge\n'
            if [ -s "$rows_file" ]; then
              # Cap at top 140 paths by size to keep time-series cardinality small and predictable.
              sort -t $'\t' -k1,1nr "$rows_file" | head -n 140 | while IFS=$'\t' read -r b cat svc path parent depth; do
                printf 'nixconf_storage_dir_bytes{category=%s,service=%s,path=%s,parent=%s,depth=%s} %s\n' \
                  "$(jq -Rn --arg v "$cat" '$v')" \
                  "$(jq -Rn --arg v "$svc" '$v')" \
                  "$(jq -Rn --arg v "$path" '$v')" \
                  "$(jq -Rn --arg v "$parent" '$v')" \
                  "$(jq -Rn --arg v "$depth" '$v')" \
                  "$b"
              done
            fi
            printf '# HELP nixconf_storage_scan_timestamp_seconds Unix epoch timestamp of the latest local storage directory scan.\n'
            printf '# TYPE nixconf_storage_scan_timestamp_seconds gauge\n'
            printf 'nixconf_storage_scan_timestamp_seconds %s\n' "$now"
          } > "$tmp_file"

          chmod 0644 "$tmp_file"
          mv -f "$tmp_file" "$textfile_dir/storage_tree.prom"
          rm -f "$rows_file"
          trap - EXIT
        '';
      };
    in {
      _file = "modules/hosts/${name}.nix, via option host.${name}.configuration";
      key = "primitives-host-monitoring-${name}";

      config = lib.mkIf (config.monitoring.enable or false) {
        monitoring = {
          exporters = {
            process.enable = lib.mkDefault true;
            unix = {
              enable = true;
              textfileDirectory = lib.mkDefault "/var/lib/alloy/textfile";
              collectors = [
                "cpu"
                "cpufreq"
                "hwmon"
                "meminfo"
                "loadavg"
                "netdev"
                "sockstat"
                "systemd"
                "textfile"
                "uname"
                "vmstat"
                "time"
                "processes"
                "boottime"
                "stat"
              ];
            };
          };

          logs.journal.enable = true;

          extraGrafanaSettings.users.home_page = lib.mkDefault "/d/nixconf-fleet-overview";

          rules = {
            host = {
              backend = "metrics";
              interval = "1m";
              rules = [
                {
                  alert = "SystemdUnitFailed";
                  expr = ''node_systemd_unit_state{state="failed"} == 1'';
                  "for" = "2m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Systemd unit {{ $labels.name }} failed on {{ $labels.host }}";
                    description = "Unit {{ $labels.name }} on {{ $labels.host }} has been in failed state for more than 2 minutes.";
                  };
                }
                {
                  alert = "HostHighMemoryUsage";
                  expr = ''((node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / clamp_min(node_memory_MemTotal_bytes, 1)) * 100 > 90'';
                  "for" = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "High memory usage on {{ $labels.host }}";
                    description = "Memory utilization on {{ $labels.host }} is above 90%.";
                  };
                }
                {
                  alert = "HostHighCpuLoad";
                  expr = ''node_load5 / count without (cpu, mode) (node_cpu_seconds_total{mode="idle"}) > 2'';
                  "for" = "10m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "High 5m load average on {{ $labels.host }}";
                    description = "5-minute load per CPU core exceeded 2.0 on {{ $labels.host }}.";
                  };
                }
              ];
            };

            operations-recording = {
              backend = "logs";
              interval = "5m";
              rules = let
                opsBase = ''_time:5m job:="systemd-journal" "Consumed" "CPU time" | ${d.systemdOpsParsePipe}'';
              in [
                {
                  record = "nixconf_operation_runs_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) count() as value'';
                }
                {
                  record = "nixconf_operation_cpu_seconds_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(cpu_s) as value'';
                }
                {
                  record = "nixconf_operation_wall_seconds_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(wall_s) as value'';
                }
                {
                  record = "nixconf_operation_memory_peak_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) max(mem_peak_bytes) as value'';
                }
                {
                  record = "nixconf_operation_io_read_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(io_read_bytes) as value'';
                }
                {
                  record = "nixconf_operation_io_write_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(io_write_bytes) as value'';
                }
              ];
            };
          };

          dashboards = let
            hasContainers =
              (config.virtualisation.docker.enable or false)
              || (config.virtualisation.podman.enable or false)
              || ((config.virtualisation.oci-containers.containers or {}) != {});
          in {
            fleet-overview = {
              title = "Fleet Command Center";
              folder = "00 · Overview";
              json = d.mkFleetOverviewDashboard {};
            };
            task-manager = {
              title = "Task Manager";
              folder = "01 · Investigate";
              json = d.mkTaskManagerDashboard {};
            };
            time-machine = {
              title = "Incident Time Machine";
              folder = "01 · Investigate";
              json = d.mkTimeMachineDashboard {};
            };
            trends-explorer = {
              title = "Trends, Cycles & Metric Explorer";
              folder = "01 · Investigate";
              json = d.mkTrendsExplorerDashboard {};
            };
            metric-workbench = {
              title = "Metric Workbench";
              folder = "01 · Investigate";
              json = d.mkMetricWorkbenchDashboard {};
            };
            logs-explorer = {
              title = "Logs Explorer";
              folder = "01 · Investigate";
              json = d.mkLogsExplorerDashboard {};
            };
            host-hardware = {
              title = "Host & Hardware";
              folder = "02 · Infrastructure";
              json = d.mkHostHardwareDashboard {};
            };
            capacity-analytics = {
              title = "Capacity, Right-Sizing & Operations";
              folder = "02 · Infrastructure";
              json = d.mkCapacityAnalyticsDashboard {};
            };
            storage-atlas = {
              title = "Storage Atlas (Treemap)";
              folder = "02 · Infrastructure";
              json = d.mkStorageAtlasDashboard {};
            };
            services-catalog = lib.mkIf (config.monitoring.services != {}) {
              title = "Services Catalog";
              folder = "03 · Services";
              json = d.mkServicesCatalogDashboard {};
            };
            service-inspector = lib.mkIf (config.monitoring.services != {}) {
              title = "Service Inspector";
              folder = "03 · Services";
              json = d.mkServiceInspectorDashboard {};
            };
            containers = lib.mkIf hasContainers {
              title = "Containers & OCI";
              folder = "03 · Services";
              json = d.mkContainersDashboard {};
            };
          };
        };

        systemd.services.nixconf-storage-scan = {
          description = "Periodic local directory and service storage scan for Storage Atlas";
          after = ["local-fs.target" "systemd-tmpfiles-setup.service"];
          serviceConfig = {
            Type = "oneshot";
            Nice = 19;
            IOSchedulingClass = "idle";
            CPUSchedulingPolicy = "idle";
            ExecStart = lib.getExe storageScanScript;
          };
        };

        systemd.timers.nixconf-storage-scan = {
          description = "Hourly local storage tree scan timer";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "1m";
            OnUnitActiveSec = "1h";
            RandomizedDelaySec = "2m";
            Persistent = true;
          };
        };

        resources.units = lib.mkIf (config.resources.enable or false) {
          "nixconf-storage-scan.service" = {
            tier = "background";
            deferOnBattery = true;
          };
        };

        system.activationScripts.nixconf-deployment-metric = ''
          install -d -m 0755 ${lib.escapeShellArg textfileDir}
          tmp_prom="$(mktemp ${lib.escapeShellArg "${textfileDir}/.deployment.XXXXXX"})"
          now_ts="$(date +%s)"
          cat > "$tmp_prom" <<'EOF'
          # HELP nixconf_deployment_info Static label metadata identifying the active NixOS revision.
          # TYPE nixconf_deployment_info gauge
          EOF
          printf 'nixconf_deployment_info{rev=%s} 1\n' ${lib.escapeShellArg (builtins.toJSON deployRev)} >> "$tmp_prom"
          cat >> "$tmp_prom" <<'EOF'
          # HELP nixconf_deployment_timestamp_seconds Unix epoch timestamp of the latest NixOS activation.
          # TYPE nixconf_deployment_timestamp_seconds gauge
          EOF
          printf 'nixconf_deployment_timestamp_seconds{rev=%s} %s\n' ${lib.escapeShellArg (builtins.toJSON deployRev)} "$now_ts" >> "$tmp_prom"
          chmod 0644 "$tmp_prom"
          mv -f "$tmp_prom" ${lib.escapeShellArg "${textfileDir}/deployment.prom"}
        '';
      };
    };
  };
}
