{self, ...}: {
  perSystem = {pkgs, ...}: {
    packages.bw = pkgs.writeShellApplication {
      name = "bw";
      runtimeInputs = [pkgs.bitwarden-cli];
      text = ''
        config_dir="''${HOME}/.config/Bitwarden CLI"
        data_file="''${config_dir}/data.json"

        if [[ ! -e "''${data_file}" ]]; then
          mkdir -p "''${config_dir}"
          ${pkgs.bitwarden-cli}/bin/bw config server "https://vaultwarden.adje.app" >/dev/null
        fi

        exec ${pkgs.bitwarden-cli}/bin/bw "$@"
      '';
    };
  };

  flake.nixosModules.bw = {
    config,
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = [self.packages.${pkgs.system}.bw];

    persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      data.directories = [".config/Bitwarden CLI"];
    };
  };

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
}
