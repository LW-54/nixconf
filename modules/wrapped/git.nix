{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.git
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.git = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.git;
      exePath = "${pkgs.git}/bin/git";
      env = rec {
        GIT_AUTHOR_NAME = "LW-54";
        GIT_AUTHOR_EMAIL = "leonardwilsonb@gmail.com";
        GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
        GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
      };
    };
  };
}