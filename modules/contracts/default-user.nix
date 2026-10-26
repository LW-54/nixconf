{lib, ...}: {
  contract.default-user = {
    description = "Default primary user account identification, credentials, and configuration injection.";

    options = {
      enable = lib.mkEnableOption "system default user contract" // {default = true;};

      username = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "Username of the default user account.";
      };

      githubUsername = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "GitHub username of the default user.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        example = "alice@example.com";
        description = "Primary email address associated with the default user.";
      };

      fullName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "Alice Smith";
        description = "Display name / GECOS description of the default user.";
      };

      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        example = [];
        description = ''
          Arbitrary NixOS configuration modules contributed by other features
          for the default user, evaluated and merged into the system when enabled.
        '';
      };
    };

    lib = {
      forDefaultUser = {
        docstring = ''
          Conditionally evaluates a user configuration function with the configured default username if default-user is enabled.

          # Inputs

          `config`
          : The evaluated NixOS system configuration.

          `f`
          : Function receiving the default username string and returning an attribute set.

          # Type
          ```
          forDefaultUser :: Config -> (String -> AttrSet) -> AttrSet
          ```

          # Examples
          ```nix
          forDefaultUser config (user: {
            users.users.''${user}.extraGroups = [ "wheel" ];
          })
          ```
        '';
        value = config: f:
          lib.optionalAttrs (config.default-user.enable or false) (f config.default-user.username);
      };
    };
  };
}
