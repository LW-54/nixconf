{self, ...}: {
  flake.nixosModules.dolphin = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dolphin;
  in {
    options.dolphin.enable = lib.mkEnableOption "Dolphin File Manager" // {default = true;};

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [self.packages.${pkgs.system}.dolphin];

      persistence.users = lib.mapAttrs (_: _: {
        data = {
          directories = [".local/share/dolphin"];
          files = [".config/dolphinrc"];
        };
      }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
    };
  };

  perSystem = {pkgs, ...}: let
    runtimePackages = with pkgs.kdePackages; [
      plasma-integration
      breeze
      breeze-icons
      kio
      kio-extras
      qtsvg
      qtwayland
    ];
  in {
    packages.dolphin = pkgs.symlinkJoin {
      name = "dolphin-portable";
      paths = [pkgs.kdePackages.dolphin] ++ runtimePackages;
      nativeBuildInputs = [pkgs.makeWrapper];
      meta.mainProgram = "dolphin";
      postBuild = ''
        wrapProgram $out/bin/dolphin \
          --set QT_QPA_PLATFORM "wayland;xcb" \
          --prefix XDG_DATA_DIRS : "$out/share" \
          --prefix QT_PLUGIN_PATH : "$out/lib/qt-6/plugins"
      '';
    };
  };
}
