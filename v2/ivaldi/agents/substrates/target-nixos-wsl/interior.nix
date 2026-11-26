{bound, ...}: {
  nixos = {
    boot.isContainer = true;
    system.stateVersion = "25.05";
    networking.hostName = bound."config:hostname".value;
  };
}
