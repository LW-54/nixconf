{ self, inputs, ... }:

{
  flake.nixosModules.impermanence = { lib, config, ... }:
    let
      cfg = config.persistence;
      userNames = builtins.attrNames cfg.users;
      users = cfg.users;
      systemRoot = "/persist/system";

      isRelativeEntry = entry:
        if builtins.isString entry then
          !(lib.hasPrefix "/" entry)
        else
          true;

      userEntries = userName:
        users.${userName}.data.directories
        ++ users.${userName}.data.files
        ++ users.${userName}.cache.directories
        ++ users.${userName}.cache.files;

      userScope = userName: scope:
        {
          directories = users.${userName}.${scope}.directories;
          files = users.${userName}.${scope}.files;
        };

      mkUserPersistence = userName: {
        environment.persistence."/persist/users/${userName}/userdata".users.${userName} = userScope userName "data";
        environment.persistence."/persist/users/${userName}/usercache".users.${userName} = userScope userName "cache";
      };
    in
    {
      imports = [
        self.nixosModules.persistence
        inputs.impermanence.nixosModules.impermanence
      ];

      config.persistence.enable = lib.mkDefault true;

      assertions =
        map (userName: {
          assertion = lib.all isRelativeEntry (userEntries userName);
          message = "persistence.users.${userName} entries must be relative paths (or impermanence attribute sets), because they are mapped to /home/${userName}.";
        }) userNames;

      config = lib.mkIf cfg.enable (lib.mkMerge (
        [
          {
            programs.fuse.userAllowOther = true;
            boot.tmp.cleanOnBoot = lib.mkDefault true;
            fileSystems."/persist".neededForBoot = lib.mkDefault true;

            environment.persistence.${systemRoot} = {
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
          }
        ]
        ++ map mkUserPersistence userNames
      ));
    };
}
