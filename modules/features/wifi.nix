{ self, ... }:

{
  flake.nixosModules.wifi-rez = { config, lib, pkgs, ... }:
    let
      cfg = config.services.wifi-rez;
      loginScript = config.sops.templates."wifi-rez-login".path;
      usernameSecret = "wifi-rez-username";
      passwordSecret = "wifi-rez-password";
      dispatcherScript = pkgs.writeShellScript "wifi-rez-dispatcher" ''
        if [[ "''${2:-}" != "up" || "''${CONNECTION_ID:-}" != "${cfg.ssid}" ]]; then
          exit 0
        fi

        ${pkgs.systemd}/bin/systemctl start --no-block wifi-rez-login.service
      '';
    in
    {
      options.services.wifi-rez = {
        ssid = lib.mkOption {
          type = lib.types.str;
          default = "WR-Nantes-Alejan";
          description = "The dorm Wi-Fi SSID and NetworkManager connection name.";
        };

        interface = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional Wi-Fi interface to bind the NetworkManager profile to.";
        };

        usernamePrefix = lib.mkOption {
          type = lib.types.str;
          default = "ZONE_653-";
          description = "Prefix required by the captive portal before the username.";
        };

        sopsFile = lib.mkOption {
          type = lib.types.path;
          default = ../../secrets/wifi/wifi_rez.yaml;
          description = "SOPS file containing username and password keys.";
        };

        usernameKey = lib.mkOption {
          type = lib.types.str;
          default = "username";
          description = "Key containing the captive portal username.";
        };

        passwordKey = lib.mkOption {
          type = lib.types.str;
          default = "password";
          description = "Key containing the captive portal password.";
        };

        probeUrl = lib.mkOption {
          type = lib.types.str;
          default = "http://clients3.google.com/generate_204";
          description = "HTTP URL used to trigger captive portal interception.";
        };

        retryCount = lib.mkOption {
          type = lib.types.ints.positive;
          default = 3;
          description = "Maximum login attempts for one connection event.";
        };
      };

      config = {
        assertions = [
          {
            assertion = cfg.ssid != "";
            message = "services.wifi-rez.ssid must not be empty.";
          }
        ];

        networking.networkmanager.enable = true;
        networking.networkmanager.ensureProfiles.profiles.wifi-rez = {
          connection = {
            id = cfg.ssid;
            type = "wifi";
            autoconnect = "yes";
            autoconnect-priority = "100";
          };
          wifi = {
            mode = "infrastructure";
            ssid = cfg.ssid;
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        } // lib.optionalAttrs (cfg.interface != null) {
          connection.interface-name = cfg.interface;
        };

        sops.secrets.${usernameSecret} = {
          inherit (cfg) sopsFile;
          key = cfg.usernameKey;
        };
        sops.secrets.${passwordSecret} = {
          inherit (cfg) sopsFile;
          key = cfg.passwordKey;
        };

        sops.templates."wifi-rez-login" = {
          mode = "0700";
          content = ''
            #!${pkgs.bash}/bin/bash
            set -euo pipefail

            readonly USERNAME_PREFIX=${lib.escapeShellArg cfg.usernamePrefix}
            USERNAME=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.${usernameSecret}.path})
            PASSWORD=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.${passwordSecret}.path})
            readonly USERNAME PASSWORD
            readonly PROBE_URL=${lib.escapeShellArg cfg.probeUrl}
            readonly RETRIES=${toString cfg.retryCount}
            readonly CURL=${pkgs.curl}/bin/curl
            readonly PYTHON=${pkgs.python3}/bin/python3

            login_once() {
              local runtime_dir headers login_url form status
              runtime_dir=$(${pkgs.coreutils}/bin/mktemp -d)
              trap '${pkgs.coreutils}/bin/rm -rf "$runtime_dir"' RETURN
              headers="$runtime_dir/headers"

              "$CURL" --silent --show-error --max-time 15 --dump-header "$headers" \
                --cookie-jar "$runtime_dir/cookies" --output /dev/null \
                --max-redirs 0 "$PROBE_URL" || true

              login_url=$(${pkgs.gnugrep}/bin/grep -i '^location:' "$headers" | \
                ${pkgs.coreutils}/bin/tail -n 1 | \
                ${pkgs.gawk}/bin/awk '{$1=""; sub(/^ /, ""); sub(/\r$/, ""); print}')
              if [[ -z "$login_url" ]]; then
                echo "wifi-rez: captive portal did not provide a login URL" >&2
                return 1
              fi

              login_url=$(
                LOGIN_URL="$login_url" "$PYTHON" - <<'PY'
            import os
            from urllib.parse import unquote
            print(unquote(os.environ["login_url"]))
            PY
              )

              form=$(
                LOGIN_USERNAME="''${USERNAME_PREFIX}''${USERNAME}" \
                LOGIN_EMAIL="''${USERNAME_PREFIX}''${USERNAME}" \
                LOGIN_NOTPREFIXED_USERNAME="$USERNAME" \
                LOGIN_PASSWORD="$PASSWORD" \
                "$PYTHON" - <<'PY'
            import os
            from urllib.parse import urlencode
            print(urlencode({
                "request_flag": "0",
                "username": os.environ["LOGIN_USERNAME"],
                "connexion_mode": "1",
                "preview_user_type": "",
                "email": os.environ["LOGIN_EMAIL"],
                "notprefixed_username": os.environ["LOGIN_NOTPREFIXED_USERNAME"],
                "password": os.environ["LOGIN_PASSWORD"],
            }))
            PY
              )

              status=$(
                printf '%s' "$form" | "$CURL" --silent --show-error --max-time 15 \
                  --cookie "$runtime_dir/cookies" --cookie-jar "$runtime_dir/cookies" \
                  --request POST --header 'Content-Type: application/x-www-form-urlencoded' \
                  --data-binary @- --output /dev/null --write-out '%{http_code}' "$login_url"
              )
              [[ "$status" =~ ^2|^3 ]] || {
                echo "wifi-rez: portal login returned HTTP $status" >&2
                return 1
              }

              echo "wifi-rez: captive portal login submitted successfully"
            }

            for attempt in $(seq 1 "$RETRIES"); do
              if login_once; then
                exit 0
              fi
              [[ "$attempt" -lt "$RETRIES" ]] && ${pkgs.coreutils}/bin/sleep 5
            done

            echo "wifi-rez: captive portal login failed after $RETRIES attempts" >&2
            exit 1
          '';
        };

        networking.networkmanager.dispatcherScripts = [
          {
            source = dispatcherScript;
            type = "basic";
          }
        ];

        systemd.services.wifi-rez-login = {
          description = "Authenticate the dorm Wi-Fi captive portal";
          wants = [ "network-online.target" ];
          after = [ "NetworkManager.service" "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.util-linux}/bin/flock -n /run/wifi-rez-login.lock ${loginScript}";
            TimeoutStartSec = "90s";
            PrivateTmp = true;
          };
        };
      };
    };
  flake.nixosModules.wifi-eduroam = { config, lib, pkgs, ... }:
    let
      cfg = config.services.wifi-eduroam;
      usernameSecret = "wifi-eduroam-username";
      passwordSecret = "wifi-eduroam-password";
      environmentTemplate = config.sops.templates."wifi-eduroam-networkmanager".path;
      caCertificate = pkgs.writeText "eduroam-ca.pem" ''
        -----BEGIN CERTIFICATE-----
        MIIFpDCCA4ygAwIBAgIQOcqTHO9D88aOk8f0ZIk4fjANBgkqhkiG9w0BAQsFADBs
        MQswCQYDVQQGEwJHUjE3MDUGA1UECgwuSGVsbGVuaWMgQWNhZGVtaWMgYW5kIFJl
        c2VhcmNoIEluc3RpdHV0aW9ucyBDQTEkMCIGA1UEAwwbSEFSSUNBIFRMUyBSU0Eg
        Um9vdCBDQSAyMDIxMB4XDTIxMDIxOTEwNTUzOFoXDTQ1MDIxMzEwNTUzN1owbDEL
        MAkGA1UEBhMCR1IxNzA1BgNVBAoMLkhlbGxlbmljIEFjYWRlbWljIGFuZCBSZXNl
        YXJjaCBJbnN0aXR1dGlvbnMgQ0ExJDAiBgNVBAMMG0hBUklDQSBUTFMgUlNBI FJv
        b3QgQ0EgMjAyMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIvC569l
        mwVnlskNJLnQDmT8zuIkGCyEf3dRywQRNrhe7Wlxp57kJQmXZ8FHws+RFjZiPTgE
        4VGC/6zStGndLuwRo0Xua2s7TL+MjaQenRG56Tj5eg4MmOIjHdFOY9TnuEFE+2uv
        a9of08WRiFukiZLRgeaMOVig1mlDqa2YUlhu2wr7a89o+uOkXjpFc5gH6l8Cct4M
        pbOfrqkdtx2z/IpZ525yZa31MJQjB/OCFks1mJxTuy/K5FrZx40d/JiZ+yykgmvw
        Kh+OC19xXFyuQnspiYHLA6OZyoieC0AJQTPb5lh6/a6ZcMBaD9YThnEvdmn8kN3b
        LW7R8pv1GmuebxWMevBLKKAiOIAkbDakO/IwkfN4E8/BPzWr8R0RI7VDIp4BkrcY
        AuUR0YLbFQDMYTfBKnya4dC6s1BG7oKsnTH4+yPiAwBIcKMJJnkVU2DzOFytOOqB
        AGMUuTNe3QvboEUHGjMJ+E20pwKmafTCWQWIZYVWrkvL4N48fS0ayOn7H6NhStYq
        E613TBoYm5EPWNgGVMWX+Ko/IIqmhaZ39qb8HOLubpQzKoNQhArlT4b4UEV4AIHr
        W2jjJo3Me1xR9BQsQL4aYB16cmEdH2MtiKrOokWQCPxrvrNQKlr9qEgYRtaQQJKQ
        CoReaDH46+0N0x3GfZkYVVYnZS6NRcUk7M7jAgMBAAGjQjBAMA8GA1UdEwEB/wQF
        MAMBAf8wHQYDVR0OBBYEFApII6ZgpJIKM+qTW8VX6iVNvRLuMA4GA1UdDwEB/wQE
        AwIBhjANBgkqhkiG9w0BAQsFAAOCAgEAPpBIqm5iFSVmewzVjIuJndftTgfvnNAU
        X15QvWiWkKQUEapobQk1OUAJ2vQJLDSle1mESSmXdMgHHkdt8s4cUCbjnj1AUz/3
        f5Z2EMVGpdAgS1D0NTsY9FVqQRtHBmg8uwkIYtlfVUKqrFOFrJVWNlar5AWMxaja
        H6NpvVMPxP/cyuN+8kyIhkdGGvMA9YCRotxDQpSbIPDRzbLrLFPCU3hKTwSUQZqP
        JzLB5UkZv/HywouoCjkxKLR9YjYsTewfM7Z+d21+UPCfDtcRj88YxeMn/ibvBZ3P
        zzfF0HvaO7AWhAw6k9a+F9sPPg4ZeAnHqQJyIkv3N3a6dcSFA1pj1bF1BcK5vZSt
        jBWZp5N99sXzqnTPBIWUmAD04vnKJGW/4GKvyMX6ssmeVkjaef2WdhW+o45WxLM0
        /L5H9MG0qPzVMIho7suuyWPEdr6sOBjhXlzPrjoiUevRi7PzKzMHVIf6tLITe7pT
        BGIBnfHAT+7hOtSLIBD6Alfm78ELt5BGnBkpjNxvoEppaZS3JGWg/6w/zgH7IS79
        aPib8qXPMThcFarmlwDB31qlpzmq6YR/PFGoOtmUW4y/Twhx5duoXNTSpv4Ao8YW
        xw/ogM4cKGR0GQjTQuPOAF1/sdwTsOEFy9EgqoZ0njnnkf3/W9b3raYvAwtt41dU
        63ZTGI0RmLo=
        -----END CERTIFICATE-----
      '';
    in
    {
      options.services.wifi-eduroam = {
        sopsFile = lib.mkOption {
          type = lib.types.path;
          default = ../../secrets/wifi/wifi_eduroam.yaml;
          description = "SOPS file containing the eduroam username and password.";
        };

        usernameKey = lib.mkOption {
          type = lib.types.str;
          default = "username";
        };

        passwordKey = lib.mkOption {
          type = lib.types.str;
          default = "password";
        };
      };

      config = {
        networking.networkmanager.enable = true;
        environment.etc."ssl/certs/eduroam-harica-root-ca.pem".source = caCertificate;

        sops.secrets.${usernameSecret} = {
          inherit (cfg) sopsFile;
          key = cfg.usernameKey;
        };
        sops.secrets.${passwordSecret} = {
          inherit (cfg) sopsFile;
          key = cfg.passwordKey;
        };

        sops.templates."wifi-eduroam-networkmanager" = {
          mode = "0400";
          content = ''
            EDUROAM_USERNAME=${config.sops.placeholder.${usernameSecret}}
            EDUROAM_PASSWORD=${config.sops.placeholder.${passwordSecret}}
          '';
        };

        networking.networkmanager.ensureProfiles = {
          environmentFiles = [ environmentTemplate ];
          profiles.eduroam = {
            connection = {
              id = "eduroam";
              type = "wifi";
              autoconnect = "yes";
              autoconnect-priority = "90";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "eduroam";
            };
            wifi-security = {
              key-mgmt = "wpa-eap";
              proto = "rsn";
              pairwise = "ccmp";
              group = "ccmp";
            };
            "802-1x" = {
              eap = "peap";
              identity = "$EDUROAM_USERNAME";
              anonymous-identity = "anonymous@eleves.ec-nantes.fr";
              phase2-auth = "mschapv2";
              password = "$EDUROAM_PASSWORD";
              password-flags = "0";
              ca-cert = "file:///etc/ssl/certs/eduroam-harica-root-ca.pem";
              domain-match = "radius.ec-nantes.fr";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      };
    };
}
