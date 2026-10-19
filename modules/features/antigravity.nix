{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.antigravity = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.antigravity.enable = lib.mkEnableOption "Antigravity" // {default = true;};

    config = lib.mkIf config.antigravity.enable {
      environment.systemPackages = [self.packages.${pkgs.system}.antigravity];
    };
  };

  flake.nixosModules.antigravity-ide = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: {
    options.antigravity-ide.enable = lib.mkEnableOption "Antigravity IDE" // {default = true;};

    config = lib.mkIf config.antigravity-ide.enable {
      environment.systemPackages = [self.packages.${pkgs.system}.antigravity-ide];
      persistence.users = lib.mapAttrs (_: _: {
        data.directories = [
          ".antigravity-ide"
          ".gemini"
        ];
      }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
    };
  };

  flake.nixosModules.antigravity-cli = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.antigravity-cli.enable = lib.mkEnableOption "Antigravity CLI" // {default = true;};

    config = lib.mkIf config.antigravity-cli.enable {
      environment.systemPackages = [self.packages.${pkgs.system}.antigravity-cli];
    };
  };

  perSystem = {pkgs, ...}: {
    packages = {
      antigravity = inputs.antigravity-nix.packages.${pkgs.system}.default;
      antigravity-ide = inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide;
      antigravity-cli = inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli;
    };
  };
}
