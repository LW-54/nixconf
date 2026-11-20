{self, ...}: {
  feature.zed = {
    description = "Zed editor environment and persistence.";
    modules = {
      zed = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.zed;
      in {
        options.zed.enable = lib.mkEnableOption "Zed editor" // {default = true;};

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [pkgs.zed-editor];

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [".config/zed" ".local/share/zed"];
          });
        };
      };
    };
  };
}
