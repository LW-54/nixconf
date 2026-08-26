{self, ...}: {
  flake.nixosModules.user = {lib, config, pkgs, ...}: {
    options.preferences = {
      user.name = lib.mkOption {
        type = lib.types.str;
        default = "lw";
      };
    };

    config = {
      users.users.${config.preferences.user.name} = {
        isNormalUser = true;
        description = "${config.preferences.user.name}'s account";
        extraGroups = ["wheel" "networkmanager"];
        shell = self.packages.${pkgs.system}.environment;
      };
    };
  };
}