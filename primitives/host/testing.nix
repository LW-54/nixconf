# Host testing module: core system essentials, bootability, authentication, systemd health, and QEMU emulation.
{
  _module.args = {
    hostTestingModule = {name}: {
      config,
      lib,
      options,
      ...
    }: let
      cfg = config.testing;

      hasQemu = options ? virtualisation && options.virtualisation ? memorySize && options.virtualisation ? cores;

      loginAccounts = lib.filterAttrs (n: u: n == "root" || u.isNormalUser) config.users.users;
      loginUsers = builtins.attrNames loginAccounts;
      usable = v: v != null && v != "" && !(lib.hasPrefix "!" (toString v)) && v != "*";
      hasPassword = u:
        lib.any usable [
          u.hashedPassword
          u.hashedPasswordFile
          u.password
          u.initialPassword
          u.initialHashedPassword
        ];
      hasKeys = u: (u.openssh.authorizedKeys.keys != [] || u.openssh.authorizedKeys.keyFiles != []);
      autoLogin =
        config.services.getty.autologinUser
        != null
        || (config.services.displayManager.autoLogin.enable or false);
      loginReady =
        lib.any (u: hasPassword u || hasKeys u) (builtins.attrValues loginAccounts)
        || autoLogin;

      bootLoader = config.system.build.installBootLoader;

      virtioInitrdModules = [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
        "9p"
        "9pnet_virtio"
        "virtiofs"
      ];
      virtioKernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    in {
      _file = "primitives/host/testing.nix";
      key = "primitives-host-testing-${name}";

      config = lib.mkMerge [
        {
          testing = {
            name = lib.mkDefault name;

            interactiveNotes =
              lib.optional (loginUsers != [])
              "  console login : ${lib.concatStringsSep ", " loginUsers} / password 'test'";

            host = {
              description = "Host identity, bootability, authentication, systemd health, and platform checks";

              evalChecks = {
                hostname = {
                  assertion = config.networking.hostName == name;
                  message = "`networking.hostName` (\"${config.networking.hostName}\") differs from the flake host name (\"${name}\"); `nixos-rebuild --flake .` selects configurations by hostname.";
                };

                bootloader = {
                  assertion = config.boot.isContainer || !(builtins.isAttrs bootLoader && (bootLoader.name or "") == "no-bootloader");
                  message = "No boot loader is enabled, so the system cannot be made bootable; enable one (e.g. `boot.loader.grub` or `boot.loader.systemd-boot`) or set `boot.isContainer`.";
                };

                login = {
                  assertion = loginReady;
                  message = "No account can log in: neither root nor a normal user has a password (hash) or SSH authorized keys, and no auto-login is configured.";
                };

                state-version = {
                  assertion = options.system.stateVersion.highestPrio < (lib.mkOptionDefault null).priority;
                  message = "`system.stateVersion` is not set explicitly, so stateful services may silently migrate data on upgrade.";
                };
              };

              inspectChecks = {
                fstab = {
                  description = "Verify filesystem table (/etc/fstab) exists";
                  priority = 100;
                  script = ''
                    if [ ! -e "$etc/fstab" ]; then
                      echo "Error: /etc/fstab was not generated!" >&2
                      exit 1
                    fi
                  '';
                };

                shells = {
                  description = "Verify valid login shells (/etc/shells) exist";
                  priority = 110;
                  script = ''
                    if [ ! -e "$etc/shells" ]; then
                      echo "Error: /etc/shells was not generated!" >&2
                      exit 1
                    fi
                  '';
                };

                pam = {
                  description = "Verify PAM directory and login configuration exist";
                  priority = 120;
                  script = ''
                    if [ ! -d "$etc/pam.d" ] || [ ! -e "$etc/pam.d/login" ]; then
                      echo "Error: /etc/pam.d/login was not generated!" >&2
                      exit 1
                    fi
                  '';
                };

                sudoers = {
                  description = "Verify sudoers configuration exists";
                  priority = 130;
                  script = ''
                    if [ ! -e "$etc/sudoers" ]; then
                      echo "Error: /etc/sudoers was not generated!" >&2
                      exit 1
                    fi
                  '';
                };

                systemd = {
                  description = "Verify systemd directory exists";
                  priority = 140;
                  script = ''
                    if [ ! -d "$etc/systemd/system" ]; then
                      echo "Error: /etc/systemd/system was not generated!" >&2
                      exit 1
                    fi
                  '';
                };
              };

              vmChecks = {
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
            };
          };
        }

        (lib.optionalAttrs hasQemu {
          virtualisation.memorySize = lib.mkDefault cfg.vm.memorySize;
          virtualisation.cores = lib.mkDefault cfg.vm.cores;
          console.keyMap = lib.mkVMOverride "us";
          boot.resumeDevice = lib.mkVMOverride "";
          boot.initrd.availableKernelModules = virtioInitrdModules;
          boot.kernelModules = virtioKernelModules;
        })
      ];
    };
  };
}
