# Host monitoring module: baseline OS/process metrics, deployment annotations, systemd journal streaming, host alert rules, and core dashboards.
{...}: {
  _module.args = {
    hostMonitoringModule = {name}: {
      config,
      lib,
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
                  expr = ''${opsBase} | stats by (host, op_unit) count()'';
                }
                {
                  record = "nixconf_operation_cpu_seconds_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(cpu_s)'';
                }
                {
                  record = "nixconf_operation_wall_seconds_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(wall_s)'';
                }
                {
                  record = "nixconf_operation_memory_peak_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) max(mem_peak_bytes)'';
                }
                {
                  record = "nixconf_operation_io_read_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(io_read_bytes)'';
                }
                {
                  record = "nixconf_operation_io_write_bytes_5m";
                  expr = ''${opsBase} | stats by (host, op_unit) sum(io_write_bytes)'';
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
