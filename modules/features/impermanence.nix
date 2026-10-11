{ self, inputs, ... }:

{
  flake.nixosModules.impermanence = { lib, config, ... }:
    let
      cfg = config.persistence;
      userNames = builtins.attrNames cfg.users;

      isRelativeEntry = entry:
        if builtins.isString entry then
          !(lib.hasPrefix "/" entry)
        else
          true;

      userEntries = userName:
        let
          userCfg = cfg.users.${userName};
        in
        userCfg.data.directories
        ++ userCfg.data.files
        ++ userCfg.cache.directories
        ++ userCfg.cache.files;
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      assertions =
        map (userName: {
          assertion = lib.all isRelativeEntry (userEntries userName);
          message = "persistence.users.${userName} entries must be relative paths (or impermanence attribute sets), because they are mapped to /home/${userName}.";
        }) userNames;

      config = lib.mkIf cfg.enable (lib.mkMerge (
        [
          {
            fileSystems."/persist".neededForBoot = lib.mkDefault true;

            environment.persistence."/persist/system" = {
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
        ++ map (userName:
          let
            userCfg = cfg.users.${userName};
          in
          {
            environment.persistence."/persist/users/${userName}/userdata".users.${userName} = {
              directories = userCfg.data.directories;
              files = userCfg.data.files;
            };

            environment.persistence."/persist/users/${userName}/usercache".users.${userName} = {
              directories = userCfg.cache.directories;
              files = userCfg.cache.files;
            };
          }) userNames
      ));
    };
}
