{self, ...}: {
  /**
  Systemd cgroups v2 resource controllers, hierarchical slices, and battery-aware policy executor.
  */
  implementation.cgroups = {
    contract = "resources";
    description = "Systemd control groups slice hierarchy and resource quotas implementation.";
    module = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.features.cgroups;
      rCfg = config.resources;
      profiles = self.lib.resources.profiles;

      # Filter out null values from attribute sets
      filterNulls = lib.filterAttrs (_: v: v != null);

      # Identify services that need dynamic battery throttling
      throttledBatteryServices = lib.filterAttrs (_: svc:
        svc.enable
        && (
          let
            base =
              if svc.profile != null && profiles ? ${svc.profile}
              then profiles.${svc.profile}
              else {};
            throttle = svc.battery.throttleOnBattery || (base.battery.throttleOnBattery or false);
          in
            throttle
        ))
      rCfg.services;
    in {
      options.features.cgroups = {
        enable = lib.mkEnableOption "systemd cgroups v2 resource controller" // {default = true;};

        enableOOMD = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable systemd-oomd userspace OOM killer for ManagedOOMPreference.";
        };
      };

      config = lib.mkIf cfg.enable {
        # Enable systemd userspace OOM killer
        systemd.oomd.enable = lib.mkIf cfg.enableOOMD (lib.mkDefault true);

        # Materialize custom and default systemd slices
        systemd.slices = lib.mapAttrs (name: sCfg: {
          sliceConfig = filterNulls {
            Description = sCfg.description;
            CPUWeight = sCfg.cpu.weight;
            CPUQuota = sCfg.cpu.quota;
            CPUQuotaPeriodSec = sCfg.cpu.period;
            MemoryMin = sCfg.memory.min;
            MemoryLow = sCfg.memory.low;
            MemoryHigh = sCfg.memory.high;
            MemoryMax = sCfg.memory.max;
            MemorySwapMax = sCfg.memory.swapMax;
            ManagedOOMPreference = sCfg.memory.oom;
            IOWeight = sCfg.io.weight;
            IOReadBandwidthMax = sCfg.io.readBandwidthMax;
            IOWriteBandwidthMax = sCfg.io.writeBandwidthMax;
            IODeviceLatencyTargetSec = sCfg.io.latencyTargetSec;
            TasksMax = sCfg.tasksMax;
          };
        }) (lib.filterAttrs (_: s: s != null) rCfg.slices);

        # Materialize per-service cgroups v2 resource settings
        systemd.services = lib.mkMerge [
          (lib.mapAttrs (name: svc: let
            base =
              if svc.profile != null && profiles ? ${svc.profile}
              then profiles.${svc.profile}
              else {};

            rawSlice =
              if svc.slice != null
              then svc.slice
              else (base.slice or null);
            sliceName =
              if rawSlice != null
              then
                (
                  if lib.hasSuffix ".slice" rawSlice
                  then rawSlice
                  else "${rawSlice}.slice"
                )
              else null;

            cpuWeight =
              if svc.cpu.weight != null
              then svc.cpu.weight
              else (base.cpu.weight or null);
            cpuQuota =
              if svc.cpu.quota != null
              then svc.cpu.quota
              else (base.cpu.quota or null);
            cpuPeriod = svc.cpu.period;
            cpuCores =
              if svc.cpu.cores != null
              then
                (
                  if lib.isList svc.cpu.cores
                  then lib.concatMapStringsSep "," toString svc.cpu.cores
                  else svc.cpu.cores
                )
              else null;

            memMin = svc.memory.min;
            memLow = svc.memory.low;
            memHigh = svc.memory.high;
            memMax = svc.memory.max;
            memSwapMax = svc.memory.swapMax;
            memOOM =
              if svc.memory.oom != null
              then svc.memory.oom
              else (base.memory.oom or null);

            ioWeight =
              if svc.io.weight != null
              then svc.io.weight
              else (base.io.weight or null);

            pauseOnBattery = svc.battery.pauseOnBattery || (base.battery.pauseOnBattery or false);
          in
            lib.mkIf svc.enable {
              serviceConfig = filterNulls {
                Slice = sliceName;
                CPUWeight = cpuWeight;
                CPUQuota = cpuQuota;
                CPUQuotaPeriodSec = cpuPeriod;
                AllowedCPUs = cpuCores;
                MemoryMin = memMin;
                MemoryLow = memLow;
                MemoryHigh = memHigh;
                MemoryMax = memMax;
                MemorySwapMax = memSwapMax;
                ManagedOOMPreference = memOOM;
                IOWeight = ioWeight;
                IOReadBandwidthMax = svc.io.readBandwidthMax;
                IOWriteBandwidthMax = svc.io.writeBandwidthMax;
                IODeviceLatencyTargetSec = svc.io.latencyTargetSec;
                TasksMax = svc.tasksMax;
              };

              unitConfig = filterNulls {
                ConditionACPower = lib.optionalString pauseOnBattery "yes";
              };
            })
          rCfg.services)

          # Dynamic battery management services (only when services request throttleOnBattery)
          (lib.mkIf (throttledBatteryServices != {}) {
            resource-battery-throttle = {
              description = "Apply battery resource throttle to background services";
              serviceConfig = {
                Type = "oneshot";
                ExecStart = let
                  commands =
                    lib.mapAttrsToList (svcName: svc: let
                      base =
                        if svc.profile != null && profiles ? ${svc.profile}
                        then profiles.${svc.profile}
                        else {};
                      bWeight =
                        if svc.battery.batteryCpuWeight != null
                        then svc.battery.batteryCpuWeight
                        else (base.battery.batteryCpuWeight or 10);
                      bQuota =
                        if svc.battery.batteryCpuQuota != null
                        then svc.battery.batteryCpuQuota
                        else (base.battery.batteryCpuQuota or null);
                      quotaCmd = lib.optionalString (bQuota != null) " ${pkgs.systemd}/bin/systemctl set-property ${svcName}.service CPUQuota=${bQuota};";
                    in ''
                      ${pkgs.systemd}/bin/systemctl set-property ${svcName}.service CPUWeight=${toString bWeight};${quotaCmd}
                    '')
                    throttledBatteryServices;
                in
                  pkgs.writeShellScript "battery-throttle" (lib.concatStringsSep "\n" commands);
              };
            };

            resource-ac-restore = {
              description = "Restore full resource allocation to background services on AC power";
              serviceConfig = {
                Type = "oneshot";
                ExecStart = let
                  commands =
                    lib.mapAttrsToList (svcName: svc: let
                      base =
                        if svc.profile != null && profiles ? ${svc.profile}
                        then profiles.${svc.profile}
                        else {};
                      origWeight =
                        if svc.cpu.weight != null
                        then svc.cpu.weight
                        else (base.cpu.weight or 100);
                      origQuota =
                        if svc.cpu.quota != null
                        then svc.cpu.quota
                        else (base.cpu.quota or "");
                      quotaCmd =
                        if origQuota != ""
                        then " ${pkgs.systemd}/bin/systemctl set-property ${svcName}.service CPUQuota=${origQuota};"
                        else " ${pkgs.systemd}/bin/systemctl set-property ${svcName}.service CPUQuota=\"\";";
                    in ''
                      ${pkgs.systemd}/bin/systemctl set-property ${svcName}.service CPUWeight=${toString origWeight};${quotaCmd}
                    '')
                    throttledBatteryServices;
                in
                  pkgs.writeShellScript "ac-restore" (lib.concatStringsSep "\n" commands);
              };
            };
          })
        ];

        # Udev rules to trigger battery/AC resource transitions
        services.udev.extraRules = lib.mkIf (throttledBatteryServices != {}) ''
          SUBSYSTEM=="power_supply", ATTR{online}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="resource-battery-throttle.service"
          SUBSYSTEM=="power_supply", ATTR{online}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}+="resource-ac-restore.service"
        '';
      };
    };
  };
}
