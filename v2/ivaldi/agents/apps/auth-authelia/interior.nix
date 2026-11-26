{bound, ...}: {
  nixos = {
    environment.etc."aky/auth-authelia.json".text = builtins.toJSON {
      ldapBackend = bound."auth:ldap".url;
      listen = "127.0.0.1:9091";
    };
  };
}
