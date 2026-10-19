{lib, ...}: {
  mkContract.default-user = {
    options = {
      enable = lib.mkEnableOption "system default user capability contract" // {default = true;};

      username = lib.mkOption {
        type = lib.types.str;
        description = "Username of the default user account.";
      };

      githubUsername = lib.mkOption {
        type = lib.types.str;
        description = "GitHub username of the default user.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "Primary email address associated with the default user.";
      };

      fullName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Display name / GECOS description of the default user.";
      };

      extraModules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = ''
          Arbitrary NixOS configuration modules contributed by other features
          for the default user, evaluated and merged into the system when enabled.
        '';
      };
    };

    collection = false;

    extraLib = {
      forDefaultUser = config: f:
        lib.optionalAttrs (config.default-user.enable or false) (f config.default-user.username);
    };
  };
}
