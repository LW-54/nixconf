{
  self,
  inputs,
  ...
}: {
  feature.helium = {
    description = "Helium web browser with custom runtime flags and enterprise policy management.";
    modules = {
      helium = {
        config,
        lib,
        ...
      }: let
        cfg = config.helium;
      in {
        imports = [
          inputs.helium.nixosModules.default
        ];

        options.helium = {
          enable = lib.mkEnableOption "Helium Browser" // {default = true;};

          flags = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "--enable-features=UseOzonePlatform"
              "--ozone-platform-hint=auto"
            ];
            description = "Command-line flags inherited by Helium users.";
          };

          users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                flags = lib.mkOption {
                  type = lib.types.nullOr (lib.types.listOf lib.types.str);
                  default = null;
                  description = "User-specific command-line flags overriding global defaults.";
                };
              };
            });
            default = {};
            description = "Per-user Helium overrides.";
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
        };

        config = lib.mkIf cfg.enable {
          programs.helium = {
            enable = true;
            inherit (cfg) flags policies;
          };

          home.shared = lib.mkIf (cfg.flags != []) {
            files = {
              ".config/helium-browser-flags.conf".text = lib.concatStringsSep "\n" cfg.flags;
            };
          };

          home.users = lib.mapAttrs (userName: uCfg:
            lib.mkIf (uCfg.flags != null) {
              files.".config/helium-browser-flags.conf".text = lib.concatStringsSep "\n" uCfg.flags;
            })
          cfg.users;

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [".config/net.imput.helium"];
          });
        };
      };
    };
  };
}
