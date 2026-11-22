{self, ...}: {
  host.x240.subModules = {
    x240-system = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        self.nixosModules.sops
        self.nixosModules.cgroups
        self.nixosModules.rclone
        self.nixosModules.restic
        self.nixosModules.alloy
        self.nixosModules.lw
        self.nixosModules.hjem
        self.nixosModules.nix
        self.nixosModules.locale
        self.nixosModules.direnv
        self.nixosModules.wifi-eduroam
        self.nixosModules.git
        self.nixosModules.tack
        self.nixosModules.bw
        self.nixosModules.ssh
        self.nixosModules.docker
        self.nixosModules.micro
        self.nixosModules.agy
      ];

      config = {
        console.keyMap = "fr";
        networking.hostName = "x240";
        networking.networkmanager.enable = true;

        environment.systemPackages = with pkgs; [
          curl
          wl-clipboard
          alejandra
          btop
          jq
        ];

        secrets.files.telemetry-ingest-token = {
          store = "services/monitoring";
          key = "telemetryIngestToken";
          owner = "alloy";
          group = "alloy";
          testValue = "nixconf-test-telemetry-ingest-token-0123456789abcdef";
        };

        monitoring.agent = {
          metricsUrl = "https://vm.adje.app/api/v1/write";
          logsUrl = "https://vlogs.adje.app/insert/loki/api/v1/push";
          bearerTokenFile = config.secrets.files.telemetry-ingest-token.path;
        };

        backup = {
          enable = true;
          units.lw = {
            paths = [
              "/home/lw/Documents"
              "/home/lw/Projects"
              "/home/lw/nixconf"
              "/home/lw/.ssh"
            ];
            autoRestore = false;
            beforeUnits = [];
          };
        };

        testing.vm.allowedFailedUnits = [
          "NetworkManager-wait-online.service"
        ];

        system.configurationRevision = self.rev or self.dirtyRev or "unknown";
        system.stateVersion = "25.11";
      };
    };
  };
}
