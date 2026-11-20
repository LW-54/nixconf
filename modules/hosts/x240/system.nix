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
        self.nixosModules.lgtm
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

        secrets.files.lldap-admin-password = {
          store = "services/auth";
          key = "lldapAdminPassword";
          owner = "alloy";
          group = "alloy";
          testValue = "nixconf-test-lldap-admin-password";
        };

        monitoring.agent = {
          metricsUrl = "https://prometheus.adje.app/api/v1/write";
          logsUrl = "https://loki.adje.app/loki/api/v1/push";
          basicAuth = {
            enable = true;
            username = "admin";
            passwordFile = config.secrets.files.lldap-admin-password.path;
          };
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
