{lib, ...}: let
  # Predefined profile archetypes
  profiles = {
    critical = {
      slice = "production";
      cpu.weight = 500;
      memory.oom = "avoid";
      io.weight = 500;
      battery = {
        throttleOnBattery = false;
        pauseOnBattery = false;
      };
    };

    standard = {
      slice = "services";
      cpu.weight = 100;
      memory.oom = "none";
      io.weight = 100;
      battery = {
        throttleOnBattery = false;
        pauseOnBattery = false;
      };
    };

    background = {
      slice = "background";
      cpu.weight = 20;
      memory.oom = "omit";
      io.weight = 20;
      battery = {
        throttleOnBattery = true;
        pauseOnBattery = false;
        batteryCpuWeight = 10;
      };
    };

    batch = {
      slice = "background";
      cpu = {
        weight = 10;
        quota = "50%";
      };
      memory.oom = "omit";
      io.weight = 10;
      battery = {
        throttleOnBattery = true;
        pauseOnBattery = true;
        batteryCpuWeight = 1;
        batteryCpuQuota = "20%";
      };
    };
  };

  # Default slice pool configurations
  defaultSlices = {
    system = {
      description = "Core system services and emergency administrative access";
      cpu.weight = 500;
      memory = {
        low = "256M";
        oom = "avoid";
      };
      io.weight = 500;
    };

    production = {
      description = "Critical user-facing services (e.g. reverse proxy, auth, vault)";
      cpu.weight = 200;
      memory.oom = "avoid";
      io.weight = 200;
    };

    services = {
      description = "Standard systemd application services";
      cpu.weight = 100;
      memory.oom = "none";
      io.weight = 100;
    };

    background = {
      description = "Low-priority background workloads, backups, and batch processing";
      cpu.weight = 20;
      memory.oom = "omit";
      io.weight = 20;
    };
  };

  # Byte size string pattern (e.g. 64M, 2G, 512K, 100B)
  byteRegex = "^[0-9]+(\\.[0-9]+)?(B|K|M|G|T|P)?(iB|B)?$";

  /**
  Type validating memory and disk size strings with standard unit suffixes (B, K, M, G, T, P)
  or raw integers representing bytes.
  */
  byteSize = lib.types.mkOptionType {
    name = "byteSize";
    description = "Size with units (e.g. '64M', '2G', '512K')";
    check = x: (builtins.isString x && builtins.match byteRegex x != null) || builtins.isInt x;
    merge = lib.options.mergeOneOption;
  };

  /**
  Type validating cgroups v2 resource weight integers strictly between 1 and 10,000.
  */
  cgroupWeight = lib.types.mkOptionType {
    name = "cgroupWeight";
    description = "Cgroup weight integer between 1 and 10000";
    check = x: builtins.isInt x && x >= 1 && x <= 10000;
    merge = lib.options.mergeOneOption;
  };

  # Slice submodule definition
  sliceSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        default = "Resource slice for ${name}";
        description = "Description of the slice.";
      };

      cpu = {
        weight = lib.mkOption {
          type = lib.types.nullOr cgroupWeight;
          default = null;
          description = "CPUWeight (1-10000). Relative proportion of CPU execution time.";
        };

        quota = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "CPUQuota (e.g. '50%', '150%'). Hard execution cap per period.";
        };

        period = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "CPUQuotaPeriodSec (e.g. '100ms').";
        };
      };

      memory = {
        min = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryMin: Hard memory protection floor. Never reclaimed or swapped.";
        };

        low = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryLow: Soft memory protection floor. Protected under normal memory pressure.";
        };

        high = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryHigh: Progressive throttle and reclaim threshold.";
        };

        max = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryMax: Hard ceiling. Triggers OOM kill if exceeded.";
        };

        swapMax = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemorySwapMax: Maximum swap allocation.";
        };

        oom = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum ["none" "avoid" "omit"]);
          default = null;
          description = "ManagedOOMPreference for systemd-oomd.";
        };
      };

      io = {
        weight = lib.mkOption {
          type = lib.types.nullOr cgroupWeight;
          default = null;
          description = "IOWeight (1-10000). Relative proportion of I/O throughput.";
        };

        readBandwidthMax = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "IOReadBandwidthMax entries (e.g. ['/dev/sda 10M']).";
        };

        writeBandwidthMax = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "IOWriteBandwidthMax entries.";
        };

        latencyTargetSec = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "IODeviceLatencyTargetSec.";
        };
      };

      tasksMax = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
        default = null;
        description = "TasksMax: Process/thread limit.";
      };
    };
  });

  # Service submodule definition
  serviceSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether resource management is enabled for this service.";
      };

      profile = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum ["critical" "standard" "background" "batch" "custom"]);
        default = null;
        description = "Resource profile preset archetype.";
      };

      slice = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Systemd slice to assign this service to (e.g. 'production', 'background').";
      };

      cpu = {
        weight = lib.mkOption {
          type = lib.types.nullOr cgroupWeight;
          default = null;
          description = "CPUWeight (1-10000).";
        };

        quota = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "CPUQuota (e.g. '80%', '200%'). Hard cap.";
        };

        period = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "CPUQuotaPeriodSec (e.g. '100ms').";
        };

        cores = lib.mkOption {
          type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.listOf lib.types.int));
          default = null;
          description = "AllowedCPUs (core affinity/pinning, e.g. '0-1' or [0 1]).";
        };
      };

      memory = {
        min = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryMin: Hard memory protection floor.";
        };

        low = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryLow: Soft memory protection floor.";
        };

        high = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryHigh: Progressive throttle and reclaim threshold.";
        };

        max = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemoryMax: Hard ceiling. Triggers OOM kill if exceeded.";
        };

        swapMax = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "MemorySwapMax: Maximum swap allocation.";
        };

        oom = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum ["none" "avoid" "omit"]);
          default = null;
          description = "ManagedOOMPreference for systemd-oomd.";
        };
      };

      io = {
        weight = lib.mkOption {
          type = lib.types.nullOr cgroupWeight;
          default = null;
          description = "IOWeight (1-10000).";
        };

        readBandwidthMax = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "IOReadBandwidthMax entries.";
        };

        writeBandwidthMax = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "IOWriteBandwidthMax entries.";
        };

        latencyTargetSec = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "IODeviceLatencyTargetSec.";
        };
      };

      tasksMax = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
        default = null;
        description = "TasksMax: Process/thread count limit.";
      };

      network = {
        rateLimit = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Network bandwidth rate limit.";
        };

        priority = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Traffic class / priority value.";
        };
      };

      disk = {
        maxSize = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "Disk quota / storage size ceiling.";
        };
      };

      battery = {
        throttleOnBattery = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to throttle CPU/IO when running on battery.";
        };

        batteryCpuWeight = lib.mkOption {
          type = lib.types.nullOr cgroupWeight;
          default = null;
          description = "Lower CPU weight to apply when running on battery.";
        };

        batteryCpuQuota = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Lower CPU quota to apply when running on battery.";
        };

        pauseOnBattery = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to pause/skip service execution while on battery (ConditionACPower=yes).";
        };
      };
    };
  });
