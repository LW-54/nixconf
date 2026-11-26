{...}: {
  nixos = {
    environment.etc."aky/auth-lldap.json".text = builtins.toJSON {
      ldapListen = "127.0.0.1:3890";
      encapsulatedIn = "auth-stack";
    };
  };
}
