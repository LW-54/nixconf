{self, ...}: {
  /**
  Realises the testing contract with the NixOS test driver: built-in host essentials, QEMU sizing, and Disko install tests.
  */
  implementation.nixos-test = {
    contract = "testing";
    description = "Host verification through the NixOS test driver: built-in essentials, QEMU VM sizing, and Disko install tests.";
    module = {
      config,
      lib,
      options,
      ...
    }: let
      cfg = config.testing;
      testingLib = self.lib.testing;

      # Feature detection on declared options keeps this module usable in every variant:
      # plain (eval/install tier), QEMU test node (vm tier), and interactive `vmVariant`.
      hasQemu = options ? virtualisation && options.virtualisation ? memorySize && options.virtualisation ? cores;
      hasDisko = options ? disko && options.disko ? tests;

      sshd = config.services.openssh;
      fw = config.networking.firewall;

      loginAccounts = lib.filterAttrs (name: u: name == "root" || u.isNormalUser) config.users.users;
      usable = v: v != null && v != "" && !(lib.hasPrefix "!" (toString v)) && v != "*";
      hasPassword = u:
        lib.any usable [
          u.hashedPassword
          u.hashedPasswordFile
          u.password
          u.initialPassword
          u.initialHashedPassword
        ];
      hasKeys = u: sshd.enable && (u.openssh.authorizedKeys.keys != [] || u.openssh.authorizedKeys.keyFiles != []);
      sshdKeyDirectives =
        sshd.enable
        && (sshd.authorizedKeysFiles != [] || sshd.authorizedKeysCommand != "none" || lib.hasInfix "AuthorizedKeys" sshd.extraConfig);
      autoLogin =
        config.services.getty.autologinUser
        != null
        || (config.services.displayManager.autoLogin.enable or false);
      loginReady =
        lib.any (u: hasPassword u || hasKeys u) (builtins.attrValues loginAccounts)
        || sshdKeyDirectives
        || autoLogin;

      portAllowed = port:
        builtins.elem port fw.allowedTCPPorts
        || lib.any (r: port >= r.from && port <= r.to) fw.allowedTCPPortRanges
        || lib.any (i: builtins.elem port (i.allowedTCPPorts or [])) (builtins.attrValues fw.interfaces);

      bootLoader = config.system.build.installBootLoader;
    in {
      imports = [self.nixosModules.testing];

      config = lib.mkMerge [
        {
          # Evaluation tier: essentials every host must satisfy, checked on the real
          # (non-virtualised) storage and boot configuration in seconds.
          testing.evalChecks = {
            bootloader = {
              assertion = config.boot.isContainer || !(builtins.isAttrs bootLoader && (bootLoader.name or "") == "no-bootloader");
              message = "No boot loader is enabled, so the system cannot be made bootable; enable one (e.g. `boot.loader.grub` or `boot.loader.systemd-boot`) or set `boot.isContainer`.";
            };

            login = {
              assertion = loginReady;
              message = "No account can log in: neither root nor a normal user has a password (hash) or SSH authorized keys, and no auto-login is configured.";
            };

            ssh-reachable = {
              assertion = !(sshd.enable && fw.enable) || lib.all portAllowed sshd.ports;
              message = "sshd listens on ports ${builtins.toJSON sshd.ports} but the firewall does not allow them; set `services.openssh.openFirewall` or open the ports (disable this check if SSH is intentionally unreachable).";
            };

            state-version = {
              assertion = options.system.stateVersion.highestPrio < (lib.mkOptionDefault null).priority;
              message = "`system.stateVersion` is not set explicitly, so stateful services may silently migrate data on upgrade.";
            };

            hostname = {
              assertion = cfg.name == null || config.networking.hostName == cfg.name;
              message = "`networking.hostName` (\"${config.networking.hostName}\") differs from the flake host name (\"${toString cfg.name}\"); `nixos-rebuild --flake .` selects configurations by hostname.";
            };
          };

          # Runtime tiers: built-in checks bracketing all module-contributed checks.
          testing.checks = {
            boot = {
              description = "boots to multi-user.target";
              priority = 0;
              script = ''
                machine.wait_for_unit("multi-user.target")
              '';
            };

            failed-units = {
              description = "no systemd unit failed";
              priority = 10000;
              script = ''
                import datetime
                import fnmatch

                machine.execute("systemctl is-system-running --wait", timeout=datetime.timedelta(minutes=10))
                machine.log(machine.execute("systemd-analyze")[1])
                _allowed: list[str] = ${builtins.toJSON cfg.vm.allowedFailedUnits}
                _failed = [
                    _line.split()[0]
                    for _line in machine.succeed("systemctl list-units --state=failed --plain --no-legend --no-pager").splitlines()
                    if _line.strip()
                ]
                _unexpected = [_u for _u in _failed if not any(fnmatch.fnmatch(_u, _p) for _p in _allowed)]
                for _u in _unexpected:
                    machine.log(machine.execute(f"journalctl -b --no-pager -n 40 -u {_u}")[1])
                assert not _unexpected, f"failed systemd units: {', '.join(_unexpected)}"
              '';
            };
          };
        }

        (lib.optionalAttrs hasQemu {
          virtualisation.memorySize = lib.mkDefault cfg.vm.memorySize;
          virtualisation.cores = lib.mkDefault cfg.vm.cores;
        })

        {
          # `system.build.vm` of a test variant: an interactive VM with stand-in secrets.
          virtualisation.vmVariant = {
            virtualisation.forwardPorts = lib.optional (sshd.enable && sshd.ports != []) {
              from = "host";
              host.port = cfg.vm.sshForwardPort;
              guest.port = builtins.head sshd.ports;
            };
          };
        }

        (lib.optionalAttrs hasDisko {
          testing.install.enable = lib.mkDefault (config.disko.devices.disk != {});
          disko.memSize = lib.mkDefault cfg.vm.memorySize;
          disko.tests = {
            extraChecks = testingLib.mkTestScript {
              inherit (cfg) checks;
              tier = "install";
              label = cfg.name;
            };
            # Hard-coded boot devices name real hardware; the disk layout already
            # derives the right boot devices for the virtual disks.
            extraConfig.boot.loader.grub.device = lib.mkForce "";
          };
        })
      ];
    };
  };
}
