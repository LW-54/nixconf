{
  config,
  lib,
  self,
  ...
}: let
  helpers = config.internal.rclone;
in {
  options.internal.rclone = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal helper functions for the rclone storage implementation.";
  };

  config = {
    /**
    Declarative multi-provider rclone mount, crypt, and union tiering runtime implementation.
    */
    implementation.rclone = {
      contract = "storage";
      description = "Declarative multi-provider storage mounts, crypt/union tiering, and rclone configuration provisioning.";
      module = {
        config,
        lib,
        pkgs,
        utils,
        ...
      }: let
        state = helpers.mkHostState {
          inherit self config lib;
        };
        tmpl = helpers.mkTemplate {
          inherit config lib pkgs state;
        };
        units = helpers.mkUnits {
          inherit self config lib pkgs utils state tmpl;
        };
        testingCfg = helpers.mkTesting {
          inherit self config lib pkgs state tmpl;
        };
      in {
        environment.systemPackages = [pkgs.rclone];
        system.fsPackages = [pkgs.rclone];
        programs.fuse.userAllowOther = lib.mkDefault true;

        secrets = {
          files = state.secretFileAttrs;

          templates."rclone.conf" = {
            mode = "0400";
            content = tmpl.rcloneTemplateContent;
          };
        };

        environment.etc."rclone/rclone.conf".source = "/run/rclone/rclone.conf";

        persistence.directories = ["/var/cache/rclone"];
        backup.exclude = ["/var/cache/rclone"];

        systemd = {
          inherit (units) services timers;
          mounts = units.systemdMountEntries;
          automounts = units.systemdAutomountEntries;
        };

        testing = {
          vm.allowedFailedUnits = units.nonAutomountUnits;
          rclone = testingCfg;
        };
      };
    };
  };
}
