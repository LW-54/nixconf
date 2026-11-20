{...}: {
  host.astrolabe.subModules = {
    astrolabe-resources = {config, ...}: let
      isTest = config.testing.enable or false;
    in {
      services.uchiyomi-server.resources.tier = "media";

      resources = {
        profile = "server";
        # VPS relies solely on zram; disable swapKill to avoid false-positive kills under compressed swap pressure.
        oom.swapKill = false;

        tiers.media = {
          description = "Isolated media and container stack (Uchiyomi, Suwayomi, FlareSolverr).";
          cpu.weight = 60;
          io.weight = 60;
          memory = {
            high = "50%";
            max = "65%";
          };
          oom = {
            preference = "none";
            kill = true;
            pressureLimit = "70%";
            scoreAdjust = 200;
          };
        };

        volumes = {
          emergency-headroom = {
            mode = "reserved";
            size =
              if isTest
              then "64M"
              else "2G";
          };
          caddy-data = {
            mode = "reserved";
            size =
              if isTest
              then "32M"
              else "256M";
            mountPoint = "/var/lib/caddy";
            owner = "caddy";
            group = "caddy";
            dirMode = "0750";
            beforeUnits = ["caddy.service"];
          };
          authelia-data = {
            mode = "reserved";
            size =
              if isTest
              then "32M"
              else "256M";
            mountPoint = "/var/lib/authelia-main";
            owner = "authelia-main";
            group = "authelia-main";
            dirMode = "0700";
            beforeUnits = ["authelia-main.service"];
          };
          lldap-data = {
            mode = "reserved";
            size =
              if isTest
              then "32M"
              else "256M";
            mountPoint = "/var/lib/lldap";
            owner = "lldap";
            group = "lldap";
            dirMode = "0700";
            beforeUnits = ["lldap.service"];
          };
          vaultwarden-data = {
            mode = "reserved";
            size =
              if isTest
              then "32M"
              else "512M";
            mountPoint = "/var/lib/vaultwarden";
            owner = "vaultwarden";
            group = "vaultwarden";
            dirMode = "0700";
            beforeUnits = ["vaultwarden.service"];
          };
          rclone-cache = {
            mode = "thin";
            size =
              if isTest
              then "256M"
              else "25G";
            mountPoint = "/var/cache/rclone";
            beforeUnits = ["rclone-config.service"];
            excludeFromSnapshot = true;
            excludeFromBackup = true;
          };
          loki-data = {
            mode = "thin";
            size =
              if isTest
              then "256M"
              else "10G";
            mountPoint = "/var/lib/loki";
            owner = "loki";
            group = "loki";
            dirMode = "0750";
            beforeUnits = ["loki.service"];
            excludeFromSnapshot = true;
            excludeFromBackup = true;
          };
          prometheus-data = {
            mode = "thin";
            size =
              if isTest
              then "256M"
              else "10G";
            mountPoint = "/var/lib/${config.services.prometheus.stateDir}";
            owner = "prometheus";
            group = "prometheus";
            dirMode = "0700";
            beforeUnits = ["prometheus.service"];
            excludeFromSnapshot = true;
            excludeFromBackup = true;
          };
        };

        storageBudgets = {
          copyparty = {
            maxSize = "250G";
            warnPercent = 80;
            interval = "6h";
          };
          uchiyomi = {
            maxSize = "250G";
            warnPercent = 80;
            interval = "6h";
          };
          hbox-backup-host = {
            maxSize = "200G";
            warnPercent = 85;
            interval = "12h";
          };
          hbox-backup-shared = {
            maxSize = "100G";
            warnPercent = 85;
            interval = "12h";
          };
          b2-backup-shared = {
            maxSize = "10G";
            warnPercent = 80;
            interval = "24h";
          };
        };
      };
    };
  };
}
