{ self, inputs, ... }: {
  flake.nixosModules.helium = { pkgs, ... }: {
    # Import the NixOS module provided by the Helium flake
    imports = [ inputs.helium.nixosModules.default ];

    programs.helium = {
      enable = true;
      flags = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform-hint=auto"
      ];
      policies = {
        ExtensionInstallForcelist = [
          "nngceckbapebfimnlniiiahkandclblb"
        ];
      };
    };
  };
}
