{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.vscode
    ];
  };
}