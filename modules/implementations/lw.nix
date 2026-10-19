{...}: let
  lwIdentity = {
    username = "lw";
    githubUsername = "LW-54";
    email = "leonardwilsonb@gmail.com";
  };
in {
  flake.lib = {
    lw = lwIdentity;
    default-user = lwIdentity;
  };

  flake.nixosModules = rec {
    lw = {
      config,
      lib,
      ...
    }: let
      cfg = config.default-user;
    in {
      config = lib.mkIf cfg.enable {
        default-user = {
          inherit (lwIdentity) username githubUsername email;
        };

        secrets.files.default-user-password-hash = {
          file = ../../secrets/users/default.yaml;
          key = "passwordHash";
          neededForUsers = true;
        };

        users.users.${cfg.username} = {
          isNormalUser = true;
          description = "lw";
          extraGroups = ["wheel" "networkmanager"];
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

    default-user = lw;
  };
}
