{...}: {
  flake.nixosModules.vivaldi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.vivaldi;
  in {
    options.vivaldi.enable = lib.mkEnableOption "Vivaldi Browser" // {default = true;};

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.vivaldi.override {
          proprietaryCodecs = true;
          enableWidevine = true;
        })
      ];

      persistence.users = lib.mapAttrs (_: _: {
        data.directories = [".config/vivaldi"];
        cache.directories = [".cache/vivaldi"];
      }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
    };
  };
}
