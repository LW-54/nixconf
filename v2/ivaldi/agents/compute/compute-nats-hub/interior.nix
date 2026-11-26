{...}: {
  nixos = {
    services.nats = {
      enable = true;
      jetstream = true;
    };
  };
}
