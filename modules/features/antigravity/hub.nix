{self, ...}: let
  mkHubPackage = pkgs:
    pkgs.runCommandCC "agy-hub" {
      nativeBuildInputs = [pkgs.rustc];
    } ''
      mkdir -p "$out/bin"
      rustc -O -C strip=symbols ${./hub.rs} -o "$out/bin/agy-hub"
    '';
in {
  internal.antigravity.hubModule = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.agy-hub;
    domain = config.reverse-proxy.domain or null;
    vmPort = config.monitoring.server.metrics.port or null;
    grafanaSub = config.monitoring.server.grafana.subdomain or null;

    knownHosts = lib.filter (
      hostName:
        hostName
        != config.networking.hostName
        && (self.nixosConfigurations.${hostName}.config.services.agy-remote-control.enable or false)
    ) (builtins.attrNames (self.nixosConfigurations or {}));
  in {
    key = "nixconf:agy-hub";

    options.services.agy-hub =
      {
        enable = lib.mkEnableOption "Antigravity Remote Control Rust monitoring and control hub" // {default = true;};

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
          description = "System user to run the hub and local OAuth login flow as.";
        };

        remoteUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://antigravity.google.com/remote";
          description = "Target URL for the Antigravity Remote Control web interface.";
        };
      }
      // self.lib.reverse-proxy.mkOption {
        subdomain = "agy";
        forwardAuth = true;
      }
      // self.lib.monitoring.mkOption {
        units = ["agy-hub.service"];
      }
      // self.lib.resources.mkOption {
        tier = "standard";
        memory = {
          high = "10%";
          max = "20%";
        };
      };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        security.sudo.extraRules = [
          {
            users = [cfg.user];
            commands = map (action: {
              command = "${pkgs.systemd}/bin/systemctl ${action} agy-remote-control.service";
              options = ["NOPASSWD"];
            }) ["start" "stop" "restart"];
          }
        ];

        systemd.services.agy-hub = {
          description = "Antigravity Remote Control Rust monitoring and control hub";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            WorkingDirectory = "/home/${cfg.user}";
            Environment = [
              "HOME=/home/${cfg.user}"
              "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
              "AGY_HUB_ADDR=${cfg.address}:${toString cfg.port}"
              "AGY_HUB_HOST=${config.networking.hostName}"
              "AGY_HUB_HOME=/home/${cfg.user}"
              "AGY_HUB_REMOTE_URL=${cfg.remoteUrl}"
              "AGY_HUB_GRAFANA_URL=${lib.optionalString (grafanaSub != null && domain != null) "https://${grafanaSub}.${domain}"}"
              "AGY_HUB_VM_ADDR=${lib.optionalString (vmPort != null) "127.0.0.1:${toString vmPort}"}"
              "AGY_HUB_KNOWN_HOSTS=${lib.concatStringsSep "," knownHosts}"
              "AGY_HUB_AGY_BIN=${self.packages.${pkgs.stdenv.hostPlatform.system}.agy}/bin/agy"
              "AGY_HUB_SYSTEMCTL=${pkgs.systemd}/bin/systemctl"
              "AGY_HUB_SUDO=/run/wrappers/bin/sudo"
              "AGY_HUB_DATE=${pkgs.coreutils}/bin/date"
            ];
            ExecStart = "${mkHubPackage pkgs}/bin/agy-hub";
            Restart = "always";
            RestartSec = "3s";
          };
        };
      }
      (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
      (self.lib.monitoring.mkConfig {
        inherit config cfg;
        name = "agy-hub";
      })
      (self.lib.resources.mkConfig {inherit config cfg;})
    ]);
  };
}
