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
          }
          // {
            user = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              apply = user:
                if user == null
                then let
                  normalNames = self.lib.user.normalUserNames config;
                in
                  if normalNames != []
                  then builtins.head normalNames
                  else "root"
                else user;
              description = "System user to run ttyd and session as.";
            };
          }
          // self.lib.monitoring.mkOption {
            units = ["ttyd-web.service"];
          }
          // self.lib.resources.mkOption {
            tier = "standard";
            memory = {
              high = "20%";
              max = "35%";
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
                ExecStart = "${pkgs.ttyd}/bin/ttyd -i ${cfg.address} -p ${toString cfg.port} -W ${pkgs.bashInteractive}/bin/bash -l";
                Restart = "always";
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.monitoring.mkConfig {
            inherit config cfg;
            name = "ttyd";
          })
          (self.lib.resources.mkConfig {inherit config cfg;})
        ]);
      };
    };
  };
}
