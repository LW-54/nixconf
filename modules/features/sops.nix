{inputs, ...}: {
  flake.nixosModules.sops-nix = {lib, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops.age.keyFile = lib.mkDefault "/persist/sops-nix/key.txt";
  };

  flake.nixosModules.sops-tools = {pkgs, ...}: {
    environment.systemPackages = [pkgs.sops pkgs.age];
  };
}
