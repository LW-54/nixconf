{
  inputs,
  persistentPaths,
  ...
}: {
  nixos = {
    imports = [
      (inputs.impermanence + "/nixos.nix")
    ];
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
    fileSystems."/persist" = {
      device = "/dev/disk/by-label/persist";
      fsType = "ext4";
      neededForBoot = true;
    };
    # Auto-realized strictly from Agent-Declared S2+ [state.*] volumes in *.toml!
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = persistentPaths;
    };
  };
}
