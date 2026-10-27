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
    };
  };
}
