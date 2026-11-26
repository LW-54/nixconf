{bound, ...}: {
  nixos = {
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    system.stateVersion = "25.05";
    networking.hostName = bound."config:hostname".value;
  };
}
