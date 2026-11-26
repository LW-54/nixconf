{
  bound,
  inputs,
  ...
}: {
  nixos = {
    imports = [
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
    ];
    networking.hostName = bound."config:hostname".value;
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
  };
}
