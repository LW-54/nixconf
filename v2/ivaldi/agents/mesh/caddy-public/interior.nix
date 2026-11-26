{
  bound,
  lib,
  ...
}: let
  domain = bound."config:domain".value;
  routes = bound."http:route";
in {
  nixos = {
    services.caddy = {
      enable = true;
      virtualHosts =
        lib.mapAttrs' (_routeKey: route: {
          name = "${route.subdomain}.${domain}";
          value.extraConfig = ''
            reverse_proxy 127.0.0.1:${toString route.port}
          '';
        })
        routes;
    };
  };
}
