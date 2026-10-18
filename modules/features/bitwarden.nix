{
  self,
  lib,
  ...
}: {
  flake.nixosModules.bw = {
    config,
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = [self.packages.${pkgs.system}.bw];

    persistence.users = self.lib.users.mkPersistence {
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
      (self.lib.users.mkFeature {
        inherit lib;
        name = "bitwarden-desktop";
        description = "Bitwarden Desktop";
        package = pkgs: pkgs.bitwarden-desktop;
      })
    ];

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = cfg.enable;
      userOverrides = cfg.users;
      data.directories = [".config/Bitwarden"];
      cache.directories = [".cache/com.bitwarden.desktop"];
    };
  };

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

  flake.lib.bitwarden.mkShell = args @ {
    pkgs,
    bw,
    ...
  }:
    pkgs.mkShell (
      builtins.removeAttrs args ["pkgs"]
      // {
        packages =
          (args.packages or [])
          ++ [
            bw
            pkgs.jq
          ];
      }
    );

  flake.lib.bitwarden.mkValue = {
    itemId,
    jqFilter,
    variable ? null,
    exportVariable ? true,
    bw ? "bw",
    jq ? "jq",
  }:
    lib.trim ''
      case "$(${bw} status | ${jq} -r '.status')" in
        unlocked)
          ;;
        locked)
          BW_SESSION="$(${bw} unlock --raw </dev/tty)"
          export BW_SESSION
          ;;
        unauthenticated)
          ${bw} login </dev/tty >/dev/tty
          BW_SESSION="$(${bw} unlock --raw </dev/tty)"
          export BW_SESSION
          ;;
        *)
          printf 'Unable to determine Bitwarden session state.\n' >&2
          exit 1
          ;;
      esac

      ${
        let
          value = "${bw} get item ${itemId} | ${jq} -e -r '${jqFilter}'";
        in
          if variable == null
          then value
          else ''${lib.optionalString exportVariable "export "}${variable}="$(${value})"''
      }
    '';
}
