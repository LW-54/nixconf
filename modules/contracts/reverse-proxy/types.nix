{lib, ...}: let
  /**
  Type validating Fully Qualified Domain Names (FQDN) matching standard internet hostname format.
  */
  fqdn = lib.types.mkOptionType {
    name = "fqdn";
    description = "Fully qualified domain name";
    check = x: builtins.isString x && builtins.match "^([a-zA-Z0-9][-a-zA-Z0-9]*\\.)+[a-zA-Z]{2,}$" x != null;
    merge = lib.options.mergeOneOption;
  };

  hostSubmodule = lib.types.submodule {
    options = {
      upstream = lib.mkOption {
        type = lib.types.str;
        example = "127.0.0.1:8080";
        description = ''
          Target upstream socket, host, or IP address and port where the service
          is listening and accepting proxied HTTP/WebSocket connections.
        '';
      };

      basicAuth = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = null;
        example = {admin = "$2a$14$...";};
        description = ''
          Optional map of usernames to bcrypt-hashed password strings for
          HTTP Basic Authentication enforcement at the proxy boundary.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Raw backend-specific configuration directives injected directly
          into the virtual host definition (e.g. custom headers or timeouts).
        '';
      };
    };
  };

  portAllocationSubmodule = lib.types.submodule {
    options = {
      owner = lib.mkOption {
        type = lib.types.str;
        example = "vault.example.com";
        description = "Service, virtual host, or component identifier claiming this local port.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "127.0.0.1";
        description = "Local bind IP address or wildcard interface for the port allocation.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        example = 23469;
        description = "Allocated local TCP or UDP port number.";
      };

      protocol = lib.mkOption {
        type = lib.types.enum ["tcp" "udp"];
        default = "tcp";
        example = "tcp";
        description = "Transport protocol (`tcp` or `udp`) for the port allocation.";
      };
    };
  };
in {
  contract.reverse-proxy.types = {
    host = hostSubmodule;
    portAllocation = portAllocationSubmodule;
    inherit fqdn;
  };
}
