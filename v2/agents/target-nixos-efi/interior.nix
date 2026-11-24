{host, ...}: {
  nixos = {
    boot.loader.systemd-boot.enable = true;
    system.stateVersion = "25.05";
    networking.hostName = host.id;
  };
}
