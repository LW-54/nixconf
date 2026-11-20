{self, ...}: {
  host.astrolabe.subModules = {
    astrolabe-services = {...}: {
      imports = [
        self.nixosModules.caddy
        self.nixosModules.authelia
        self.nixosModules.lgtm
        self.nixosModules.restic
        self.nixosModules.snapshot
        self.nixosModules.vaultwarden
        self.nixosModules.ttyd
        self.nixosModules.uchiyomi
        self.nixosModules.copyparty
      ];

      config = {
        reverse-proxy.domain = "adje.app";
        monitoring.server.enable = true;
      };
    };
  };
}
