{ self, ... }:

{
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
              autoconnect = "true";
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
