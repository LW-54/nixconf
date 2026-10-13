{ ... }:
{
  flake.nixosModules.fonts = { pkgs, ... }:
    {
      fonts.packages = [ pkgs.jetbrains-mono ];
    };
}