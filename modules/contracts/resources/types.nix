{lib, ...}: let
  byteRegex = "^([0-9]+)(\\.([0-9]+))?(B|K|M|G|T|P)?$";
  resourceRegex = "^[0-9]+(\\.[0-9]+)?(B|K|M|G|T|P|%)?$";
  cpuQuotaRegex = "^[0-9]+(\\.[0-9]+)?%$";
  percentRegex = "^(100|[1-9]?[0-9])%$";

  unitMultipliers = {
    "" = 1;
    B = 1;
    K = 1024;
    M = 1024 * 1024;
    G = 1024 * 1024 * 1024;
    T = 1024 * 1024 * 1024 * 1024;
    P = 1024 * 1024 * 1024 * 1024 * 1024;
  };

  pow10 = n:
    if n <= 0
    then 1
    else 10 * (pow10 (n - 1));

  toBytes = x:
    if builtins.isInt x
    then
      if x >= 0
      then x
      else throw "resources: byteSize integer must be non-negative, got ${toString x}."
    else let
      m =
        if builtins.isString x
        then builtins.match byteRegex x
        else null;
    in
      if m == null
      then throw "resources: invalid byteSize '${toString x}' (expected e.g. '512M', '1.5G', or integer bytes)."
      else let
        intVal = lib.toIntBase10 (builtins.elemAt m 0);
        fracRaw = builtins.elemAt m 2;
        suffixRaw = builtins.elemAt m 3;
        suffix =
          if suffixRaw == null
          then ""
          else suffixRaw;
        mul = unitMultipliers.${suffix};
        fracShort =
          if fracRaw == null
          then null
          else builtins.substring 0 3 fracRaw;
        fracBytes =
          if fracShort == null || fracShort == ""
          then 0
          else ((lib.toIntBase10 fracShort) * mul) / (pow10 (builtins.stringLength fracShort));
      in
        intVal * mul + fracBytes;

  sliceName = tier:
    if lib.hasSuffix ".slice" tier
    then tier
    else "${tier}.slice";

  byteSize = lib.types.mkOptionType {
    name = "byteSize";
    description = "Byte size as an integer or systemd size string with `B`, `K`, `M`, `G`, `T`, or `P` suffix (e.g. `512M`, `2G`).";
    check = x: (builtins.isInt x && x >= 0) || (builtins.isString x && builtins.match byteRegex x != null);
    merge = lib.options.mergeOneOption;
  };

  resourceSize = lib.types.mkOptionType {
    name = "resourceSize";
    description = "Cgroup memory limit as an integer, size string (`B`/`K`/`M`/`G`/`T`/`P`), percentage (`%`), or `infinity`.";
    check = x: (builtins.isInt x && x >= 0) || (builtins.isString x && (x == "infinity" || builtins.match resourceRegex x != null));
    merge = lib.options.mergeOneOption;
  };

  cgroupWeight = lib.types.mkOptionType {
    name = "cgroupWeight";
    description = "Cgroups v2 relative scheduling weight integer strictly between `1` and `10000`.";
    check = x: builtins.isInt x && x >= 1 && x <= 10000;
    merge = lib.options.mergeOneOption;
  };

  cpuQuota = lib.types.mkOptionType {
    name = "cpuQuota";
    description = "Systemd `CPUQuota=` percentage string (e.g. `50%`, `150%`).";
    check = x: builtins.isString x && builtins.match cpuQuotaRegex x != null;
    merge = lib.options.mergeOneOption;
  };

  percentage = lib.types.mkOptionType {
    name = "percentage";
    description = "Percentage string strictly between `0%` and `100%`.";
    check = x: builtins.isString x && builtins.match percentRegex x != null;
    merge = lib.options.mergeOneOption;
  };

  oomScore = lib.types.mkOptionType {
    name = "oomScore";
    description = "Linux kernel `OOMScoreAdjust` integer strictly between `-1000` and `1000`.";
    check = x: builtins.isInt x && x >= -1000 && x <= 1000;
    merge = lib.options.mergeOneOption;
  };

  oomPreference =
    (lib.types.enum ["none" "avoid" "omit"])
    // {
      description = "Systemd `ManagedOOMPreference` policy (`none`, `avoid`, or `omit`).";
    };

  profile =
    (lib.types.enum ["server" "workstation"])
    // {
      description = "Host workload profile preset (`server` or `workstation`).";
    };

  mkLimitsOptions = {
    defaults ? {},
    includeOomKill ? false,
  }: let
    cpuDef = defaults.cpu or {};
    memDef = defaults.memory or {};
    ioDef = defaults.io or {};
    oomDef = defaults.oom or {};
  in {
    cpu = {
      weight = lib.mkOption {
        type = lib.types.nullOr cgroupWeight;
        default = cpuDef.weight or null;
        description = "Cgroups v2 relative CPU scheduling weight (`CPUWeight`, `1` to `10000`).";
      };
      quota = lib.mkOption {
        type = lib.types.nullOr cpuQuota;
        default = cpuDef.quota or null;
        description = "Hard CPU bandwidth ceiling (`CPUQuota`, e.g. `50%`, `200%`).";
      };
      cores = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.listOf lib.types.int));
        default = cpuDef.cores or null;
        description = "Allowed CPU core mask (`AllowedCPUs`, e.g. `\"0-1\"` or `[0 1]`).";
      };
    };

    memory = {
      min = lib.mkOption {
        type = lib.types.nullOr resourceSize;
        default = memDef.min or null;
        description = "Hard memory protection floor (`MemoryMin`). Never reclaimed by kernel.";
      };
      low = lib.mkOption {
        type = lib.types.nullOr resourceSize;
        default = memDef.low or null;
        description = "Soft memory protection floor (`MemoryLow`). Protected under normal pressure.";
      };
      high = lib.mkOption {
        type = lib.types.nullOr resourceSize;
        default = memDef.high or null;
        description = "Throttling and aggressive reclaim threshold (`MemoryHigh`).";
      };
      max = lib.mkOption {
        type = lib.types.nullOr resourceSize;
        default = memDef.max or null;
        description = "Hard memory ceiling (`MemoryMax`). Triggers OOM kill if exceeded.";
      };
      swapMax = lib.mkOption {
        type = lib.types.nullOr resourceSize;
        default = memDef.swapMax or null;
        description = "Hard swap usage ceiling (`MemorySwapMax`).";
      };
    };

    io = {
      weight = lib.mkOption {
        type = lib.types.nullOr cgroupWeight;
        default = ioDef.weight or null;
        description = "Cgroups v2 relative block I/O scheduling weight (`IOWeight`, `1` to `10000`).";
      };
      readMax = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = ioDef.readMax or null;
        description = "Per-device block read bandwidth limits (`IOReadBandwidthMax`, e.g. `[\"/dev/sda 20M\"]`).";
      };
      writeMax = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = ioDef.writeMax or null;
        description = "Per-device block write bandwidth limits (`IOWriteBandwidthMax`, e.g. `[\"/dev/sda 20M\"]`).";
      };
    };

    tasksMax = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
      default = defaults.tasksMax or null;
      description = "Maximum number of processes and threads permitted (`TasksMax`).";
    };

    oom =
      {
        preference = lib.mkOption {
          type = lib.types.nullOr oomPreference;
          default = oomDef.preference or null;
          description = "Hint passed to `systemd-oomd` (`ManagedOOMPreference`: `none`, `avoid`, or `omit`).";
        };
        scoreAdjust = lib.mkOption {
          type = lib.types.nullOr oomScore;
          default = oomDef.scoreAdjust or null;
          description = "Kernel OOM killer score bias (`OOMScoreAdjust`, `-1000` to `1000`).";
        };
      }
      // lib.optionalAttrs includeOomKill {
        kill = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = oomDef.kill or null;
          description = "Whether `systemd-oomd` may terminate units in this tier under sustained memory pressure (`ManagedOOMMemoryPressure`).";
        };
        pressureLimit = lib.mkOption {
          type = lib.types.nullOr percentage;
          default = oomDef.pressureLimit or null;
          description = "PSI memory pressure percentage threshold (`ManagedOOMMemoryPressureLimit`) before `systemd-oomd` intervenes.";
        };
      };
  };

  onBatterySubmodule =
    (lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "battery throttling overrides for this tier";

        cpu = {
          weight = lib.mkOption {
            type = lib.types.nullOr cgroupWeight;
            default = null;
            description = "Override `CPUWeight` applied to this tier while running on battery.";
          };
          quota = lib.mkOption {
            type = lib.types.nullOr cpuQuota;
            default = null;
            description = "Override `CPUQuota` applied to this tier while running on battery.";
          };
        };

        io = {
          weight = lib.mkOption {
            type = lib.types.nullOr cgroupWeight;
            default = null;
            description = "Override `IOWeight` applied to this tier while running on battery.";
          };
        };
      };
    })
    // {
      description = "Power-policy override submodule defining reduced CPU and I/O limits applied to a tier while on battery.";
    };

  tierSubmodule =
    (lib.types.submodule ({name, ...}: {
      options =
        {
          description = lib.mkOption {
            type = lib.types.str;
            default = "Workload resource tier '${name}'.";
            description = "Human-readable description assigned to the systemd slice unit.";
          };

          onBattery = lib.mkOption {
            type = onBatterySubmodule;
            default = {};
            description = "Dynamic CPU and I/O throttling overrides applied to this tier when running on battery.";
          };
        }
        // mkLimitsOptions {includeOomKill = true;};
    }))
    // {
      description = "Workload resource tier submodule mapping directly to a top-level systemd `.slice` unit.";
    };

  unitSubmodule =
    (lib.types.submodule {
      options =
        {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether declarative resource allocation is enabled for this systemd unit.";
          };

          tier = lib.mkOption {
            type = lib.types.str;
            default = "standard";
            description = "Workload resource tier (`resources.tiers.<name>`) governing this systemd unit.";
          };

          deferOnBattery = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to skip starting this unit while running on battery power (`ConditionACPower=true`).";
          };
        }
        // mkLimitsOptions {};
    })
    // {
      description = "Per-systemd-unit resource policy submodule binding a unit to a tier with optional overrides.";
    };

  oomSubmodule =
    (lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable `systemd-oomd` userspace OOM pressure and swap monitoring.";
        };

        swapKill = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether `systemd-oomd` monitors host swap saturation on the root slice (`ManagedOOMSwap=kill`).";
        };

        swapUsedLimit = lib.mkOption {
          type = lib.types.nullOr percentage;
          default = null;
          description = "Optional `SwapUsedLimit` threshold configured in `/etc/systemd/oomd.conf`.";
        };

        defaultPressureDuration = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional `DefaultMemoryPressureDurationSec` window configured in `/etc/systemd/oomd.conf`.";
        };
      };
    })
    // {
      description = "Host-wide `systemd-oomd` configuration submodule.";
    };

  powerSubmodule =
    (lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to activate AC/battery power-supply throttling and `deferOnBattery` gating.";
        };
      };
    })
    // {
      description = "Host power-aware resource throttling policy submodule.";
    };

  diskSubmodule =
    (lib.types.submodule {
      options = {
        journalMaxSize = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "Maximum persistent journal disk budget enforced by `systemd-journald` (`SystemMaxUse`).";
        };

        journalKeepFree = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "Minimum free disk space preserved by `systemd-journald` (`SystemKeepFree`).";
        };

        nixMinFree = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "Minimum free disk threshold (`min-free`) triggering automatic Nix garbage collection during builds.";
        };

        nixMaxFree = lib.mkOption {
          type = lib.types.nullOr byteSize;
          default = null;
          description = "Target free disk space (`max-free`) freed when automatic Nix garbage collection triggers.";
        };
      };
    })
    // {
      description = "System-wide local disk headroom and garbage-collection threshold submodule.";
    };

  volumeSubmodule =
    (lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether this local disk space allocation or reservation volume is active.";
        };

        mode = lib.mkOption {
          type = lib.types.enum ["reserved" "thin" "tmpfs"];
          default = "reserved";
          description = "Allocation strategy: preallocated `fallocate` block/ext4 image (`reserved`), sparse quota image (`thin`), or RAM-backed (`tmpfs`).";
        };

        size = lib.mkOption {
          type = byteSize;
          description = "Exact size allocated, reserved, or capped for this local volume.";
        };

        mountPoint = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Target mountpoint directory, or `null` when `mode = \"reserved\"` acts as an unmounted space-reservation block.";
        };

        backingDir = lib.mkOption {
          type = lib.types.str;
          default = "/persist/.volumes";
          description = "Host directory storing backing `.img` or `.reserve` files for `reserved` and `thin` volumes.";
        };

        owner = lib.mkOption {
          type = lib.types.str;
          default = "root";
          description = "User owning the mounted volume root directory.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "root";
          description = "Group owning the mounted volume root directory.";
        };

        dirMode = lib.mkOption {
          type = lib.types.str;
          default = "0755";
          description = "Octal POSIX permissions mode enforced on the mounted volume root directory.";
        };

        beforeUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Systemd service units ordered after this volume is formatted, mounted, and chowned.";
        };

        excludeFromSnapshot = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to exclude this volume from host Btrfs snapshots (`null` excludes unmounted `.reserve` files automatically).";
        };

        excludeFromBackup = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to exclude this volume's mountpoint from host restic backups.";
        };
      };
    })
    // {
      description = "Dedicated local disk quota, preallocated loopback volume, or space reservation submodule.";
    };

  storageBudgetSubmodule =
    (lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether periodic remote storage usage measurement and budget alerting are active for this slice.";
        };

        maxSize = lib.mkOption {
          type = byteSize;
          description = "Target soft capacity budget enforced via monitoring and alerts for the remote storage slice.";
        };

        warnPercent = lib.mkOption {
          type = lib.types.ints.between 1 100;
          default = 80;
          description = "Percentage of `maxSize` that triggers a warning alert before exceeding the budget.";
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "6h";
          description = "Systemd timer cadence (`OnUnitActiveSec`) for measuring remote slice consumption.";
        };
      };
    })
    // {
      description = "Remote storage capacity budget and periodic telemetry submodule keyed by `storage.slices` name.";
    };
in {
  options.internal.resources = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal helper functions and preset definitions for the `resources` contract.";
  };

  config = {
    internal.resources.helpers = {
      inherit toBytes sliceName mkLimitsOptions;
    };

    contract.resources.types = {
      inherit byteSize resourceSize cgroupWeight cpuQuota percentage oomScore oomPreference profile;
      onBattery = onBatterySubmodule;
      tier = tierSubmodule;
      unit = unitSubmodule;
      oom = oomSubmodule;
      power = powerSubmodule;
      disk = diskSubmodule;
      volume = volumeSubmodule;
      storageBudget = storageBudgetSubmodule;
    };
  };
}
