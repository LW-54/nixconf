{
  inputs,
  self,
  ...
}: {
  /**
  Ephemeral root filesystem persistence and state binding via impermanence.
  */
  implementation.impermanence = {
    contract = "persistence";
    description = "Ephemeral root filesystem with persistent state bind-mounts via Impermanence.";
    module = {
      lib,
      config,
      ...
    }: let
      cfg = config.persistence;
      systemRoot = "/persist/system";

      isRelativeEntry = entry: let
        paths =
          if builtins.isString entry
          then [entry]
          else
            (lib.optional (entry ? directory) entry.directory)
            ++ (lib.optional (entry ? file) entry.file);
      in
        paths != [] && lib.all (path: !lib.hasPrefix "/" path) paths;

      mkUserScope = userName: scope: let
        inherit (cfg.users.${userName}.${scope}) directories files;
      in {
        inherit directories files;
      };

      mkUserPersistence = userName: {
        "/persist/users/${userName}/data".users.${userName} = mkUserScope userName "data";
        "/persist/users/${userName}/cache".users.${userName} = mkUserScope userName "cache";
      };

      systemPersistence = {
        ${systemRoot} = {
          hideMounts = true;
          directories =
            [
              "/etc/nixos"
              "/var/log"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
              "/etc/NetworkManager/system-connections"
              "/tmp"
            ]
            ++ cfg.directories;
          files =
            [
              "/etc/machine-id"
            ]
            ++ cfg.files;
        };
      };
      entryPath = entry:
        if builtins.isString entry
        then entry
        else entry.directory or entry.file;
      persistedDirectories = map entryPath systemPersistence.${systemRoot}.directories;
      ephemeralRoot = (config.fileSystems."/".fsType or "") == "tmpfs";
    in {
      imports = [
        inputs.impermanence.nixosModules.impermanence
        self.nixosModules.testing
      ];

      config = {
        assertions =
          lib.mapAttrsToList (userName: user: {
            assertion = lib.all isRelativeEntry (
              user.data.directories
              ++ user.data.files
              ++ user.cache.directories
              ++ user.cache.files
            );
            message = "persistence.users.${userName} entries must be relative paths (or impermanence attribute sets), because they are mapped to /home/${userName}.";
          })
          cfg.users;

        programs.fuse.userAllowOther = true;
        boot.tmp.cleanOnBoot = true;
        fileSystems."/persist".neededForBoot = true;

        # Only meaningful on the real disk layout, i.e. in the install tier.
        testing.checks.persistence = {
          description = "state under ${systemRoot} survives a reboot${lib.optionalString ephemeralRoot " while the root is wiped"}";
          tiers = ["install"];
          # Reboots the machine, so run after the other checks but before `failed-units`.
          priority = 9000;
          script =
            ''
              for _dir in ${builtins.toJSON persistedDirectories}:
                  machine.succeed(f"mountpoint -q {_dir}")
              machine.succeed("echo persisted > /var/lib/nixos/nixconf-test-persist")
              machine.succeed("echo ephemeral > /etc/nixconf-test-ephemeral")
              machine.shutdown()
              machine.start()
              machine.wait_for_unit("multi-user.target")
              machine.succeed("grep -qx persisted /var/lib/nixos/nixconf-test-persist")
            ''
            + lib.optionalString ephemeralRoot ''
              machine.fail("test -e /etc/nixconf-test-ephemeral")
            '';
        };

        environment.persistence = lib.mkMerge (
          [systemPersistence]
          ++ map mkUserPersistence (builtins.attrNames cfg.users)
        );
      };
    };
  };
}
