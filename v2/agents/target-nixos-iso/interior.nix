{
  host,
  inputs,
  ...
}: {
  nixos = {
    imports = [
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
    ];
    networking.hostName = host.id;
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
  };
}
