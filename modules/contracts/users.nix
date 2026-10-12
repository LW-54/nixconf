{ inputs, ... }:
{
  flake.nixosModules.users = { config, lib, ... }:
    let
      cfg = config.users.defaultUser;
    in
    {
      options.users.defaultUser = {
        enable = lib.mkEnableOption "the default local user" // {
          default = true;
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "lw";
          description = "Username created when no host-specific user is declared.";
        };
      };

      imports = [
        inputs.hjem.nixosModules.default
      ];

      config = lib.mkIf cfg.enable {
        users.users.${cfg.name} = {
          isNormalUser = lib.mkDefault true;
          description = lib.mkDefault "${cfg.name}'s account";
          extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
        };

        hjem.users.${cfg.name}.enable = lib.mkDefault true;
        hjem.clobberByDefault = true;
/*
        persistence.users.${cfg.name}.data.directories = lib.mkDefault [
            "nixconf"
            "Documents" 
            "Downloads"
            "Projects"
        ];*/
      };
    };
}
