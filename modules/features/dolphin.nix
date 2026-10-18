{self, ...}: {
  flake.nixosModules.dolphin = {
    config,
    lib,
    ...
  }: let
    cfg = config.dolphin;
  in {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "dolphin";
        description = "Dolphin File Manager";
        package = pkgs: self.packages.${pkgs.stdenv.hostPlatform.system}.dolphin;
      })
    ];

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = cfg.enable;
      userOverrides = cfg.users;
      data = {
        directories = [".local/share/dolphin"];
        files = [".config/dolphinrc"];
      };
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
