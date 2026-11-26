{...}: {
  nixos = {
    services.tailscale.enable = true;
    # ADR-0012 / A-006: never block headless boot or SSH on Tailscale control plane!
    systemd.network.wait-online.enable = false;
  };
}
