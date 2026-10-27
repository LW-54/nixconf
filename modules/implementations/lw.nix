{self, ...}: let
  Identity = {
    username = {
      docstring = ''
        Primary login username for user account lw.

        # Type
        ```
        username :: String
        ```
      '';
      value = "lw";
    };

    githubUsername = {
      docstring = ''
        Primary GitHub account username for user account lw.

        # Type
        ```
        githubUsername :: String
        ```
      '';
      value = "LW-54";
    };

    email = {
      docstring = ''
        Primary email address for user account lw.

        # Type
        ```
        email :: String
        ```
      '';
      value = "leonardwilsonb@gmail.com";
    };
  };
in {
  /**
  Primary human user account orchestration and identity provisioning.
  */
  implementation.lw = {
    contract = "default-user";
    description = "Primary human user account orchestration and identity provisioning.";
    lib = Identity;
    module = {
      config,
      lib,
      options,
      ...
    }: let
      cfg = config.default-user;
    in {
      config = lib.mkIf cfg.enable {
        default-user = {
          username = Identity.username.value;
          githubUsername = Identity.githubUsername.value;
          email = Identity.email.value;
        };

        secrets.files.default-user-password-hash = {
          file = ../../secrets/users/default.yaml;
          key = "passwordHash";
          neededForUsers = true;
        };

        users.users.${cfg.username} = {
          isNormalUser = true;
          description = cfg.username;
          extraGroups = ["wheel" "networkmanager"];
          hashedPasswordFile = config.secrets.files.default-user-password-hash.path;
        };

        users.users.root = {
          hashedPasswordFile = config.secrets.files.default-user-password-hash.path;
        };

        home.users.${cfg.username} = {};

        persistence.users.${cfg.username} = {
          data.directories = [
            "nixconf"
            "Documents"
            "Downloads"
            "Projects"
            ".ssh"
            ".gnupg"
          ];
        };
      };
    };
  };
}
