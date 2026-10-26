{
  inputs,
  self,
  ...
}: {
  feature.antigravity = {
    description = "Google Antigravity IDE, agentic workflow tools, and CLI runtime.";
    modules = {
      antigravity = {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.antigravity.enable = lib.mkEnableOption "Antigravity" // {default = true;};

        config = lib.mkIf config.antigravity.enable {
          environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity];
        };
      };

      antigravity-ide = {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.antigravity-ide.enable = lib.mkEnableOption "Antigravity IDE" // {default = true;};

        config = lib.mkIf config.antigravity-ide.enable {
          environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-ide];
          persistence.users = lib.mapAttrs (_: _: {
            data.directories = [
              ".antigravity-ide"
              ".gemini"
            ];
          }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
        };
      };

      antigravity-cli = {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.antigravity-cli.enable = lib.mkEnableOption "Antigravity CLI" // {default = true;};

        config = lib.mkIf config.antigravity-cli.enable {
          environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli];
        };
      };
    };

    packages = {pkgs, ...}: {
      antigravity = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      antigravity-ide = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide;
      antigravity-cli = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli;
    };
  };
}
