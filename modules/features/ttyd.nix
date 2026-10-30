{self, ...}: {
  feature.ttyd = {
    description = "Web terminal server bridging browser sessions to system shells via ttyd.";
    modules = {
      ttyd = {
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
          // self.lib.reverse-proxy.mkOption {
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
                then let
                  normalNames = builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
                in
                  if normalNames != []
                  then builtins.head normalNames
                  else "root"
                else user;
              description = "System user to run ttyd and session as";
            };
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
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
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
        ]);
      };
    };
  };
}
