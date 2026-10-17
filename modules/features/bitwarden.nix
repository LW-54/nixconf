{self, ...}: {
  flake.nixosModules.bitwarden-desktop = {
    config,
    lib,
    ...
  }: let
    cfg = config.bitwarden-desktop;
  in {
    imports = [
      (self.lib.mkUserFeature {
        inherit lib;
        name = "bitwarden-desktop";
        description = "Bitwarden Desktop";
        package = pkgs: pkgs.bitwarden-desktop;
      })
    ];

    config.persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        self.lib.resolveUserOption {
          inherit lib;
          global = cfg.enable;
          users = cfg.users;
          inherit userName;
          path = ["enable"];
        };
      data.directories = [".config/Bitwarden"];
      cache.directories = [".cache/com.bitwarden.desktop"];
    };
  };

  flake.nixosModules.bw = {pkgs, ...}: {
    environment.systemPackages = [pkgs.bitwarden-cli];
  };
}
