{...}: {
  flake.nixosModules.reverse-proxy = {lib, ...}: {
    key = "contracts-reverse-proxy";

    options.services.reverseProxy = {
      enable = lib.mkEnableOption "system reverse proxy" // {default = true;};

      domain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Base domain name for reverse-proxied services (e.g. adje.app).";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            upstream = lib.mkOption {
              type = lib.types.str;
              example = "127.0.0.1:8222";
              description = "Upstream address:port to proxy requests to.";
            };

            basicAuth = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
              default = null;
              example = {admin = "$2a$14$...";};
              description = "Attribute set of username to bcrypt hashed password.";
            };

            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra reverse proxy directives.";
            };
          };
        });
        default = {};
        description = "Virtual host configurations mapped to upstream targets.";
      };
    };
  };
}
