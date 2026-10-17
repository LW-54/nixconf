{
  inputs,
  self,
  ...
}: let
  defaultAgeKeyFile = "/persist/sops-nix/key.txt";
  mkSopsHostShell = {
    pkgs,
    keyFile,
  }:
    pkgs.mkShell {
      packages = [
        pkgs.age
        pkgs.sops
      ];
      shellHook = ''
        export SOPS_AGE_KEY="$(cat ${keyFile})"
      '';
    };
in {
  perSystem = {pkgs, ...}: {
    devShells.sops-admin = pkgs.mkShell {
      packages = [
        self.packages.${pkgs.system}.bw
        pkgs.age
        pkgs.jq
        pkgs.sops
      ];
      shellHook = self.lib.mkBitwardenSecretShellHook {
        itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
        variable = "SOPS_AGE_KEY";
        jqFilter = ".notes | select(type == \"string\" and length > 0)";
      };
    };

    devShells.sops-host = mkSopsHostShell {
      inherit pkgs;
      keyFile = defaultAgeKeyFile;
    };
  };

  flake.nixosModules.sops-nix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.sops;
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    options.sops.prebuildAdminShell = lib.mkEnableOption "prebuilding the SOPS admin development shell" // {default = true;};
    options.sops.prebuildHostShell = lib.mkEnableOption "prebuilding the SOPS host development shell" // {default = true;};

    config = {
      sops.age.keyFile = lib.mkDefault defaultAgeKeyFile;
      system.extraDependencies =
        lib.optional cfg.prebuildAdminShell self.devShells.${pkgs.system}.sops-admin
        ++ lib.optional cfg.prebuildHostShell (mkSopsHostShell {
          inherit pkgs;
          keyFile = config.sops.age.keyFile;
        });
    };
  };
}
