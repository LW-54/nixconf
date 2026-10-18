{...}: {
  flake.nixosModules.ttyd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.ttyd-web;
    domain = config.services.reverseProxy.domain;
    fqdn =
      if cfg.subdomain != null && domain != null
      then "${cfg.subdomain}.${domain}"
      else null;
  in {
    options.services.ttyd-web = {
      enable = lib.mkEnableOption "ttyd web terminal server" // {default = true;};

      subdomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "ttyd";
        description = "Subdomain prefix for reverse proxy";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 7681;
        description = "Local port for ttyd";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Local bind address for ttyd";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "lw";
        description = "System user to run ttyd and session as";
      };

      basicAuth = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = {
          admin = "$2a$14$vYmK17NeNy4sdgvOm6SAheSigD5Lnus70w8aJfQgLBceSG0hlVrPK";
        };
        description = "Basic auth credentials for the web terminal";
      };
    };

    config = lib.mkIf cfg.enable {
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

      # Auto-register with reverse proxy if enabled
      services.reverseProxy.hosts = lib.mkIf (config.services.reverseProxy.enable && fqdn != null) {
        "${fqdn}" = {
          upstream = "${cfg.address}:${toString cfg.port}";
          basicAuth = cfg.basicAuth;
        };
      };
    };
  };
}
