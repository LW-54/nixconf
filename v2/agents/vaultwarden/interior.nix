{
  self,
  bound,
  ...
}: {
  nixos = {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_PORT = self.offers."http:vaultwarden".port;
        DOMAIN = "https://vault.${bound."config:domain".value}";
      };
    };
  };
}
