{
  config,
  self,
  ...
}: let
  configModule = config.internal.antigravity.configModule;
in {
  internal.antigravity.remoteControlModule = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.agy-remote-control;
    tokenPath = "/home/${cfg.user}/.gemini/antigravity-cli/antigravity-oauth-token";
  in {
    key = "nixconf:agy-remote-control";
    imports = [configModule];

    options.services.agy-remote-control =
      {
        enable = lib.mkEnableOption "automatic agy remote-control background daemon" // {default = true;};

        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          apply = user:
            if user == null
            then let
              normalNames = self.lib.user.normalUserNames config;
            in
              if normalNames != []
              then builtins.head normalNames
              else "root"
            else user;
          description = "System user to run the `agy remote-control` daemon as.";
        };

        instanceName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Machine instance name displayed in the Antigravity Remote Control web dashboard.";
        };
      }
      // self.lib.monitoring.mkOption {
        units = ["agy-remote-control.service"];
      }
      // self.lib.resources.mkOption {
        tier = "background";
        memory = {
          high = "25%";
          max = "40%";
        };
      };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        home.shared.files.".gemini/antigravity-cli/remote-control-name".text = "${cfg.instanceName}\n";

        systemd.services.agy-remote-control = {
          description = "Antigravity CLI remote-control daemon (${cfg.instanceName})";
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
          unitConfig.ConditionPathExists = tokenPath;
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            WorkingDirectory = "/home/${cfg.user}";
            Environment = [
              "HOME=/home/${cfg.user}"
              "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
            ];
            ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.agy}/bin/agy remote-control serve";
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStopSec = "30s";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        systemd.paths.agy-remote-control = {
          description = "Watch for Antigravity OAuth token to start remote-control daemon";
          wantedBy = ["multi-user.target"];
          pathConfig = {
            PathExists = tokenPath;
            Unit = "agy-remote-control.service";
          };
        };
      }
      (self.lib.monitoring.mkConfig {
        inherit config cfg;
        name = "agy-remote-control";
      })
      (self.lib.resources.mkConfig {inherit config cfg;})
    ]);
  };
}
