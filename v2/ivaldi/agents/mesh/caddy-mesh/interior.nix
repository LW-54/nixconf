{
  bound,
  lib,
  ...
}: let
  tailnet = bound."config:tailnet".value;
  routes = bound."http:route";
in {
  nixos = {
    environment.etc."aky/caddy-mesh-routes.json".text = builtins.toJSON (
      lib.mapAttrs (_k: route: {
        fqdn = "${route.subdomain}.${tailnet}";
        upstream = "127.0.0.1:${toString route.port}";
        tls = "tailscale-get-certificate";
      })
      routes
    );
  };
}
