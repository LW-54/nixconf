{
  self,
  lib,
  ...
}: let
  /**
  Creates a development shell pre-configured with Bitwarden CLI and jq for secrets manipulation.

  # Inputs

  `pkgs`
  : Package set supplying jq and shell dependencies.

  `bw`
  : Wrapped Bitwarden CLI package derivation.

  # Type
  ```
  mkShell :: AttrSet -> Derivation
  ```

  # Examples
  ```nix
  bitwarden.mkShell {
    inherit pkgs;
    bw = pkgs.bitwarden-cli;
  }
  ```
  */
  mkShell = args @ {
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

  /**
  Generates a bash snippet that retrieves and optionally exports a Bitwarden vault value via jq.

  # Inputs

  `itemId`
  : Bitwarden vault item UUID.

  `jqFilter`
  : jq filter expression extracting the required field.

  `variable`
  : Environment variable name to store the secret into (optional).

  `exportVariable`
  : Whether to export the assigned environment variable (default: true).

  `bw`
  : Path or executable name for Bitwarden CLI binary (default: "bw").

  `jq`
  : Path or executable name for jq binary (default: "jq").

  # Type
  ```
  mkValue :: AttrSet -> String
  ```

  # Examples
  ```nix
  bitwarden.mkValue {
    itemId = "00000000-0000-0000-0000-000000000000";
    jqFilter = ".login.password";
  }
  ```
  */
  mkValue = {
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
in {
  feature.bitwarden = {
    description = "Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers.";

    modules = {
      bw = {
        config,
        lib,
        pkgs,
        ...
      }: {
        environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.bw];

        persistence.users = lib.mapAttrs (_: _: {
          data.directories = [".config/Bitwarden CLI"];
        }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
      };

      bitwarden-desktop = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.bitwarden-desktop;
      in {
        options.bitwarden-desktop.enable = lib.mkEnableOption "Bitwarden Desktop" // {default = true;};

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [pkgs.bitwarden-desktop];

          persistence.users = lib.mapAttrs (_: _: {
            data.directories = [".config/Bitwarden"];
            cache.directories = [".cache/com.bitwarden.desktop"];
          }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
        };
      };
    };

    packages = {pkgs, ...}: {
      bw = pkgs.writeShellApplication {
        name = "bw";
        runtimeInputs = [pkgs.bitwarden-cli];
        meta.description = "Bitwarden CLI wrapper providing automated server configuration and session management.";
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

    lib = {
      mkShell = {
        docstring = ''
          Creates a development shell pre-configured with Bitwarden CLI and jq for secrets manipulation.

          # Inputs

          `pkgs`
          : Package set supplying jq and shell dependencies.

          `bw`
          : Wrapped Bitwarden CLI package derivation.

          # Type
          ```
          mkShell :: AttrSet -> Derivation
          ```

          # Examples
          ```nix
          bitwarden.mkShell {
            inherit pkgs;
            bw = pkgs.bitwarden-cli;
          }
          ```
        '';
        value = mkShell;
      };

      mkValue = {
        docstring = ''
          Generates a bash snippet that retrieves and optionally exports a Bitwarden vault value via jq.

          # Inputs

          `itemId`
          : Bitwarden vault item UUID.

          `jqFilter`
          : jq filter expression extracting the required field.

          `variable`
          : Environment variable name to store the secret into (optional).

          `exportVariable`
          : Whether to export the assigned environment variable (default: true).

          `bw`
          : Path or executable name for Bitwarden CLI binary (default: "bw").

          `jq`
          : Path or executable name for jq binary (default: "jq").

          # Type
          ```
          mkValue :: AttrSet -> String
          ```

          # Examples
          ```nix
          bitwarden.mkValue {
            itemId = "00000000-0000-0000-0000-000000000000";
            jqFilter = ".login.password";
          }
          ```
        '';
        value = mkValue;
      };
    };
  };
}
