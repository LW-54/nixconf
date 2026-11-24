{
  self,
  bound,
  ...
}: let
  route = self.offers."route:vault";
in {
  nixos = {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_PORT = route.port;
        DOMAIN = "https://${route.subdomain}.${bound."config:domain".value}";
      };
    };
  };
}
