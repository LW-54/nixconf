{
  internal.cgroups.mkTesting = {
    self,
    config,
    cfg,
    lib,
    utils,
    background,
    sliceNameFn,
  }: let
    enabledUnits = lib.filterAttrs (_: u: u.enable) cfg.units;
    enabledServiceUnits = lib.filterAttrs (n: _: lib.hasSuffix ".service" n) enabledUnits;
    enabledOtherUnits = lib.filterAttrs (n: _: !(lib.hasSuffix ".service" n)) enabledUnits;
    enabledVolumes = lib.filterAttrs (_: v: v.enable) cfg.volumes;
    enabledBudgets = lib.filterAttrs (_: b: b.enable) cfg.storageBudgets;

    missingTiers = lib.filterAttrs (_: u: !(cfg.tiers ? ${u.tier})) enabledUnits;
    invalidUnitSuffixes =
      builtins.filter (n: !(lib.hasSuffix ".service" n || lib.hasSuffix ".mount" n)) (builtins.attrNames enabledUnits);

    reservedMountPoints = ["/" "/persist" "/nix" "/boot"];
    mountPointVolumes = lib.filterAttrs (_: v: v.mountPoint != null) enabledVolumes;
    mountPointList = lib.mapAttrsToList (_: v: v.mountPoint) mountPointVolumes;
    uniqueMountPoints = lib.unique mountPointList;

    volumesNeedingMount = lib.filterAttrs (_: v: v.mode != "reserved" && v.mountPoint == null) enabledVolumes;
    invalidMountPaths = lib.filterAttrs (_: v: !(lib.hasPrefix "/" v.mountPoint) || builtins.elem v.mountPoint reservedMountPoints) mountPointVolumes;

    storageSlices = config.storage.slices or {};
    invalidBudgetSlices = builtins.filter (s: !(storageSlices ? ${s})) (builtins.attrNames enabledBudgets);

    builtinSlices = ["-" "system" "user" "machine"];
    customSlices = lib.filterAttrs (n: _: !(builtins.elem n builtinSlices)) cfg.tiers;
    batteryTiers = lib.filterAttrs (_: t: t.onBattery.enable) cfg.tiers;
    powerActive = cfg.power.enable && batteryTiers != {};

    expectedBgWeight = toString (
      if (cfg.tiers.background.cpu.weight or null) != null
      then cfg.tiers.background.cpu.weight
      else (background.cpu.weight or 20)
    );
    expectedBgIo = toString (
      if (cfg.tiers.background.io.weight or null) != null
      then cfg.tiers.background.io.weight
      else (background.io.weight or 20)
    );
    expectedCritWeight = toString (
      if (cfg.tiers.critical.cpu.weight or null) != null
      then cfg.tiers.critical.cpu.weight
      else if cfg.profile == "workstation"
      then 300
      else 500
    );
  in {
    description = "Systemd cgroups v2 workload tiers, OOM ordering, battery throttling, and disk policy verification";

    evalChecks = {
      valid-unit-tiers = {
        assertion = missingTiers == {};
        message = "Units in `resources.units` reference undefined tiers: ${lib.concatStringsSep ", " (lib.mapAttrsToList (u: v: "${u}->${v.tier}") missingTiers)}.";
      };

      valid-unit-names = {
        assertion = invalidUnitSuffixes == [];
        message = "`resources.units` keys must end with `.service` or `.mount`: ${lib.concatStringsSep ", " invalidUnitSuffixes}.";
      };

      valid-volumes = {
        assertion =
          volumesNeedingMount
          == {}
          && invalidMountPaths == {}
          && (builtins.length mountPointList == builtins.length uniqueMountPoints);
        message = "Invalid `resources.volumes` declaration: `thin`/`tmpfs` modes require a non-reserved absolute `mountPoint`, and mountpoints must be unique.";
      };

      valid-storage-budgets = {
        assertion = !(config.storage.enable or false) || invalidBudgetSlices == [];
        message = "`resources.storageBudgets` references unknown storage slices: ${lib.concatStringsSep ", " invalidBudgetSlices}.";
      };
    };

    inspectChecks = {
      slice-units = {
        description = "Verify custom resource slice units exist and declare expected cgroup weights";
        priority = 130;
        script =
          lib.concatStrings (lib.mapAttrsToList (sName: t: let
              sRel = lib.escapeShellArg (sliceNameFn sName);
              sFile = "\"$etc/systemd/system/\"${sRel}";
              wLine =
                if t.cpu.weight != null
                then "CPUWeight=${toString t.cpu.weight}"
                else "[Slice]";
              memMinLine =
                if t.memory.min != null
                then "MemoryMin=${toString t.memory.min}"
                else null;
            in ''
              test -e ${sFile} || {
                echo "Missing generated slice unit: $etc/systemd/system/${sliceNameFn sName}" >&2
                exit 1
              }
              grep -q '^\[Slice\]' ${sFile} || {
                echo "Missing [Slice] section in $etc/systemd/system/${sliceNameFn sName}" >&2
                exit 1
              }
              grep -q ${lib.escapeShellArg wLine} ${sFile} || {
                echo "Expected '${wLine}' in $etc/systemd/system/${sliceNameFn sName}" >&2
                exit 1
              }
              ${lib.optionalString (memMinLine != null) ''
                grep -q ${lib.escapeShellArg memMinLine} ${sFile} || {
                  echo "Expected '${memMinLine}' in $etc/systemd/system/${sliceNameFn sName}" >&2
                  exit 1
                }
              ''}
            '')
            customSlices)
          + ''
            echo "Verified ${toString (builtins.length (builtins.attrNames customSlices))} custom resource slices."
          '';
      };

      service-slices = {
        description = "Verify every managed systemd unit is pinned to its declared tier slice";
        priority = 132;
        script =
          lib.concatStrings (lib.mapAttrsToList (uName: u: let
              expected = "Slice=${sliceNameFn u.tier}";
              unitPath = "\"$etc/systemd/system/\"${lib.escapeShellArg uName}";
              dropinPath = "\"$etc/systemd/system/\"${lib.escapeShellArg "${uName}.d/overrides.conf"}";
            in ''
              if [ -e ${unitPath} ] && grep -qx ${lib.escapeShellArg expected} ${unitPath}; then
                :
              elif [ -e ${dropinPath} ] && grep -qx ${lib.escapeShellArg expected} ${dropinPath}; then
                :
              else
                echo "Unit ${uName} is missing '${expected}' in $etc/systemd/system/${uName} or ${uName}.d/overrides.conf" >&2
                exit 1
              fi
            '')
            enabledServiceUnits)
          + lib.concatStrings (lib.mapAttrsToList (uName: u: let
              expected = "Slice=${sliceNameFn u.tier}";
              dropinPath = "\"$etc/systemd/system/\"${lib.escapeShellArg "${uName}.d/50-resources.conf"}";
            in ''
              test -e ${dropinPath} && grep -qx ${lib.escapeShellArg expected} ${dropinPath} || {
                echo "Unit ${uName} is missing '${expected}' in $etc/systemd/system/${uName}.d/50-resources.conf" >&2
                exit 1
              }
            '')
            enabledOtherUnits)
          + ''
            echo "Verified slice placement for ${toString (builtins.length (builtins.attrNames enabledUnits))} managed units."
          '';
      };

      io-scheduler = {
        enable =
          lib.any (t: (t.io.weight or null) != null) (builtins.attrValues cfg.tiers)
          || lib.any (u: (u.io.weight or null) != null) (builtins.attrValues enabledUnits);
        description = "Verify BFQ block I/O scheduler udev rule exists when IOWeight policies are active";
        priority = 133;
        script = ''
          grep -rq 'ATTR{queue/scheduler}="bfq"' "$etc/udev/rules.d" || {
            echo "Missing BFQ udev rule in $etc/udev/rules.d" >&2
            exit 1
          }
        '';
      };

      disk-policies = {
        enable = cfg.disk.journalMaxSize != null || cfg.disk.nixMinFree != null;
        description = "Verify journald and Nix free-space disk policies are generated";
        priority = 134;
        script =
          lib.optionalString (cfg.disk.journalMaxSize != null) ''
            grep -q '^SystemMaxUse=${toString cfg.disk.journalMaxSize}' "$etc/systemd/journald.conf" || {
              echo "Missing SystemMaxUse=${toString cfg.disk.journalMaxSize} in journald.conf" >&2
              exit 1
            }
          ''
          + lib.optionalString (cfg.disk.nixMinFree != null) ''
            grep -q 'min-free =' "$etc/nix/nix.conf" || {
              echo "Missing min-free in nix.conf" >&2
              exit 1
            }
          '';
      };

      power-policy = {
        enable = powerActive;
        description = "Verify power-aware battery throttling service and udev rule exist";
        priority = 136;
        script = ''
          ${self.lib.testing.mkInspectFile {
            path = "$etc/systemd/system/resources-power-policy.service";
            pattern = "nixconf-power-policy";
          }}
          grep -rq 'resources-power-policy.service' "$etc/udev/rules.d" || {
            echo "Missing power_supply udev rule for resources-power-policy.service" >&2
            exit 1
          }
        '';
      };

      volumes = let
        nonTmpfs = lib.filterAttrs (_: v: v.mode != "tmpfs") enabledVolumes;
        mountedVols = lib.filterAttrs (_: v: v.mountPoint != null) enabledVolumes;
      in {
        enable = enabledVolumes != {};
        description = "Verify local disk volume preparation services and mount units exist";
        priority = 135;
        script =
          lib.concatStrings (lib.mapAttrsToList (vName: _: ''
              test -e "$etc/systemd/system/"${lib.escapeShellArg "resources-volume-${vName}.service"} || {
                echo "Missing volume service: resources-volume-${vName}.service" >&2
                exit 1
              }
            '')
            nonTmpfs)
          + lib.concatStrings (lib.mapAttrsToList (vName: v: let
              mountUnit = "${utils.escapeSystemdPath v.mountPoint}.mount";
            in ''
              test -e "$etc/systemd/system/"${lib.escapeShellArg mountUnit} || {
                echo "Missing volume mount unit: ${mountUnit}" >&2
                exit 1
              }
              test -e "$etc/systemd/system/"${lib.escapeShellArg "resources-volume-${vName}-perms.service"} || {
                echo "Missing volume perms service: resources-volume-${vName}-perms.service" >&2
                exit 1
              }
              ${lib.optionalString (v.mode != "tmpfs") ''
                grep -qE '^DefaultDependencies=(false|no)' "$etc/systemd/system/"${lib.escapeShellArg mountUnit} || {
                  echo "Expected DefaultDependencies=false in loopback mount ${mountUnit}" >&2
                  exit 1
                }
              ''}
              ${lib.optionalString (v.mode == "thin") ''
                grep -q '^Options=.*discard' "$etc/systemd/system/"${lib.escapeShellArg mountUnit} || {
                  echo "Expected discard mount option in thin volume ${mountUnit}" >&2
                  exit 1
                }
              ''}
              ${lib.optionalString (v.mode == "reserved") ''
                if grep -q '^Options=.*discard' "$etc/systemd/system/"${lib.escapeShellArg mountUnit}; then
                  echo "Unexpected discard mount option in reserved volume ${mountUnit}" >&2
                  exit 1
                fi
              ''}
            '')
            mountedVols)
          + ''
            echo "Verified ${toString (builtins.length (builtins.attrNames enabledVolumes))} local disk volume(s)."
          '';
      };

      storage-budgets = {
        enable = enabledBudgets != {} && (config.storage.enable or false);
        description = "Verify periodic remote storage budget measurement service and timer exist";
        priority = 137;
        script = ''
          ${self.lib.testing.mkInspectFile {
            path = "$etc/systemd/system/resources-storage-budgets.service";
            pattern = "nixconf-storage-budgets";
          }}
          test -e "$etc/systemd/system/resources-storage-budgets.timer" || {
            echo "Missing resources-storage-budgets.timer" >&2
            exit 1
          }
        '';
      };
    };

    vmChecks.cgroups-runtime = {
      description = "systemd-oomd, workload slices, and unit cgroup assignments are active at runtime";
      priority = 350;
      script = ''
        ${lib.optionalString cfg.oom.enable (self.lib.testing.mkServiceCheck {unit = "systemd-oomd.service";})}

        def _show(unit, prop):
            return machine.succeed(f"systemctl show -p {prop} --value {unit}").strip()

        assert _show("critical.slice", "CPUWeight") == "${expectedCritWeight}", f"critical.slice CPUWeight mismatch: {_show('critical.slice', 'CPUWeight')}"
        ${lib.optionalString ((cfg.tiers.critical.memory.min or null) != null) ''
          _crit_min = _show("critical.slice", "MemoryMin")
          assert _crit_min and _crit_min != "0", f"critical.slice MemoryMin not set: {_crit_min}"
        ''}
        assert _show("standard.slice", "CPUWeight") == "100", f"standard.slice CPUWeight mismatch: {_show('standard.slice', 'CPUWeight')}"
        assert _show("background.slice", "CPUWeight") == "${expectedBgWeight}", f"background.slice CPUWeight mismatch: {_show('background.slice', 'CPUWeight')}"
        assert _show("background.slice", "IOWeight") == "${expectedBgIo}", f"background.slice IOWeight mismatch: {_show('background.slice', 'IOWeight')}"
        ${lib.optionalString cfg.oom.enable ''
          assert _show("background.slice", "ManagedOOMMemoryPressure") == "kill", f"background.slice ManagedOOMMemoryPressure mismatch: {_show('background.slice', 'ManagedOOMMemoryPressure')}"
          assert _show("critical.slice", "ManagedOOMPreference") == "avoid", f"critical.slice ManagedOOMPreference mismatch: {_show('critical.slice', 'ManagedOOMPreference')}"
        ''}

        ${lib.optionalString (enabledServiceUnits ? "sshd.service") ''
          assert _show("sshd.service", "Slice") == "critical.slice", f"sshd.service Slice mismatch: {_show('sshd.service', 'Slice')}"
          assert _show("sshd.service", "OOMScoreAdjust") == "-500", f"sshd.service OOMScoreAdjust mismatch: {_show('sshd.service', 'OOMScoreAdjust')}"
          ${lib.optionalString cfg.oom.enable ''
            assert _show("sshd.service", "ManagedOOMPreference") == "avoid", f"sshd.service ManagedOOMPreference mismatch: {_show('sshd.service', 'ManagedOOMPreference')}"
          ''}
        ''}
        ${lib.optionalString (enabledServiceUnits ? "nix-daemon.service") ''
          assert _show("nix-daemon.service", "Slice") == "background.slice", f"nix-daemon.service Slice mismatch: {_show('nix-daemon.service', 'Slice')}"
          assert _show("nix-daemon.service", "OOMScoreAdjust") == "500", f"nix-daemon.service OOMScoreAdjust mismatch: {_show('nix-daemon.service', 'OOMScoreAdjust')}"
        ''}
        ${lib.optionalString powerActive ''
          machine.wait_for_unit("resources-power-policy.service")
        ''}
        ${lib.concatStrings (lib.mapAttrsToList (_: v: ''
            machine.succeed("mountpoint -q " + ${builtins.toJSON v.mountPoint})
          '')
          mountPointVolumes)}
        ${lib.concatStrings (lib.mapAttrsToList (vName: v: ''
          machine.succeed("test -s " + ${builtins.toJSON "${v.backingDir}/${vName}.reserve"})
        '') (lib.filterAttrs (_: v: v.mode == "reserved" && v.mountPoint == null) enabledVolumes))}
      '';
    };
  };
}
