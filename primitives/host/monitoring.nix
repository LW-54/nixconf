# Host monitoring module: baseline OS metrics, systemd journal streaming, host alert rules, and overview dashboards.
{
  mkHostOverviewDashboard,
  mkLogsExplorerDashboard,
  ...
}: {
  _module.args = {
    hostMonitoringModule = {name}: {
      config,
      lib,
      self,
      ...
    }: let
      d = self.lib.monitoring.dashboard;
    in {
      _file = "modules/hosts/${name}.nix, via option host.${name}.configuration";
      key = "primitives-host-monitoring-${name}";

      config = lib.mkIf (config.monitoring.enable or false) {
        monitoring = {
          exporters.unix = {
            enable = true;
            collectors = [
              "cpu"
              "meminfo"
              "loadavg"
              "netdev"
              "systemd"
              "uname"
              "vmstat"
              "time"
              "processes"
              "boottime"
              "stat"
            ];
          };

          logs.journal.enable = true;

          extraGrafanaSettings.users.home_page = lib.mkDefault "/d/nixconf-host-overview";

          rules.host = {
            backend = "prometheus";
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
                expr = ''(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90'';
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

          dashboards = {
            host-overview = {
              title = "Host & Systemd Overview";
              folder = "Infrastructure";
              json = mkHostOverviewDashboard d;
            };
            logs-explorer = {
              title = "Logs Explorer";
              folder = "Infrastructure";
              json = mkLogsExplorerDashboard d;
            };
            service-inspector = lib.mkIf (config.monitoring.services != {}) {
              title = "Service Inspector";
              folder = "Services";
              json = d.mkServiceInspectorDashboard {};
            };
          };
        };
      };
    };
  };
}
