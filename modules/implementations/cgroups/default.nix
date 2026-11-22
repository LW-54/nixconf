{
  config,
  lib,
  ...
}: let
  helpers = config.internal.cgroups;
in {
  options.internal.cgroups = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal builder helpers for systemd cgroups v2 slices, power policy, volumes, dashboards, and tests.";
  };

  /**
  Systemd cgroups v2 workload tiers, OOM ordering, battery throttling, local volumes, and monitoring integration.
  */
  config.implementation.cgroups = {
    contract = "resources";
    description = "Systemd control groups v2 tiering, OOM ordering, power policy, local disk volumes, and remote storage budget implementation.";

    module = {
      config,
      lib,
      pkgs,
      options,
      utils,
      self,
      ...
    }: let
      cfg = config.resources;
      resHelpers = self.lib.resources;
      inherit (resHelpers) profiles sliceName toBytes;

      builtinSlices = ["-" "system" "user" "machine"];

      filterNulls = lib.filterAttrs (_: v: v != null);

      formatCores = cores:
        if cores == null
        then null
        else if builtins.isList cores
        then lib.concatMapStringsSep "," toString cores
        else cores;

      mkDefaultLeaves = attrs:
        lib.mapAttrs (
          _: v:
            if builtins.isAttrs v && !lib.isDerivation v && !(v ? _type)
            then mkDefaultLeaves v
            else lib.mkDefault v
        )
        attrs;

      renderIniSection = sectionName: attrs: let
        lines = lib.concatLists (lib.mapAttrsToList (
            k: v:
              if builtins.isList v
              then map (item: "${k}=${toString item}") v
              else ["${k}=${toString v}"]
          )
          attrs);
      in
        lib.optionalString (attrs != {}) ''
          [${sectionName}]
          ${lib.concatStringsSep "\n" lines}
        '';

      enabledUnits = lib.filterAttrs (_: u: u.enable) cfg.units;
      serviceUnits = lib.filterAttrs (n: _: lib.hasSuffix ".service" n) enabledUnits;
      otherUnits = lib.filterAttrs (n: _: !(lib.hasSuffix ".service" n)) enabledUnits;

      mkUnitDirectives = u: let
        tierCfg = cfg.tiers.${u.tier} or {};
        tierOomScore = tierCfg.oom.scoreAdjust or null;
        tierOomPref = tierCfg.oom.preference or null;
      in
        filterNulls {
          Slice = sliceName u.tier;
          CPUWeight = u.cpu.weight;
          CPUQuota = u.cpu.quota;
          AllowedCPUs = formatCores u.cpu.cores;
          MemoryMin = u.memory.min;
          MemoryLow = u.memory.low;
          MemoryHigh = u.memory.high;
          MemoryMax = u.memory.max;
          MemorySwapMax = u.memory.swapMax;
          IOWeight = u.io.weight;
          IOReadBandwidthMax = u.io.readMax;
          IOWriteBandwidthMax = u.io.writeMax;
          TasksMax = u.tasksMax;
          ManagedOOMPreference =
            if u.oom.preference != null
            then u.oom.preference
            else if tierOomPref != null && tierOomPref != "none"
            then tierOomPref
            else null;
          OOMScoreAdjust =
            if u.oom.scoreAdjust != null
            then u.oom.scoreAdjust
            else tierOomScore;
        };

      usesIoWeights =
        lib.any (t: (t.io.weight or null) != null) (builtins.attrValues cfg.tiers)
        || lib.any (u: (u.io.weight or null) != null) (builtins.attrValues enabledUnits);

      powerCfg = helpers.mkPower {
        inherit cfg lib pkgs sliceName;
      };

      volumesCfg = helpers.mkVolumes {
        inherit self config cfg lib pkgs options utils toBytes filterNulls;
      };

      testingSuite = helpers.mkTesting {
        inherit self config cfg lib utils;
        inherit (profiles.${cfg.profile}) background;
        sliceNameFn = sliceName;
      };

      monEnabled = config.monitoring.enable or false;
      hasStorageBudgets = (lib.filterAttrs (_: b: b.enable) cfg.storageBudgets) != {};
    in
      lib.mkMerge [
        {
          resources = {
            tiers = mkDefaultLeaves (profiles.${cfg.profile} or {});
            power.enable = lib.mkDefault (cfg.profile == "workstation");
            disk = {
              journalMaxSize = lib.mkDefault "512M";
              journalKeepFree = lib.mkDefault "1G";
              nixMinFree = lib.mkDefault "1G";
              nixMaxFree = lib.mkDefault "4G";
            };
          };

          systemd = {
            oomd = {
              enable = lib.mkIf cfg.oom.enable (lib.mkDefault true);
              settings.OOM = lib.mkIf cfg.oom.enable (filterNulls {
                SwapUsedLimit = cfg.oom.swapUsedLimit;
                DefaultMemoryPressureDurationSec = cfg.oom.defaultPressureDuration;
              });
            };

            slices = lib.mkMerge [
              (lib.mapAttrs (name: t: let
                isBuiltin = builtins.elem name builtinSlices;
                oomKill = cfg.oom.enable && (t.oom.kill == true);
              in
                (lib.optionalAttrs (!isBuiltin) {
                  inherit (t) description;
                })
                // {
                  sliceConfig = filterNulls {
                    CPUWeight = t.cpu.weight;
                    CPUQuota = t.cpu.quota;
                    AllowedCPUs = formatCores t.cpu.cores;
                    MemoryMin = t.memory.min;
                    MemoryLow = t.memory.low;
                    MemoryHigh = t.memory.high;
                    MemoryMax = t.memory.max;
                    MemorySwapMax = t.memory.swapMax;
                    IOWeight = t.io.weight;
                    IOReadBandwidthMax = t.io.readMax;
                    IOWriteBandwidthMax = t.io.writeMax;
                    TasksMax = t.tasksMax;
                    ManagedOOMPreference = t.oom.preference;
                    ManagedOOMMemoryPressure =
                      if oomKill
                      then "kill"
                      else null;
                    ManagedOOMMemoryPressureLimit =
                      if oomKill
                      then t.oom.pressureLimit
                      else null;
                  };
                })
              cfg.tiers)
              (lib.mkIf (cfg.oom.enable && cfg.oom.swapKill) {
                "-".sliceConfig.ManagedOOMSwap = "kill";
              })
            ];

            services = lib.mapAttrs' (uName: u: let
              stem = lib.removeSuffix ".service" uName;
              tierCfg = cfg.tiers.${u.tier} or {};
              tierOomScore = tierCfg.oom.scoreAdjust or null;
              tierOomPref = tierCfg.oom.preference or null;
              baseCfg = filterNulls {
                Slice = sliceName u.tier;
                CPUWeight = u.cpu.weight;
                CPUQuota = u.cpu.quota;
                AllowedCPUs = formatCores u.cpu.cores;
                MemoryMin = u.memory.min;
                MemoryLow = u.memory.low;
                MemoryHigh = u.memory.high;
                MemoryMax = u.memory.max;
                MemorySwapMax = u.memory.swapMax;
                IOWeight = u.io.weight;
                IOReadBandwidthMax = u.io.readMax;
                IOWriteBandwidthMax = u.io.writeMax;
                TasksMax = u.tasksMax;
              };
              oomScoreCfg =
                if u.oom.scoreAdjust != null
                then {OOMScoreAdjust = u.oom.scoreAdjust;}
                else if tierOomScore != null
                then {OOMScoreAdjust = lib.mkDefault tierOomScore;}
                else {};
              oomPrefCfg =
                if u.oom.preference != null
                then {ManagedOOMPreference = u.oom.preference;}
                else if tierOomPref != null && tierOomPref != "none"
                then {ManagedOOMPreference = lib.mkDefault tierOomPref;}
                else {};
              unitCfg = lib.optionalAttrs (cfg.power.enable && u.deferOnBattery) {
                ConditionACPower = true;
              };
            in
              lib.nameValuePair stem (
                {
                  serviceConfig = baseCfg // oomScoreCfg // oomPrefCfg;
                }
                // lib.optionalAttrs (unitCfg != {}) {
                  unitConfig = unitCfg;
                }
              ))
            serviceUnits;

            units = lib.mapAttrs' (uName: u: let
              sectionName =
                if lib.hasSuffix ".mount" uName
                then "Mount"
                else if lib.hasSuffix ".socket" uName
                then "Socket"
                else if lib.hasSuffix ".scope" uName
                then "Scope"
                else "Service";
              unitBlock =
                if cfg.power.enable && u.deferOnBattery
                then renderIniSection "Unit" {ConditionACPower = true;}
                else "";
              bodyBlock = renderIniSection sectionName (mkUnitDirectives u);
            in
              lib.nameValuePair "${uName}.d/50-resources.conf" {
                text = lib.concatStringsSep "\n" (lib.filter (s: s != "") [unitBlock bodyBlock]);
              })
            otherUnits;
          };

          boot.kernelModules = lib.mkIf usesIoWeights ["bfq"];

          services.udev.extraRules = lib.mkIf usesIoWeights ''
            ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="sd[a-z]*|vd[a-z]*|nvme[0-9]n[0-9]*", TEST=="queue/scheduler", ATTR{queue/scheduler}="bfq"
          '';

          monitoring = lib.mkIf monEnabled {
            exporters = {
              cadvisor.enable = true;
              unix = {
                collectors =
                  ["pressure" "textfile"]
                  ++ lib.optional cfg.power.enable "powersupplyclass";
                textfileDirectory = lib.mkDefault "/var/lib/alloy/textfile";
              };
            };

            watchedUnits =
              lib.optional cfg.oom.enable "systemd-oomd.service"
              ++ lib.optional (hasStorageBudgets && (config.storage.enable or false)) "resources-storage-budgets.timer";

            rules = {
              resources = {
                backend = "metrics";
                interval = "1m";
                rules = [
                  {
                    alert = "CgroupMemoryNearLimit";
                    expr = ''(container_memory_working_set_bytes{unit!=""} / (container_spec_memory_limit_bytes{unit!=""} > 0)) * 100 > 85'';
                    "for" = "5m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Cgroup {{ $labels.unit }} near memory limit on {{ $labels.host }}";
                      description = "Unit {{ $labels.unit }} in {{ $labels.slice }} slice has used more than 85% of its memory limit for 5 minutes.";
                    };
                  }
                  {
                    alert = "CgroupCpuThrottled";
                    expr = ''(rate(container_cpu_cfs_throttled_periods_total{unit!=""}[5m]) / clamp_min(rate(container_cpu_cfs_periods_total{unit!=""}[5m]), 1)) * 100 > 25'';
                    "for" = "10m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Cgroup {{ $labels.unit }} CPU-throttled on {{ $labels.host }}";
                      description = "Unit {{ $labels.unit }} experienced CPU CFS quota throttling on over 25% of periods for 10 minutes.";
                    };
                  }
                  {
                    alert = "HostMemoryPressureHigh";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total[5m]) * 100 > 10'';
                    "for" = "5m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Elevated Linux PSI memory pressure on {{ $labels.host }}";
                      description = "Memory PSI stall rate on {{ $labels.host }} exceeded 10% over 5 minutes.";
                    };
                  }
                  {
                    alert = "CgroupOomKilled";
                    expr = ''increase(container_oom_events_total{unit!=""}[5m]) > 0'';
                    "for" = null;
                    labels.severity = "critical";
                    annotations = {
                      summary = "Cgroup OOM event in {{ $labels.unit }} on {{ $labels.host }}";
                      description = "Kernel or cgroup OOM kill recorded for {{ $labels.unit }} on {{ $labels.host }}.";
                    };
                  }
                  {
                    alert = "LocalVolumeSpaceWarning";
                    expr = ''(((node_filesystem_avail_bytes / clamp_min(node_filesystem_size_bytes, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!="reserved-unmounted"} * 0 + 1)) < 20'';
                    "for" = "10m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Local volume {{ $labels.volume }} low on free space on {{ $labels.host }}";
                      description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}, {{ $labels.mode }}) has less than 20% free space remaining on {{ $labels.host }}.";
                    };
                  }
                  {
                    alert = "LocalVolumeSpaceCritical";
                    expr = ''(((node_filesystem_avail_bytes / clamp_min(node_filesystem_size_bytes, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!="reserved-unmounted"} * 0 + 1)) < 10'';
                    "for" = "5m";
                    labels.severity = "critical";
                    annotations = {
                      summary = "Local volume {{ $labels.volume }} critically full on {{ $labels.host }}";
                      description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}, {{ $labels.mode }}) has less than 10% free space remaining on {{ $labels.host }}.";
                    };
                  }
                  {
                    alert = "LocalVolumeInodesLow";
                    expr = ''(((node_filesystem_files_free / clamp_min(node_filesystem_files, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!="reserved-unmounted"} * 0 + 1)) < 15'';
                    "for" = "10m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Local volume {{ $labels.volume }} low on free inodes on {{ $labels.host }}";
                      description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}) has less than 15% free inodes remaining on {{ $labels.host }}.";
                    };
                  }
                  {
                    alert = "RemoteStorageBudgetWarning";
                    expr = ''(nixconf_storage_budget_used_bytes / clamp_min(nixconf_storage_budget_limit_bytes, 1)) * 100 > nixconf_storage_budget_warn_percent'';
                    "for" = "15m";
                    labels.severity = "warning";
                    annotations = {
                      summary = "Remote storage slice {{ $labels.slice }} approaching budget on {{ $labels.host }}";
                      description = "Storage slice {{ $labels.slice }} exceeded its warning percentage threshold.";
                    };
                  }
                  {
                    alert = "RemoteStorageBudgetExceeded";
                    expr = ''nixconf_storage_budget_used_bytes >= nixconf_storage_budget_limit_bytes'';
                    "for" = "5m";
                    labels.severity = "critical";
                    annotations = {
                      summary = "Remote storage slice {{ $labels.slice }} exceeded budget on {{ $labels.host }}";
                      description = "Storage slice {{ $labels.slice }} usage is at or above its configured maxSize budget.";
                    };
                  }
                ];
              };

              resources-logs = {
                backend = "logs";
                interval = "1m";
                rules = [
                  {
                    alert = "OomKillDetected";
                    expr = ''_time:5m job:="systemd-journal" _msg:~"(?i)(Out of memory: Killed process|systemd-oomd.*Killed)" | stats by (host) count() as kills | filter kills:>0'';
                    "for" = null;
                    labels.severity = "critical";
                    annotations = {
                      summary = "OOM kill detected in journal on {{ $labels.host }}";
                      description = "Kernel OOM killer or systemd-oomd terminated a process on {{ $labels.host }}.";
                    };
                  }
                ];
              };
            };

            dashboards.resources = {
              title = "Resources & Allocation";
              folder = "02 · Infrastructure";
              json = helpers.mkDashboard self.lib.monitoring.dashboard;
            };
          };

          testing.cgroups = testingSuite;
        }
        powerCfg
        volumesCfg
      ];
  };
}
