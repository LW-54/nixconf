{bound, ...}: {
  nixos = {
    services.caddy = {
      enable = true;
      virtualHosts."vault.${bound."config:domain".value}".extraConfig = ''
        reverse_proxy 127.0.0.1:8222
      '';
    };
  };
}
