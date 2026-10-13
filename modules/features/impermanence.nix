{ self, inputs, ... }:

{
  flake.nixosModules.impermanence = { lib, config, ... }:
    let
      cfg = config.persistence;
      systemRoot = "/persist/system";

      isRelativeEntry = entry:
        let
          paths =
            if builtins.isString entry then
              [ entry ]
            else
              (lib.optional (entry ? directory) entry.directory)
              ++ (lib.optional (entry ? file) entry.file);
        in
        paths != [ ] && lib.all (path: !lib.hasPrefix "/" path) paths;

      mkUserScope = userName: scope:
        let
          inherit (cfg.users.${userName}.${scope}) directories files;
        in
        {
          inherit directories files;
        };

      mkUserPersistence = userName: {
        "/persist/users/${userName}/data".users.${userName} = mkUserScope userName "data";
        "/persist/users/${userName}/cache".users.${userName} = mkUserScope userName "cache";
      };

      systemPersistence = {
        ${systemRoot} = {
          hideMounts = true;
          directories = [
            "/etc/nixos"
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
            "/etc/NetworkManager/system-connections"
            "/tmp"
          ] ++ cfg.directories;
          files = [
            "/etc/machine-id"
          ] ++ cfg.files;
        };
      };
    in
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      persistence.enable = true;

      assertions = lib.mapAttrsToList (userName: user: {
        assertion = lib.all isRelativeEntry (
          user.data.directories
          ++ user.data.files
          ++ user.cache.directories
          ++ user.cache.files
        );
        message = "persistence.users.${userName} entries must be relative paths (or impermanence attribute sets), because they are mapped to /home/${userName}.";
      }) cfg.users;

      programs.fuse.userAllowOther = lib.mkIf cfg.enable true;
      boot.tmp.cleanOnBoot = lib.mkIf cfg.enable true;
      fileSystems."/persist".neededForBoot = lib.mkIf cfg.enable true;

      environment.persistence = lib.mkIf cfg.enable (
        lib.mkMerge (
          [ systemPersistence ]
          ++ map mkUserPersistence (builtins.attrNames cfg.users)
        )
      );
    };
}