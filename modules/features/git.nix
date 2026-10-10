{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.git
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.git = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings = {
        user.name = "LW-54";
        user.email = "leonardwilsonb@gmail.com";

        pull.rebase = true;
        fetch.prune = true;
        push.autoSetupRemote = true;
        rerere.enabled = true;
      };
    };
  };
}