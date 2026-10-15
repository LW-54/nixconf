{ self, ... }:
{
  perSystem = { pkgs, ... }:
    let
      dolphinPackage = pkgs.kdePackages.dolphin;
      runtimePackages = with pkgs.kdePackages; [
        plasma-integration
        breeze
        breeze-icons
        kio
        kio-extras
        qtsvg
        qtwayland
      ];
      dolphin = pkgs.symlinkJoin {
        name = "dolphin-portable";
        paths = [ dolphinPackage ] ++ runtimePackages;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/dolphin \
            --set QT_QPA_PLATFORM "wayland;xcb" \
            --prefix XDG_DATA_DIRS : "$out/share" \
            --prefix QT_PLUGIN_PATH : "$out/lib/qt-6/plugins"
        '';
      };
    in
    {
      packages.dolphin = dolphin;
      apps.dolphin = {
        type = "app";
        program = "${dolphin}/bin/dolphin";
        meta.description = "Portable Dolphin file manager";
      };
    };

  flake.nixosModules.dolphin = { config, lib, ... }:
    let
      cfg = config.dolphin;
    in
    {
      imports = [
        (self.lib.mkUserFeature {
          inherit lib;
          name = "dolphin";
          description = "Dolphin File Manager";
          package = pkgs: self.packages.${pkgs.system}.dolphin;
        })
      ];

      config.persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
        userEnabled = userName:
          self.lib.resolveUserOption {
            inherit lib;
            global = cfg.enable;
            users = cfg.users;
            inherit userName;
          };
        data = {
          directories = [ ".local/share/dolphin" ];
          files = [ ".config/dolphinrc" ];
        };
      };
    };
  }