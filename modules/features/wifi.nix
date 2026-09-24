{ self, ... }:

{
  flake.nixosModules.wifi-rez = { config, lib, pkgs, ... }:
    let
      cfg = config.services.wifi-rez;
      usernameSecret = "wifi-rez-username";
      passwordSecret = "wifi-rez-password";
      browserPython = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.selenium ]);
        loginScript = pkgs.writeText "wifi-rez-login.py" ''
        import os
        import sys
        import tempfile
        import time
        import urllib.error
        import urllib.request

        from selenium import webdriver
        from selenium.common.exceptions import WebDriverException
        from selenium.webdriver.chrome.options import Options
        from selenium.webdriver.chrome.service import Service
        from selenium.webdriver.common.by import By
        from selenium.webdriver.support.ui import WebDriverWait

        probe_url = ${builtins.toJSON cfg.probeUrl}
        login_url = ${builtins.toJSON cfg.loginUrl}
        retries = ${toString cfg.retryCount}
        chromium = "${pkgs.chromium}/bin/chromium"
        chromedriver = "${pkgs.chromedriver}/bin/chromedriver"

        def read_credential(name):
          with open(os.path.join(os.environ["CREDENTIALS_DIRECTORY"], name), encoding="utf-8") as credential:
            return credential.read().strip()

        def unrestricted_network():
          request = urllib.request.Request(probe_url, method="GET")
          try:
            with urllib.request.urlopen(request, timeout=10) as response:
              return response.status == 204
          except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError):
            return False

        def browser_login(username, password):
          options = Options()
          options.binary_location = chromium
          options.add_argument("--headless=new")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--no-first-run")
          options.add_argument("--no-default-browser-check")
          options.add_argument("--disable-gpu")
          options.add_argument("--disable-dev-shm-usage")
          with tempfile.TemporaryDirectory(prefix="wifi-rez-browser-") as profile:
            options.add_argument("--user-data-dir=" + profile)
            driver = None
            try:
              driver = webdriver.Chrome(
                service=Service(executable_path=chromedriver, log_output=os.devnull),
                options=options,
              )
              driver.set_page_load_timeout(20)
              driver.get(login_url)
              password_field = WebDriverWait(driver, 15).until(
                lambda current: current.find_element(By.CSS_SELECTOR, "input[type='password']")
              )
              visible = [field for field in driver.find_elements(By.CSS_SELECTOR, "input") if field.is_displayed() and field.is_enabled()]
              username_field = next(
                field for field in visible
                if "username" in ((field.get_attribute("name") or "") + " " + (field.get_attribute("id") or "")).lower()
              )
              username_field.send_keys(username)
              password_field.send_keys(password)
              driver.find_element(By.CSS_SELECTOR, "button[type='submit'], input[type='submit']").click()
              time.sleep(5)
              return unrestricted_network()
            except (WebDriverException, StopIteration):
              return False
            finally:
              if driver is not None:
                driver.quit()

        def login_once(username, password):
          if unrestricted_network():
            print("wifi-rez: network is already authenticated")
            return True
          return browser_login(username, password)

        username = read_credential("username")
        password = read_credential("password")
        for attempt in range(1, retries + 1):
          if login_once(username, password):
            print("wifi-rez: captive portal login succeeded")
            sys.exit(0)
          if attempt < retries:
            time.sleep(5)

        print("wifi-rez: captive portal login failed after {} attempts".format(retries), file=sys.stderr)
        sys.exit(1)
        '';
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
          description = "HTTP URL used only to verify unrestricted internet access after login.";
        };

        loginUrl = lib.mkOption {
          type = lib.types.str;
          default = "http://saas1.hotspotmanager.fr/hotspot.php?ap_name=Bat-B-Et2-B202+&ap_tags=&continue_url=http%3A%2F%2Fcapture.adipsys.net%2F&login_url=https%3A%2F%2Feu.network-auth.com%2Fsplash%2F0-DDmdjd.0.945%2Flogin%3Fcontinue_url%3Dhttp%25253A%25252F%25252Fcapture.adipsys.net%25252F%26mauth%3DEfqbOaLu03DvCu787KxlL_vU8WuTdKtwHDkvLK3bHaSuEpPlW1al79xYBA9w_dXE-ffAGhirLH4sEfqbVDkQgMkxgCG0cmNV-psf8lVKvcuSBYK8kXllK_5m4XyuBdkAq_aDEF0PmBgDhX3miYMcStnNG6d7oHOwktgZYJu9NRreiFc6KW_bS0WpeVgVm8bRYlx2K2wOEd6aLmlgHWra9f74o0YvphHmxTmNMKAVupBpNc0JXw&ap_mac=f8:9e:28:db:e5:f7&client_ip=10.60.86.184&client_mac=5c:c5:d4:af:51:9f";
          description = "Full captive-portal URL opened by the headless browser after Wi-Fi connects.";
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
            autoconnect = "true";
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
            ExecStart = "${pkgs.util-linux}/bin/flock -n /run/wifi-rez-login/wifi-rez-login.lock ${browserPython}/bin/python ${loginScript}";
            LoadCredential = [
              "username:${config.sops.secrets.${usernameSecret}.path}"
              "password:${config.sops.secrets.${passwordSecret}.path}"
            ];
            DynamicUser = true;
            RuntimeDirectory = "wifi-rez-login";
            PrivateTmp = true;
            ProtectHome = true;
            RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
            MemoryMax = "768M";
            TasksMax = 256;
            TimeoutStartSec = "120s";
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
