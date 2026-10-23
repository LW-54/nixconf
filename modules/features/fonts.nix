{...}: {
  feature.fonts = {
    description = "System typography and developer monospace font packages.";
    modules = {
      fonts = {pkgs, ...}: {
        fonts.packages = [pkgs.jetbrains-mono];
      };
    };
  };
}
