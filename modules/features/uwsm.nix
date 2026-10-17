{...}: {
  flake.nixosModules.uwsm = {
    lib,
    pkgs,
    ...
  }: {
    config = {
      programs.labwc.enable = lib.mkForce false;
      environment.systemPackages = [pkgs.labwc];

      programs.uwsm = {
        enable = true;
        waylandCompositors.labwc = {
          prettyName = "Labwc";
          comment = "Labwc managed by UWSM";
          binPath = "/run/current-system/sw/bin/labwc";
        };
      };
    };
  };
}
