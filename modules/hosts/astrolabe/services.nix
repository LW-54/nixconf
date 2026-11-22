{self, ...}: {
  host.astrolabe.subModules = {
    astrolabe-services = {...}: {
      imports = [
        self.nixosModules.caddy
        self.nixosModules.authelia
        self.nixosModules.grafana
        self.nixosModules.ntfy
        self.nixosModules.restic
        self.nixosModules.snapshot
        self.nixosModules.vaultwarden
        self.nixosModules.ttyd
        self.nixosModules.agy
        self.nixosModules.agy-hub
        self.nixosModules.uchiyomi
        self.nixosModules.copyparty
      ];

      config = {
        reverse-proxy.domain = "adje.app";
      };
    };
  };
}
