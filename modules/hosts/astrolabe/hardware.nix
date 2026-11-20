{...}: {
  host.astrolabe.subModules = {
    astrolabe-hardware = {
      modulesPath,
      lib,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      config = {
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
          device = "/dev/sda";
        };
      };
    };
  };
}
