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
      ...
    }: let
      cfg = config.default-user;
      testPassword = "test";
      testHashedPassword = "$y$j9T$wLgKY231.8j.ciV2MfEXe1$P0k5j3bCwHgnwW0Ive3w4knrgpiA4TzhCYLAnHvDZ51";
      user = config.users.users.${cfg.username};
    in {
      default-user = {
        username = Identity.username.value;
        githubUsername = Identity.githubUsername.value;
        email = Identity.email.value;
      };

      secrets.files.default-user-password-hash = {
        file = ../../secrets/users/default.yaml;
        key = "passwordHash";
        neededForUsers = true;
        testValue = testHashedPassword;
      };

      testing.default-user = {
        description = "User ${cfg.username} console login and sudo privilege escalation";

        vmChecks.login = {
          description = "${cfg.username} can log in on a virtual console with a password";
          script = self.lib.testing.mkTtyLogin {
            user = cfg.username;
            password = testPassword;
          };
        };

        vmChecks.sudo = lib.mkIf (config.security.sudo.enable && builtins.elem "wheel" user.extraGroups) {
          description = "${cfg.username} can escalate privileges with sudo";
          script = ''
            machine.wait_for_unit("multi-user.target")
            machine.succeed(${builtins.toJSON "su - ${cfg.username} -c ${lib.escapeShellArg "echo ${lib.escapeShellArg testPassword} | sudo -S -k true"}"})
          '';
        };
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
        ];
      };
    };
  };
}