in {
  mkContract.resources = {
    options = {
      enable = lib.mkEnableOption "system resource allocation contract" // {default = true;};

      defaultSlices = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to automatically declare standard hierarchical resource slices
            (`system.slice`, `production.slice`, `services.slice`, and `background.slice`).
          '';
        };
      };

      slices = lib.mkOption {
        type = lib.types.attrsOf sliceSubmodule;
        default = {};
        description = ''
          Attribute set of hierarchical systemd slice definitions mapping directly
          to Linux cgroups v2 resource controllers (CPU, memory, IO, and task counts).
        '';
      };

      services = lib.mkOption {
        type = lib.types.attrsOf serviceSubmodule;
        default = {};
        description = ''
          Attribute set of per-service resource policies and constraints
          mapped directly to individual systemd service unit configurations.
        '';
      };
    };

    mkOption = {
      profile ? null,
      slice ? null,
      cpu ? {},
      memory ? {},
      io ? {},
      tasksMax ? null,
      battery ? {},
    }: {
      resources = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether resource management is enabled for this service.";
            };

            profile = lib.mkOption {
              type = lib.types.nullOr (lib.types.enum ["critical" "standard" "background" "batch" "custom"]);
              default = profile;
              description = "Resource profile preset.";
            };

            slice = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = slice;
              description = "Systemd slice to assign this service to.";
            };

            cpu = {
              weight = lib.mkOption {
                type = lib.types.nullOr cgroupWeight;
                default = cpu.weight or null;
                description = "CPUWeight (1-10000).";
              };

              quota = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = cpu.quota or null;
                description = "CPUQuota.";
              };

              cores = lib.mkOption {
                type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.listOf lib.types.int));
                default = cpu.cores or null;
                description = "AllowedCPUs.";
              };
            };

            memory = {
              min = lib.mkOption {
                type = lib.types.nullOr byteSize;
                default = memory.min or null;
                description = "Hard memory floor guarantee (MemoryMin).";
              };

              low = lib.mkOption {
                type = lib.types.nullOr byteSize;
                default = memory.low or null;
                description = "Soft memory floor protection (MemoryLow).";
              };

              high = lib.mkOption {
                type = lib.types.nullOr byteSize;
                default = memory.high or null;
                description = "Progressive throttle / reclaim threshold (MemoryHigh).";
              };

              max = lib.mkOption {
                type = lib.types.nullOr byteSize;
                default = memory.max or null;
                description = "Hard ceiling limit (MemoryMax).";
              };

              oom = lib.mkOption {
                type = lib.types.nullOr (lib.types.enum ["none" "avoid" "omit"]);
                default = memory.oom or null;
                description = "ManagedOOMPreference.";
              };
            };

            io = {
              weight = lib.mkOption {
                type = lib.types.nullOr cgroupWeight;
                default = io.weight or null;
                description = "IOWeight (1-10000).";
              };
            };

            tasksMax = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
              default = tasksMax;
              description = "TasksMax.";
            };

            battery = {
              throttleOnBattery = lib.mkOption {
                type = lib.types.bool;
                default = battery.throttleOnBattery or false;
                description = "Throttle on battery.";
              };

              pauseOnBattery = lib.mkOption {
                type = lib.types.bool;
                default = battery.pauseOnBattery or false;
                description = "Pause service execution while on battery.";
              };
            };
          };
        };
        default = {};
        description = "Resource allocation contract settings.";
      };
    };

    mkConfig = {
      config,
      serviceName,
      cfg,
    }:
      lib.mkIf ((config.resources.enable or false) && cfg ? resources && cfg.resources.enable) {
        resources.services.${serviceName} = {
          inherit (cfg.resources) profile slice cpu memory io tasksMax battery;
        };
      };

    types = {
      slice = sliceSubmodule;
      service = serviceSubmodule;
      inherit byteSize cgroupWeight;
    };

    extraLib = {
      inherit profiles defaultSlices;
    };
  };
}
