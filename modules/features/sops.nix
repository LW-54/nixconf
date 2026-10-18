{
  inputs,
  self,
  ...
}: let
  defaultAgeKeyFile = "/persist/sops-nix/key.txt";
in {
  flake.nixosModules.sops = {
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
      system.extraDependencies = lib.concatLists [
        (lib.optional cfg.prebuildAdminShell self.devShells.${pkgs.system}.sops-admin)
        (lib.optional cfg.prebuildHostShell (self.lib.sops.mkHostShell {
          inherit pkgs;
          keyFile = config.sops.age.keyFile;
        }))
      ];
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.sops-admin = self.lib.bitwarden.mkShell {
      inherit pkgs;
      bw = self'.packages.bw;
      packages = [pkgs.age pkgs.sops];
      shellHook = self.lib.bitwarden.mkValue {
        itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
        variable = "SOPS_AGE_KEY";
        jqFilter = ".notes | select(type == \"string\" and length > 0)";
      };
    };

    devShells.sops-host = self.lib.sops.mkHostShell {inherit pkgs;};
  };

  flake.lib.sops.mkHostShell = {
    pkgs,
    keyFile ? defaultAgeKeyFile,
  }:
    pkgs.mkShell {
      packages = [pkgs.age pkgs.sops];
      shellHook = let
        keyFileArg = pkgs.lib.escapeShellArg keyFile;
      in ''
        SOPS_AGE_KEY="$(${pkgs.coreutils}/bin/cat ${keyFileArg} 2>/dev/null ||
          { command -v sudo >/dev/null 2>&1 && sudo ${pkgs.coreutils}/bin/cat ${keyFileArg}; } ||
          { printf 'Unable to read the SOPS age key file: %s\n' ${keyFileArg} >&2; exit 1; }
        )" || exit 1
        export SOPS_AGE_KEY
      '';
    };
}
