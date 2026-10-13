{ self, inputs, ... }:
{
  flake.nixosModules.helium = { config, lib, ... }:
    let
      cfg = config.helium;
    in
    {
      imports = [
        inputs.helium.nixosModules.default
        (self.lib.mkHjemUserProjection {
          inherit lib;
          name = "helium";
          description = "Helium Browser";
          userOptions = {
            enable = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether this user receives Helium, overriding helium.enable.";
            };

            flags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional flags for this user.";
            };
          };

          userEnabled = args:
            let override = lib.attrByPath [ args.name "enable" ] null args.cfg.users;
            in if override == null then args.cfg.enable else override;

          userModule = { cfg, user, config, lib, ... }:
            let
              flags = cfg.flags ++ (user.flags or [ ]);
            in
            {
              packages = lib.optional (!cfg.enable) config.programs.helium.package;
              files.".config/helium-browser-flags.conf" = lib.mkIf
                (flags != [ ])
                { text = lib.concatStringsSep "\n" flags; };
            };
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
            };
          data = {
            directories = [ ".config/net.imput.helium" ];
          };
        };

      options.helium = {
        enable = lib.mkEnableOption "Helium Browser" // {
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
      };

      config.programs.helium = {
        enable = cfg.enable;
        flags = cfg.flags;
        policies = cfg.policies;
      };
    };
}
