{self, ...}: {
  nixos = {
    services.caddy = {
      enable = true;
      virtualHosts."vault.${self.offers."proxy:https".domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:8222
      '';
    };
  };
}
