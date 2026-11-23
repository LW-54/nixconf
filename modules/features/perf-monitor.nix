{self, ...}: {
  feature.perf-monitor = {
    description = "Continuous Nixconf CI, Nix evaluation, binary cache latency, and cache-isolation monitoring exported to VictoriaMetrics and Grafana.";

    modules = {
      perf-monitor = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.nixconf-perf-monitor;
        isTest = config.testing.enable or false;
        textfileDir = config.monitoring.exporters.unix.textfileDirectory or "/var/lib/alloy/textfile";
        profPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.prof;
        atticCfg =
          self.lib.attic.cacheConfig
          or {
            endpoint = "https://cache.adje.app";
            cache = "nixconf";
          };
        atticCacheUrl = "${atticCfg.endpoint}/${atticCfg.cache}";

        mkDashboard = d:
          d.mkDashboard {
            uid = "nixconf-perf-ci";
            title = "Nixconf CI & Eval Performance";
            description = "Tracks GitHub Actions workflow/job durations, runner minutes, local uncached Nix evaluation speed & memory, derivation cache isolation, and Attic/Cachix binary cache latency & disk usage.";
            tags = ["nixconf" "ci" "nix" "attic" "performance"];
            sections = [
              (d.mkRow [
                (d.mkStat {
                  title = "CI Build Wall Time";
                  w = 4;
                  unit = "s";
                  decimals = 0;
                  colorMode = "background";
                  thresholds = [
                    {
                      color = "green";
                      value = null;
                    }
                    {
                      color = "yellow";
                      value = 90;
                    }
                    {
                      color = "red";
                      value = 150;
                    }
                  ];
                  expr = ''nixconf_ci_workflow_wall_seconds{workflow="CI & Binary Cache Push"}'';
                  legend = "Wall";
                })
                (d.mkStat {
                  title = "CI Runner Time";
                  w = 4;
                  unit = "s";
                  decimals = 0;
                  graphMode = "area";
                  expr = ''nixconf_ci_workflow_runner_seconds{workflow="CI & Binary Cache Push"}'';
                  legend = "Runner";
                })
                (d.mkStat {
                  title = "Host VM Tests Wall";
                  w = 4;
                  unit = "s";
                  decimals = 0;
                  graphMode = "area";
                  expr = ''nixconf_ci_workflow_wall_seconds{workflow="Host Verification & VM Tests"}'';
                  legend = "VM Wall";
                })
                (d.mkStat {
                  title = "Attic Latency";
                  w = 4;
                  unit = "s";
                  decimals = 3;
                  graphMode = "area";
                  expr = ''nixconf_cache_probe_latency_seconds{cache="attic"}'';
                  legend = "Attic";
                })
                (d.mkStat {
                  title = "Attic Disk Used";
                  w = 4;
                  unit = "bytes";
                  decimals = 1;
                  graphMode = "area";
                  expr = ''nixconf_attic_storage_bytes'';
                  legend = "Attic";
                })
                (d.mkStat {
                  title = "Cache Isolation Leaks";
                  w = 4;
                  decimals = 0;
                  colorMode = "background";
                  noValue = "0";
                  thresholds = d.thresholds.zeroOk;
                  expr = ''nixconf_cache_invalidated_non_docs_drvs{mutation="readme"}'';
                  legend = "Leaks";
                })
              ])
              (d.mkSection {
                title = "GitHub Actions CI Performance";
                rows = [
                  [
                    (d.mkTimeseries {
                      title = "Workflow Wall-Clock Duration";
                      w = 12;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_ci_workflow_wall_seconds'';
                      legend = "{{workflow}}";
                    })
                    (d.mkTimeseries {
                      title = "Cumulative Runner Time";
                      w = 12;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_ci_workflow_runner_seconds'';
                      legend = "{{workflow}}";
                    })
                  ]
                  [
                    (d.mkTimeseries {
                      title = "Per-Job Duration";
                      w = 14;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_ci_job_duration_seconds'';
                      legend = "{{job}}";
                    })
                    (d.mkTimeseries {
                      title = "Per-Job Work Duration (Excl. Setup)";
                      w = 10;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_ci_job_work_seconds'';
                      legend = "{{job}}";
                    })
                  ]
                ];
              })
              (d.mkSection {
                title = "Local Nix Evaluation & Binary Cache Health";
                rows = [
                  [
                    (d.mkTimeseries {
                      title = "Uncached Nix Eval Wall Time";
                      w = 12;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_eval_wall_seconds'';
                      legend = "{{target}}";
                    })
                    (d.mkTimeseries {
                      title = "Nix Evaluator Memory Allocated";
                      w = 12;
                      h = 8;
                      unit = "bytes";
                      expr = ''nixconf_eval_alloc_bytes'';
                      legend = "{{target}}";
                    })
                  ]
                  [
                    (d.mkTimeseries {
                      title = "Binary Cache Probe Latency";
                      w = 12;
                      h = 8;
                      unit = "s";
                      expr = ''nixconf_cache_probe_latency_seconds'';
                      legend = "{{cache}}";
                    })
                    (d.mkTimeseries {
                      title = "Attic Cache Storage Growth";
                      w = 12;
                      h = 8;
                      unit = "bytes";
                      expr = ''nixconf_attic_storage_bytes'';
                      legend = "Attic Storage";
                    })
                  ]
                ];
              })
            ];
          };
      in {
        options.services.nixconf-perf-monitor = {
          enable = lib.mkEnableOption "Continuous Nixconf CI and Nix eval performance exporter" // {default = true;};

          repo = lib.mkOption {
            type = lib.types.str;
            default = "LW-54/nixconf";
            description = "GitHub repository slug (owner/repo) polled for CI workflow metrics.";
          };

          repoDir = lib.mkOption {
            type = lib.types.str;
            default = "/home/lw/nixconf";
            description = "Local git checkout path used by the daily Nix evaluation benchmark.";
          };

          evalUser = lib.mkOption {
            type = lib.types.str;
            default = "lw";
            description = "Local user account used to execute the daily Nix evaluation benchmark.";
          };

          atticDir = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/atticd";
            description = "Local Attic storage directory measured for cache disk usage.";
          };

          ciInterval = lib.mkOption {
            type = lib.types.str;
            default = "30min";
            description = "Interval between GitHub Actions CI & binary cache telemetry polls.";
          };

          evalCalendar = lib.mkOption {
            type = lib.types.str;
            default = "*-*-* 04:15:00";
            description = "systemd OnCalendar schedule for daily uncached Nix eval & cache-isolation benchmarks.";
          };
        };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            systemd.services.nixconf-ci-metrics = {
              description = "Export GitHub Actions CI, binary cache latency, and Attic storage metrics for Alloy";
              after = ["network-online.target"];
              wants = ["network-online.target"];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = lib.concatStringsSep " " [
                  "${profPkg}/bin/nixprof"
                  "metrics"
                  "--ci"
                  "--repo"
                  (lib.escapeShellArg cfg.repo)
                  "--attic-url"
                  (lib.escapeShellArg atticCacheUrl)
                  "--attic-dir"
                  (lib.escapeShellArg cfg.atticDir)
                  "--out"
                  (lib.escapeShellArg "${textfileDir}/nixconf_ci.prom")
                ];
              };
            };

            systemd.timers.nixconf-ci-metrics = {
              description = "Periodic GitHub Actions CI & Attic cache metrics poll";
              wantedBy = lib.optionals (!isTest) ["timers.target"];
              timerConfig = {
                OnBootSec = "3min";
                OnUnitActiveSec = cfg.ciInterval;
                RandomizedDelaySec = "2min";
                Persistent = true;
              };
            };

            systemd.services.nixconf-eval-metrics = {
              description = "Run daily uncached Nix eval & cache-isolation benchmark for Alloy";
              after = ["nix-daemon.service" "local-fs.target"];
              path = [pkgs.nix pkgs.git pkgs.coreutils pkgs.util-linux];
              serviceConfig = {
                Type = "oneshot";
                Nice = 19;
                IOSchedulingClass = "idle";
              };
              script = ''
                set -euo pipefail
                if [ ! -f ${lib.escapeShellArg "${cfg.repoDir}/flake.nix"} ]; then
                  echo "Skipping eval metrics: ${cfg.repoDir}/flake.nix not found."
                  exit 0
                fi
                tmp_prom="$(mktemp /tmp/nixconf-eval-metrics.XXXXXX.prom)"
                trap 'rm -f "$tmp_prom"' EXIT
                chown ${lib.escapeShellArg cfg.evalUser} "$tmp_prom"
                runuser -u ${lib.escapeShellArg cfg.evalUser} -- \
                  ${profPkg}/bin/nixprof metrics --eval \
                  --repo-dir ${lib.escapeShellArg cfg.repoDir} \
                  --out "$tmp_prom"
                install -m 0644 "$tmp_prom" ${lib.escapeShellArg "${textfileDir}/nixconf_eval.prom"}
              '';
            };

            systemd.timers.nixconf-eval-metrics = {
              description = "Daily Nix evaluation & cache-isolation regression benchmark";
              wantedBy = lib.optionals (!isTest) ["timers.target"];
              timerConfig = {
                OnCalendar = cfg.evalCalendar;
                RandomizedDelaySec = "15min";
                Persistent = true;
              };
            };

            monitoring = lib.mkIf (config.monitoring.enable or false) {
              exporters.unix.textfileDirectory = lib.mkDefault "/var/lib/alloy/textfile";
              watchedUnits = ["nixconf-ci-metrics.service" "nixconf-eval-metrics.service"];
              rules.nixconf-perf = {
                interval = "5m";
                rules = [
                  {
                    alert = "NixconfCacheIsolationLeak";
                    expr = ''nixconf_cache_invalidated_non_docs_drvs{mutation="readme"} > 0'';
                    "for" = "5m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Nixconf derivation cache isolation broken ({{ $value }} leaked drvs)";
                      description = "Editing README.md invalidated {{ $value }} non-docs derivations. Check for accidental \${self} interpolations with `just prof-cache README.md`.";
                    };
                  }
                  {
                    alert = "NixconfCiWorkflowSlow";
                    expr = ''nixconf_ci_workflow_wall_seconds{workflow="CI & Binary Cache Push"} > 150'';
                    "for" = "2h";
                    labels.severity = "warning";
                    annotations = {
                      summary = "GitHub Actions CI & Binary Cache Push slowed to {{ $value | humanizeDuration }}";
                      description = "Latest CI & Binary Cache Push wall time exceeded 150s (baseline target: ~50s). Inspect with `just prof-ci`.";
                    };
                  }
                  {
                    alert = "NixconfCiWorkflowFailed";
                    expr = ''nixconf_ci_workflow_success == 0'';
                    "for" = "1h";
                    labels.severity = "warning";
                    annotations = {
                      summary = "GitHub Actions workflow {{ $labels.workflow }} failed";
                      description = "Latest completed run of {{ $labels.workflow }} did not succeed. Run `just prof-ci` to inspect failed jobs and steps.";
                    };
                  }
                  {
                    alert = "NixconfAtticCacheUnreachable";
                    expr = ''nixconf_cache_probe_up{cache="attic"} == 0'';
                    "for" = "15m";
                    labels.severity = "critical";
                    annotations = {
                      summary = "Self-hosted Attic binary cache is unreachable";
                      description = "Probe to ${atticCacheUrl}/nix-cache-info failed for 15 minutes.";
                    };
                  }
                  {
                    alert = "NixconfEvalSlow";
                    expr = ''nixconf_eval_wall_seconds{target="packages.docs"} > 20'';
                    "for" = "24h";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Nixconf docs evaluation regressed to {{ $value | humanizeDuration }}";
                      description = "Uncached packages.docs evaluation exceeded 20s (baseline target: ~10s). Profile with `just prof nix build --no-link .#docs`.";
                    };
                  }
                ];
              };
              dashboards.nixconf-perf = {
                title = "Nixconf CI & Eval Performance";
                folder = "02 · Infrastructure";
                json = mkDashboard self.lib.monitoring.dashboard;
              };
            };

            resources.units = lib.mkIf (config.resources.enable or false) {
              "nixconf-ci-metrics.service".tier = lib.mkDefault "background";
              "nixconf-eval-metrics.service".tier = lib.mkDefault "background";
            };

            testing.perf-monitor = {
              description = "Nixconf CI and Nix eval performance exporter and dashboard checks";

              evalChecks.has-repo = {
                assertion = cfg.repo != "";
                message = "`services.nixconf-perf-monitor.repo` must be non-empty.";
              };

              inspectChecks.timers = {
                description = "Verify nixconf-ci-metrics and nixconf-eval-metrics systemd units exist";
                priority = 230;
                script = ''
                  ${self.lib.testing.mkInspectFile {
                    path = "$etc/systemd/system/nixconf-ci-metrics.service";
                    pattern = "nixprof";
                  }}
                  ${self.lib.testing.mkInspectFile {
                    path = "$etc/systemd/system/nixconf-eval-metrics.service";
                    pattern = "nixconf-eval-metrics-start";
                  }}
                  ${self.lib.testing.mkInspectFile {
                    path = "$etc/systemd/system/nixconf-ci-metrics.timer";
                    pattern = "OnUnitActiveSec";
                  }}
                  ${self.lib.testing.mkInspectFile {
                    path = "$etc/systemd/system/nixconf-eval-metrics.timer";
                    pattern = "OnCalendar";
                  }}
                '';
              };
            };
          }
        ]);
      };
    };
  };
}
