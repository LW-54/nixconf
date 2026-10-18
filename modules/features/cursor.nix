{...}: {
  flake.nixosModules.cursor = {pkgs, ...}: {
    config = {
      environment.sessionVariables = {
        XCURSOR_THEME = "Adwaita";
        XCURSOR_SIZE = "24";
      };
      environment.systemPackages = [pkgs.adwaita-icon-theme];
    };
  };
}
