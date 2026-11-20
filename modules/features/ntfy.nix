{self, ...}: {
  feature.ntfy = {
    description = "Self-hosted push notification server (ntfy) with declarative admin credentials, metrics, probes, and Alertmanager wiring.";
    modules = {
      ntfy = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.ntfy-server;
        domain = config.reverse-proxy.domain or null;
        fqdn =
          if cfg.subdomain != null && domain != null
          then "${cfg.subdomain}.${domain}"
          else null;
        connectAddr = addr:
          if addr == "0.0.0.0" || addr == "::" || addr == "*"
          then "127.0.0.1"
          else addr;
        probeName =
          if fqdn != null
          then fqdn
          else "ntfy";
      in {
        options.services.ntfy-server =
          {
            enable = lib.mkEnableOption "ntfy self-hosted push notification service" // {default = true;};

            alertTopic = lib.mkOption {
              type = lib.types.str;
              default = "alerts";
              description = "Default topic receiving infrastructure Alertmanager webhook notifications.";
            };

            metricsPort = lib.mkOption {
              type = lib.types.port;
              default = self.lib.reverse-proxy.mkPort "ntfy-metrics";
              description = "Local TCP port exposing ntfy Prometheus metrics.";
            };
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "ntfy";
            forwardAuth = false;
            probe = false;
          }
          // self.lib.persistence.mkOption {
            directories = ["/var/lib/ntfy-sh"];
          }
          // self.lib.monitoring.mkOption {
            units = ["ntfy-sh.service"];
          }
          // self.lib.resources.mkOption {
            tier = "standard";
            memory = {
              high = "128M";
              max = "256M";
            };
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            users.groups.ntfy-sh = {};
            users.users.ntfy-sh = {
              isSystemUser = true;
              group = "ntfy-sh";
              home = "/var/lib/ntfy-sh";
            };

            secrets.files.ntfy-admin-password = {
              store = "services/auth";
              key = "lldapAdminPassword";
              owner = "ntfy-sh";
              group = "ntfy-sh";
              testValue = "nixconf-test-lldap-admin-password";
            };

            services.ntfy-sh = {
              enable = true;
              settings = {
                base-url =
                  if fqdn != null
                  then "https://${fqdn}"
                  else "http://${connectAddr cfg.address}:${toString cfg.port}";
                listen-http = "${cfg.address}:${toString cfg.port}";
                behind-proxy = fqdn != null;
                enable-signup = false;
                auth-default-access = "deny-all";
                auth-file = "/var/lib/ntfy-sh/user.db";
                cache-file = "/var/lib/ntfy-sh/cache.db";
                enable-metrics = true;
                metrics-listen-http = "127.0.0.1:${toString cfg.metricsPort}";
              };
            };

            systemd.services.ntfy-sh = {
              after = ["sops-install-secrets.service"];
              wants = ["sops-install-secrets.service"];
              serviceConfig = {
                DynamicUser = lib.mkForce false;
                User = "ntfy-sh";
                Group = "ntfy-sh";
                StateDirectory = "ntfy-sh";
                StateDirectoryMode = "0700";
              };
              postStart = ''
                for _ in $(${pkgs.coreutils}/bin/seq 1 75); do
                  if ${pkgs.curl}/bin/curl -fsS "http://${connectAddr cfg.address}:${toString cfg.port}/v1/health" >/dev/null 2>&1; then
                    break
                  fi
                  ${pkgs.coreutils}/bin/sleep 0.2
                done
                export NTFY_AUTH_FILE=/var/lib/ntfy-sh/user.db
                export NTFY_PASSWORD="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.secrets.files.ntfy-admin-password.path})"
                ${pkgs.ntfy-sh}/bin/ntfy user add --role=admin --ignore-exists admin
                ${pkgs.ntfy-sh}/bin/ntfy user change-pass admin
              '';
            };

            reverse-proxy.ports = [
              {
                owner = "ntfy-metrics";
                address = "127.0.0.1";
                port = cfg.metricsPort;
                protocol = "tcp";
              }
            ];

            monitoring = lib.mkIf (config.monitoring.enable or false) {
              scrapes.ntfy = {
                address = "127.0.0.1";
                port = cfg.metricsPort;
                metricsPath = "/metrics";
              };
              probes.${probeName} = {
                target = "http://${connectAddr cfg.address}:${toString cfg.port}/v1/health";
                module = "http_2xx";
                labels = lib.optionalAttrs (fqdn != null) {vhost = fqdn;};
              };
              server.alerts.ntfy = lib.mkIf (config.monitoring.server.enable or false) {
                enable = lib.mkDefault true;
                url = lib.mkDefault "http://${connectAddr cfg.address}:${toString cfg.port}/${cfg.alertTopic}?template=alertmanager";
                username = lib.mkDefault "admin";
                passwordFile = lib.mkDefault config.secrets.files.ntfy-admin-password.path;
              };
            };

            testing.ntfy = {
              description = "Verify ntfy server starts cleanly and responds to /v1/health";
              vmChecks.service = {
                description = "ntfy-sh.service is active and serves HTTP 200 on /v1/health";
                script = ''
                  ${self.lib.testing.mkServiceCheck {unit = "ntfy-sh.service";}}
                  ${self.lib.testing.mkHttpCheck {
                    inherit (cfg) port;
                    host = connectAddr cfg.address;
                    path = "/v1/health";
                  }}

                  _ntfy_unauth = machine.succeed(
                      "curl -s -o /dev/null -w '%{http_code}' -d 'test' "
                      "http://${connectAddr cfg.address}:${toString cfg.port}/${cfg.alertTopic}"
                  ).strip()
                  assert _ntfy_unauth in ("401", "403"), f"Expected unauthenticated ntfy publish to be denied, got {_ntfy_unauth}"
                  _ntfy_auth = machine.succeed(
                      "pw=$(cat ${config.secrets.files.ntfy-admin-password.path}) && "
                      "curl -s -o /dev/null -w '%{http_code}' -u \"admin:$pw\" -d 'vm-test' "
                      "http://${connectAddr cfg.address}:${toString cfg.port}/${cfg.alertTopic}"
                  ).strip()
                  assert _ntfy_auth == "200", f"Expected authenticated ntfy publish to succeed, got {_ntfy_auth}"
                '';
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {inherit config cfg;})
          (self.lib.monitoring.mkConfig {
            inherit config cfg;
            name = "ntfy";
          })
          (self.lib.resources.mkConfig {inherit config cfg;})
        ]);
      };
    };
  };
}
