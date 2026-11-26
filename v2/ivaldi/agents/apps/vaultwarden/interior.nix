{
  self,
  bound,
  lib,
  ...
}: let
  routeOffer = lib.findFirst (p: p.polarity == "offer" && p.ptype == "http:route" && p.key == "vault") (throw "missing http:route offer") self.promises;
  route = routeOffer.payload;
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
