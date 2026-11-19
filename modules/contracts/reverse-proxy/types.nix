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

      forwardAuth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enforce proxy-level forward authentication (Single Sign-On)
          before forwarding requests to the upstream service.
        '';
      };

      bypassPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["/drop*" "/share*"];
        description = ''
          URL path patterns on this virtual host that bypass proxy forward authentication
          and allow unauthenticated public requests.
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

  forwardAuthSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "global forward authentication middleware at the reverse proxy boundary";

      upstream = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "127.0.0.1:9091";
        description = ''
          Target host and port of the forward authentication service endpoint
          queried before proxying protected virtual hosts.
        '';
      };

      uri = lib.mkOption {
        type = lib.types.str;
        default = "/api/authz/forward-auth";
        example = "/api/authz/forward-auth";
        description = ''
          Verification sub-request URI path queried on the forward authentication upstream.
        '';
      };

      copyHeaders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "Remote-User"
          "Remote-Groups"
          "Remote-Name"
          "Remote-Email"
        ];
        example = ["Remote-User" "Remote-Groups"];
        description = ''
          HTTP response headers copied from a successful forward authentication sub-request
          to the proxied upstream request.
        '';
      };
    };
  };
in {
  contract.reverse-proxy.types = {
    host = hostSubmodule;
    portAllocation = portAllocationSubmodule;
    forwardAuth = forwardAuthSubmodule;
    inherit fqdn;
  };
}
