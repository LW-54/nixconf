{self, ...}: {
  host.x240.subModules = {
    x240-desktop = {...}: {
      imports = [
        self.nixosModules.uwsm
        self.nixosModules.fonts
        self.nixosModules.labwc
        self.nixosModules.noctalia
        self.nixosModules.audio
        self.nixosModules.cursor
        self.nixosModules.greetd
        self.nixosModules.dolphin
        self.nixosModules.foot
        self.nixosModules.vivaldi
        self.nixosModules.vscode
        self.nixosModules.zed
        self.nixosModules.antigravity-ide
      ];

      config = {
        wayland.enable = true;
        environment.sessionVariables = {
          XKB_DEFAULT_LAYOUT = "fr";
          XKB_DEFAULT_VARIANT = "";
        };
      };
    };
  };
}
