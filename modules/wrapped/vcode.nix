{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.vscode
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.vscode = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.vscode;
    };
  };
}
