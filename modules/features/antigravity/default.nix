{
  config,
  lib,
  self,
  ...
}: let
  helpers = config.internal.antigravity;
in {
  options.internal.antigravity = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal modular builders for Antigravity CLI, configuration, remote-control daemon, hub, and packages.";
  };

  config.feature.antigravity = {
    description = "Modular Google Antigravity CLI (agy), declarative config/rules, remote-control daemon, Rust hub, desktop/IDE packages, and Gemini API shell.";

    modules = {
      agy = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.agy;
        normalNames = self.lib.user.normalUserNames config;
        backupUser =
          if normalNames != []
          then builtins.head normalNames
          else "root";
      in {
        key = "nixconf:agy";
        imports = [
          helpers.configModule
          helpers.remoteControlModule
        ];

        options.agy = {
          enable = lib.mkEnableOption "Antigravity CLI (agy)" // {default = true;};

          package = lib.mkOption {
            type = lib.types.package;
            default = self.packages.${pkgs.stdenv.hostPlatform.system}.agy;
            description = "Antigravity CLI package to install.";
          };
        };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            environment.systemPackages = [cfg.package];

            # Materialize system CA bundles as regular files instead of symlinks through
            # /etc/static so Linux mount-namespace sandboxes (agy's sbox localcert) can
            # read and bind-mount over them without /etc/static mounted.
            environment.etc."ssl/certs/ca-certificates.crt".mode = "0444";
            environment.etc."pki/tls/certs/ca-bundle.crt".mode = "0444";

            persistence.users = self.lib.user.forNormalUsers config (_: _: {
              data.directories = [".gemini"];
            });
          }
          (lib.mkIf (config.backup.enable or false) {
            backup.units.agy = {
              enable = lib.mkDefault true;
              paths = ["/home/${backupUser}/.gemini"];
              exclude = [
                "**/cache/**"
                "**/tmp/**"
                "**/log/**"
                "**/crashes/**"
              ];
              autoRestore = lib.mkDefault false;
              beforeUnits = lib.optional (config.services.agy-remote-control.enable or false) "agy-remote-control.service";
            };
          })
        ]);
      };

      agy-config = helpers.configModule;
      agy-remote-control = helpers.remoteControlModule;
      agy-hub = helpers.hubModule;
    };

    inherit (helpers) packages devShells;
  };
}
