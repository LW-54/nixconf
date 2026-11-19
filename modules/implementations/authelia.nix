{self, ...}: {
  /**
  Centralized SSO, forward authentication, and LDAP directory implementation via Authelia and LLDAP.
  */
  implementation.authelia = {
    contract = "auth";
    description = "Centralized SSO, forward authentication, 2FA, and LDAP directory implementation using Authelia and LLDAP.";
    module = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.auth;
      domain = config.reverse-proxy.domain or null;
      fqdnDomain =
        if domain != null
        then domain
        else "localhost";

      connectAddr = addr:
        if addr == "0.0.0.0" || addr == "::" || addr == "*"
        then "127.0.0.1"
        else addr;

      authConnectHost = connectAddr cfg.address;
      ldapConnectHost = connectAddr cfg.directory.address;

      baseDn =
        if cfg.directory.baseDn != null
        then cfg.directory.baseDn
        else if domain != null
        then lib.concatMapStringsSep "," (p: "dc=${p}") (lib.splitString "." domain)
        else "dc=example,dc=com";

      adminEmail =
        if cfg.directory.adminEmail != "admin@example.com"
        then cfg.directory.adminEmail
        else if (config.default-user.enable or false) && (config.default-user.email or "") != ""
        then config.default-user.email
        else if domain != null
        then "${cfg.directory.adminUser}@${domain}"
        else cfg.directory.adminEmail;

      authFqdn =
        if domain != null
        then "${cfg.subdomain}.${domain}"
        else null;

      lldapFqdn =
        if domain != null && cfg.directory.enable && cfg.directory.subdomain != null
        then "${cfg.directory.subdomain}.${domain}"
        else null;

      testAdminPassword = "nixconf-test-lldap-admin-password";

      # Escape regex metacharacters in Caddy glob patterns and translate `*` to `.*`.
      globToRegex = pattern: let
        escaped =
          builtins.replaceStrings
          ["\\" "." "+" "?" "(" ")" "[" "]" "{" "}" "^" "$" "|"]
          ["\\\\" "\\." "\\+" "\\?" "\\(" "\\)" "\\[" "\\]" "\\{" "\\}" "\\^" "\\$" "\\|"]
          pattern;
        withWildcard = builtins.replaceStrings ["*"] [".*"] escaped;
      in "^${withWildcard}$";

      bypassHosts =
        lib.filterAttrs
        (_: h: (h.forwardAuth or false) && (h.bypassPaths or []) != [])
        (config.reverse-proxy.hosts or {});

      bypassRules =
        lib.mapAttrsToList (hostFqdn: hostCfg: {
          domain = hostFqdn;
          policy = "bypass";
          resources = map globToRegex hostCfg.bypassPaths;
        })
        bypassHosts;

      explicitRules =
        map (
          r:
            {
              inherit (r) domain policy;
            }
            // lib.optionalAttrs (r.subject != []) {
              inherit (r) subject;
            }
            // lib.optionalAttrs (r.resources != []) {
              inherit (r) resources;
            }
        )
        (builtins.attrValues cfg.rules);

      catchAllRule = {
        domain =
          if domain != null
          then "*.${fqdnDomain}"
          else [fqdnDomain "*.${fqdnDomain}"];
        policy = cfg.defaultPolicy;
      };

      autheliaUser = config.services.authelia.instances.main.user;
      autheliaGroup = config.services.authelia.instances.main.group;

      lldapReadyScript = pkgs.writeShellScript "lldap-wait-ready" ''
        set -euo pipefail
        for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
          if (: < /dev/tcp/${ldapConnectHost}/${toString cfg.directory.ldapPort}) 2>/dev/null && \
             (: < /dev/tcp/${ldapConnectHost}/${toString cfg.directory.httpPort}) 2>/dev/null; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 0.25
        done
        echo "Timed out waiting for LLDAP ports ${toString cfg.directory.ldapPort} and ${toString cfg.directory.httpPort}" >&2
        exit 1
      '';
    in {
      assertions = [
        {
          assertion = cfg.directory.enable;
          message = "implementation.authelia currently requires `auth.directory.enable = true` (LLDAP backend).";
        }
        {
          assertion = cfg.subdomain != cfg.directory.subdomain;
          message = "auth.subdomain and auth.directory.subdomain must be distinct virtual host prefixes.";
        }
      ];

      users.groups.lldap = lib.mkIf cfg.directory.enable {};
      users.users.lldap = lib.mkIf cfg.directory.enable {
        isSystemUser = true;
        group = "lldap";
        home = "/var/lib/lldap";
      };

      secrets.files =
        {
          authelia-jwt-secret = {
            store = "services/auth";
            key = "autheliaJwtSecret";
            owner = autheliaUser;
            group = autheliaGroup;
            testValue = "nixconf-test-authelia-jwt-secret-0123456789abcdef";
          };
          authelia-session-secret = {
            store = "services/auth";
            key = "autheliaSessionSecret";
            owner = autheliaUser;
            group = autheliaGroup;
            testValue = "nixconf-test-authelia-session-secret-0123456789abcdef";
          };
          authelia-storage-encryption-key = {
            store = "services/auth";
            key = "autheliaStorageEncryptionKey";
            owner = autheliaUser;
            group = autheliaGroup;
            testValue = "nixconf-test-authelia-storage-encryption-key-0123456789";
          };
        }
        // lib.optionalAttrs cfg.directory.enable {
          lldap-admin-password = {
            store = "services/auth";
            key = "lldapAdminPassword";
            owner = "lldap";
            group = "lldap";
            testValue = testAdminPassword;
          };
          lldap-jwt-secret = {
            store = "services/auth";
            key = "lldapJwtSecret";
            owner = "lldap";
            group = "lldap";
            testValue = "nixconf-test-lldap-jwt-secret-0123456789abcdef";
          };
        };

      services.lldap = lib.mkIf cfg.directory.enable {
        enable = true;
        silenceForceUserPassResetWarning = true;
        environment = {
          LLDAP_JWT_SECRET_FILE = config.secrets.files.lldap-jwt-secret.path;
        };
        settings = {
          ldap_host = cfg.directory.address;
          ldap_port = cfg.directory.ldapPort;
          http_host = cfg.directory.address;
          http_port = cfg.directory.httpPort;
          http_url =
            if lldapFqdn != null
            then "https://${lldapFqdn}"
            else "http://${ldapConnectHost}:${toString cfg.directory.httpPort}";
          ldap_base_dn = baseDn;
          ldap_user_dn = cfg.directory.adminUser;
          ldap_user_email = adminEmail;
          ldap_user_pass_file = config.secrets.files.lldap-admin-password.path;
          force_ldap_user_pass_reset = "always";
          jwt_secret_file = config.secrets.files.lldap-jwt-secret.path;
        };
      };

      services.authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = config.secrets.files.authelia-jwt-secret.path;
          sessionSecretFile = config.secrets.files.authelia-session-secret.path;
          storageEncryptionKeyFile = config.secrets.files.authelia-storage-encryption-key.path;
        };
        environmentVariables = lib.optionalAttrs cfg.directory.enable {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldapPasswordFile";
        };
        settings = {
          theme = "auto";
          default_2fa_method = "totp";
          server = {
            address = "tcp://${cfg.address}:${toString cfg.port}/";
            endpoints.authz.forward-auth.implementation = "ForwardAuth";
          };
          log = {
            level = "info";
            format = "text";
          };
          totp = {
            disable = false;
            issuer = fqdnDomain;
          };
          webauthn = {
            disable = false;
            display_name = "Authelia (${fqdnDomain})";
          };
          authentication_backend = {
            password_reset.disable = false;
            refresh_interval = "1m";
            ldap = lib.mkIf cfg.directory.enable {
              implementation = "lldap";
              address = "ldap://${ldapConnectHost}:${toString cfg.directory.ldapPort}";
              timeout = "5s";
              start_tls = false;
              base_dn = baseDn;
              user = "uid=${cfg.directory.adminUser},ou=people,${baseDn}";
            };
          };
          session = {
            name = "authelia_session";
            same_site = "lax";
            inactivity = "1M";
            expiration = "3M";
            remember_me = "1y";
            cookies = [
              {
                domain = fqdnDomain;
                authelia_url = "https://${cfg.subdomain}.${fqdnDomain}";
              }
            ];
          };
          regulation = {
            max_retries = 5;
            find_time = "2m";
            ban_time = "5m";
          };
          storage.local.path = "/var/lib/authelia-main/db.sqlite3";
          notifier = {
            disable_startup_check = false;
            filesystem.filename = "/var/lib/authelia-main/notifications.txt";
          };
          access_control = {
            default_policy = "deny";
            rules = bypassRules ++ explicitRules ++ [catchAllRule];
          };
        };
      };

      systemd.services =
        (lib.optionalAttrs cfg.directory.enable {
          lldap = {
            after = ["sops-install-secrets.service"];
            wants = ["sops-install-secrets.service"];
            serviceConfig = {
              DynamicUser = lib.mkForce false;
              ExecStartPost = ["${lldapReadyScript}"];
            };
          };
        })
        // {
          authelia-main = {
            after = ["sops-install-secrets.service"] ++ lib.optional cfg.directory.enable "lldap.service";
            wants = ["sops-install-secrets.service"];
            requires = lib.optional cfg.directory.enable "lldap.service";
            serviceConfig = lib.optionalAttrs cfg.directory.enable {
              LoadCredential = ["ldapPasswordFile:${config.secrets.files.lldap-admin-password.path}"];
            };
          };
        };

      reverse-proxy = {
        forwardAuth = {
          enable = true;
          upstream = "${authConnectHost}:${toString cfg.port}";
          uri = "/api/authz/forward-auth";
        };
        ports =
          [
            {
              owner =
                if authFqdn != null
                then authFqdn
                else "auth";
              inherit (cfg) address port;
              protocol = "tcp";
            }
          ]
          ++ lib.optionals cfg.directory.enable [
            {
              owner =
                if lldapFqdn != null
                then lldapFqdn
                else "lldap-http";
              address = cfg.directory.address;
              port = cfg.directory.httpPort;
              protocol = "tcp";
            }
            {
              owner = "lldap-ldap";
              address = cfg.directory.address;
              port = cfg.directory.ldapPort;
              protocol = "tcp";
            }
          ];
        hosts = lib.mkIf ((config.reverse-proxy.enable or false) && domain != null) (
          {
            ${authFqdn} = {
              upstream = "${authConnectHost}:${toString cfg.port}";
              forwardAuth = false;
            };
          }
          // lib.optionalAttrs (lldapFqdn != null) {
            ${lldapFqdn} = {
              upstream = "${ldapConnectHost}:${toString cfg.directory.httpPort}";
              forwardAuth = false;
            };
          }
        );
      };

      persistence.directories = lib.mkIf (config.persistence.enable or false) (
        ["/var/lib/authelia-main"]
        ++ lib.optional cfg.directory.enable "/var/lib/lldap"
      );

      backup = lib.mkIf (config.backup.enable or false) {
        paths =
          ["/var/lib/authelia-main"]
          ++ lib.optional cfg.directory.enable "/var/lib/lldap";
        units =
          {
            authelia = {
              paths = ["/var/lib/authelia-main"];
              beforeUnits = ["authelia-main.service"];
            };
          }
          // lib.optionalAttrs cfg.directory.enable {
            lldap = {
              paths = ["/var/lib/lldap"];
              beforeUnits = ["lldap.service"];
            };
          };
      };

      testing.authelia = {
        description = "Authelia SSO, forward-auth middleware, and LLDAP directory verification";

        evalChecks = {
          forward-auth-wired = {
            assertion =
              (config.reverse-proxy.forwardAuth.enable or false)
              && (config.reverse-proxy.forwardAuth.upstream or null) == "${authConnectHost}:${toString cfg.port}";
            message = "`reverse-proxy.forwardAuth` must be enabled and point to Authelia's listener.";
          };

          auth-hosts-exempt = {
            assertion =
              (authFqdn == null || !(config.reverse-proxy.hosts.${authFqdn}.forwardAuth or false))
              && (lldapFqdn == null || !(config.reverse-proxy.hosts.${lldapFqdn}.forwardAuth or false));
            message = "Authelia and LLDAP web portals must not wrap themselves in `forwardAuth`.";
          };
        };

        inspectChecks = {
          authelia-unit = {
            description = "Verify authelia-main.service unit exists and generated config passes validate-config";
            script = ''
              ${self.lib.testing.mkInspectFile {
                path = "$etc/systemd/system/authelia-main.service";
                pattern = "validate-config";
              }}
              cfg_file="$(sed -n 's/^ExecStart=.*--config \([^ ,]*\).*/\1/p' "$etc/systemd/system/authelia-main.service")"
              test -n "$cfg_file" && test -r "$cfg_file"
              tmp_sec="$(mktemp)"
              trap 'rm -f "$tmp_sec"' EXIT
              printf 'nixconf-inspect-secret-0123456789abcdef' > "$tmp_sec"
              AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE="$tmp_sec" \
              AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE="$tmp_sec" \
              AUTHELIA_SESSION_SECRET_FILE="$tmp_sec" \
              AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE="$tmp_sec" \
                ${pkgs.authelia}/bin/authelia --config "$cfg_file" validate-config
            '';
          };

          lldap-unit = {
            description = "Verify lldap.service unit exists in system closure";
            script = self.lib.testing.mkInspectFile {
              path = "$etc/systemd/system/lldap.service";
              pattern = "lldap";
            };
          };

          caddy-forward-auth = {
            description = "Verify Caddyfile enforces forward_auth on protected services";
            script = lib.optionalString (config.reverse-proxy.enable or false) (
              self.lib.testing.mkInspectFile {
                path = "$etc/caddy/caddy_config";
                pattern = "forward_auth";
              }
            );
          };
        };

        vmChecks.sso = {
          description = "LLDAP and Authelia run, validate LDAP auth, and enforce forward-auth decisions";
          script = ''
            import datetime

            ${self.lib.testing.mkServiceCheck {unit = "lldap.service";}}
            ${self.lib.testing.mkServiceCheck {unit = "authelia-main.service";}}
            ${self.lib.testing.mkHttpCheck {
              port = cfg.directory.httpPort;
              host = ldapConnectHost;
            }}

            machine.wait_for_open_port(${toString cfg.port})
            machine.wait_until_succeeds(
                "curl -fsS http://${authConnectHost}:${toString cfg.port}/api/health",
                timeout=datetime.timedelta(seconds=30),
            )

            _unauth = machine.succeed(
                "curl -s -o /dev/null -w '%{http_code}' "
                "-H 'X-Forwarded-Proto: https' "
                "-H 'X-Forwarded-Host: test.${fqdnDomain}' "
                "-H 'X-Forwarded-Uri: /' "
                "-H 'X-Forwarded-Method: GET' "
                "http://${authConnectHost}:${toString cfg.port}/api/authz/forward-auth"
            ).strip()
            assert _unauth in ("302", "401"), f"Expected 302 or 401 for unauthenticated forward-auth, got {_unauth}"

            _authed = machine.succeed(
                "curl -fsSi "
                "-u '${cfg.directory.adminUser}:${testAdminPassword}' "
                "-H 'X-Forwarded-Proto: https' "
                "-H 'X-Forwarded-Host: test.${fqdnDomain}' "
                "-H 'X-Forwarded-Uri: /' "
                "-H 'X-Forwarded-Method: GET' "
                "http://${authConnectHost}:${toString cfg.port}/api/authz/forward-auth"
            )
            assert "Remote-User: ${cfg.directory.adminUser}" in _authed or "remote-user: ${cfg.directory.adminUser}" in _authed.lower(), f"Missing Remote-User header in Authelia response:\n{_authed}"
            assert "remote-groups: ${cfg.adminGroup}" in _authed.lower(), f"Missing Remote-Groups header in Authelia response:\n{_authed}"

            ${lib.optionalString ((config.services.copyparty-server.enable or false) && domain != null) ''
              _drop_status = machine.succeed(
                  "curl -s -o /dev/null -w '%{http_code}' "
                  "-H 'X-Forwarded-Proto: https' "
                  "-H 'X-Forwarded-Host: ${config.services.copyparty-server.subdomain}.${domain}' "
                  "-H 'X-Forwarded-Uri: /drop/' "
                  "-H 'X-Forwarded-Method: GET' "
                  "http://${authConnectHost}:${toString cfg.port}/api/authz/forward-auth"
              ).strip()
              assert _drop_status == "200", f"Expected 200 for bypassed copyparty /drop/ path, got {_drop_status}"
            ''}
          '';
        };
      };
    };
  };
}
