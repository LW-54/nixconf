{self, ...}: {
  flake.nixosModules.ttyd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.ttyd-web;
  in {
    options.services.ttyd-web =
      {
        enable = lib.mkEnableOption "ttyd web terminal server" // {default = true;};
      }
      // self.lib."reverse-proxy".mkOptions {
        subdomain = "ttyd";
        port = 7681;
        basicAuth = {admin = "$2a$14$vYmK17NeNy4sdgvOm6SAheSigD5Lnus70w8aJfQgLBceSG0hlVrPK";};
      }
      // {
        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          apply = user:
            if user == null
            then lib.head (lib.attrNames config.users.account)
            else user;
          description = "System user to run ttyd and session as";
        };
      };

    config = lib.mkIf cfg.enable ({
        environment.systemPackages = [pkgs.ttyd];

        systemd.services.ttyd-web = {
          description = "ttyd Web Terminal";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig = {
            User = cfg.user;
            WorkingDirectory = "/home/${cfg.user}";
            ExecStart = "${pkgs.ttyd}/bin/ttyd -i ${cfg.address} -p ${toString cfg.port} -W ${pkgs.bashInteractive}/bin/bash";
            Restart = "always";
          };
        };
      }
      // self.lib."reverse-proxy".mkConfig {inherit config cfg;});
  };
}
