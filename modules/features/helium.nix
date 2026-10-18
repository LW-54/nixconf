{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.helium = {
    config,
    lib,
    ...
  }: let
    cfg = config.helium;
  in {
    imports = [
      inputs.helium.nixosModules.default
    ];

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = cfg.enable;
      userOverrides = cfg.users;
      data = {
        directories = [".config/net.imput.helium"];
      };
    };

    options.helium = {
      enable =
        lib.mkEnableOption "Helium Browser"
        // {
          default = true;
        };

      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform-hint=auto"
        ];
        description = "Command-line flags inherited by Helium users.";
      };

      policies = lib.mkOption {
        type = lib.types.attrs;
        default = {
          ExtensionInstallForcelist = [
            "nngceckbapebfimnlniiiahkandclblb"
          ];
        };
        description = "System-wide Helium enterprise policies.";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether this user receives Helium, overriding helium.enable.";
            };
            flags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Additional flags for this user.";
            };
          };
        });
        default = {};
        description = "Per-user Helium overrides.";
      };
    };

    config = {
      programs.helium = {
        enable = cfg.enable;
        flags = cfg.flags;
        policies = cfg.policies;
      };
      users.home =
        lib.mapAttrs (
          userName: _: let
            user = lib.attrByPath [userName] {} cfg.users;
            enabled =
              self.lib.users.mkUserEnabled {
                inherit lib;
                global = cfg.enable;
                users = cfg.users;
              }
              userName;
            flags = cfg.flags ++ (user.flags or []);
          in {
            packages = lib.optional (!cfg.enable) config.programs.helium.package;
            files = lib.optionalAttrs (enabled && flags != []) {
              ".config/helium-browser-flags.conf".text = lib.concatStringsSep "\n" flags;
            };
          }
        ) (lib.filterAttrs (userName: _:
          (self.lib.users.mkUserEnabled {
            inherit lib;
            global = cfg.enable;
            users = cfg.users;
          })
          userName)
        config.users.account);
    };
  };
}
