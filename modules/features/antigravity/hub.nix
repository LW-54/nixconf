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
    tokenPath = "/home/${cfg.user}/.gemini/antigravity-cli/antigravity-oauth-token";
    domain = config.reverse-proxy.domain or null;
    loginFqdn =
      if cfg.loginSubdomain != null && domain != null
      then "${cfg.loginSubdomain}.${domain}"
      else null;

    discoveredPeers = builtins.listToAttrs (
      lib.concatMap (
        hostName: let
          peerCfg = self.nixosConfigurations.${hostName}.config;
          rc = peerCfg.services.agy-remote-control or {};
        in
          lib.optional (rc.enable or false) {
            name = hostName;
            value.sshTarget = "${rc.user or cfg.user}@${hostName}";
          }
      ) (lib.filter (h: h != config.networking.hostName) (builtins.attrNames (self.nixosConfigurations or {})))
    );

    loginScript = pkgs.writeShellScript "agy-login-tty" ''
      set -euo pipefail
      echo "=== Antigravity OAuth Login (${config.networking.hostName}) ==="
      if [ -s ${lib.escapeShellArg tokenPath} ]; then
        echo "An OAuth token already exists at ${tokenPath}."
        echo "To force a fresh login, press 'r' then Enter; otherwise press Enter to launch agy."
        read -r choice || true
        if [ "''${choice:-}" = "r" ] || [ "''${choice:-}" = "R" ]; then
          rm -f ${lib.escapeShellArg tokenPath}
          echo "Removed old token."
        fi
      fi
      echo ""
      echo "Launching agy — complete the Google sign-in prompt, then exit (/quit or Ctrl+D)."
      echo "Once authenticated, agy-remote-control.service starts automatically."
      echo ""
      ${self.packages.${pkgs.stdenv.hostPlatform.system}.agy}/bin/agy || true
      echo ""
      if [ -s ${lib.escapeShellArg tokenPath} ]; then
        echo "Token detected! Return to:"
        ${lib.optionalString (cfg.subdomain != null && domain != null) ''echo "  Hub:    https://${cfg.subdomain}.${domain}"''}
        echo "  Remote: ${cfg.remoteUrl}"
      else
        echo "No token written yet. Refresh this page to retry."
      fi
      echo ""
      read -r -p "Press Enter to close..." _ || true
    '';
  in {
    key = "nixconf:agy-hub";

    options.services.agy-hub =
      {
        enable = lib.mkEnableOption "Antigravity Remote Control Rust monitoring/control hub and browser OAuth login terminal" // {default = true;};

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
          description = "System user to run the hub and browser OAuth login terminal as.";
        };

        remoteUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://antigravity.google.com/remote";
          description = "Target URL for the Antigravity Remote Control web interface.";
        };

        loginSubdomain = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "agy-login";
          description = "Subdomain serving the Authelia-protected browser OAuth login terminal.";
        };

        loginPort = lib.mkOption {
          type = lib.types.port;
          default = self.lib.reverse-proxy.mkPort "agy-login";
          description = "Local port for the dedicated browser OAuth login ttyd instance.";
        };

        peers = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options.sshTarget = lib.mkOption {
              type = lib.types.str;
              example = "lw@x240";
              description = "SSH target (`user@host`) polled by the hub when reachable.";
            };
          });
          default = discoveredPeers;
          description = "Remote hosts probed over SSH by the hub dashboard (auto-discovered from `self.nixosConfigurations` by default).";
        };
      }
      // self.lib.reverse-proxy.mkOption {
        subdomain = "agy";
        forwardAuth = true;
      }
      // self.lib.monitoring.mkOption {
        units = ["agy-hub.service" "agy-login-tty.service"];
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
              "AGY_HUB_ADDR=${cfg.address}:${toString cfg.port}"
              "AGY_HUB_HOST=${config.networking.hostName}"
              "AGY_HUB_HOME=/home/${cfg.user}"
              "AGY_HUB_REMOTE_URL=${cfg.remoteUrl}"
              "AGY_HUB_LOGIN_URL=${lib.optionalString (loginFqdn != null) "https://${loginFqdn}"}"
              "AGY_HUB_PEERS=${lib.concatStringsSep "," (lib.mapAttrsToList (n: p: "${n}=${p.sshTarget}") cfg.peers)}"
              "AGY_HUB_SYSTEMCTL=${pkgs.systemd}/bin/systemctl"
              "AGY_HUB_SUDO=/run/wrappers/bin/sudo"
              "AGY_HUB_SSH=${pkgs.openssh}/bin/ssh"
            ];
            ExecStart = "${mkHubPackage pkgs}/bin/agy-hub";
            Restart = "always";
            RestartSec = "3s";
          };
        };

        systemd.services.agy-login-tty = {
          description = "Antigravity browser OAuth login terminal";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            WorkingDirectory = "/home/${cfg.user}";
            Environment = [
              "HOME=/home/${cfg.user}"
              "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
            ];
            ExecStart = "${pkgs.ttyd}/bin/ttyd -i ${cfg.address} -p ${toString cfg.loginPort} -W ${loginScript}";
            Restart = "always";
            RestartSec = "3s";
          };
        };
      }
      (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
      (lib.mkIf ((config.reverse-proxy.enable or false) && loginFqdn != null) {
        reverse-proxy = {
          ports = [
            {
              owner = loginFqdn;
              inherit (cfg) address;
              port = cfg.loginPort;
              protocol = "tcp";
            }
          ];
          hosts.${loginFqdn} = {
            upstream = "${cfg.address}:${toString cfg.loginPort}";
            forwardAuth = true;
          };
        };
      })
      (self.lib.monitoring.mkConfig {
        inherit config;
        cfg =
          cfg
          // {
            monitoring =
              cfg.monitoring
              // {
                metrics = {
                  enable = true;
                  inherit (cfg) address port;
                  path = "/metrics";
                };
              };
          };
        name = "agy-hub";
      })
      (self.lib.resources.mkConfig {inherit config cfg;})
    ]);
  };
}
