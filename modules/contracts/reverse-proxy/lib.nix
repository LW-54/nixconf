{lib, ...}: let
  /**
  Deterministically maps a service or subdomain identifier to an unprivileged port in [10000, 59999].
  */
  mkPort = name: let
    base = 10000;
    span = 50000;
    hex = builtins.substring 0 12 (builtins.hashString "sha256" name);
    num = (builtins.fromTOML "v = 0x${hex}").v;
  in
    base + (num - (num / span) * span);

  normalizeAddress = addr:
    if addr == "localhost"
    then "127.0.0.1"
    else if addr == "*" || addr == ""
    then "0.0.0.0"
    else addr;

  isWildcardAddress = addr: addr == "0.0.0.0" || addr == "::";

  addressesConflict = a: b: let
    na = normalizeAddress a;
    nb = normalizeAddress b;
  in
    na == nb || isWildcardAddress na || isWildcardAddress nb;

  /**
  Detects conflicting port allocations across matching protocol, port, and overlapping bind addresses.
  */
  findPortConflicts = allocations: let
    grouped = lib.groupBy (a: "${a.protocol or "tcp"}:${toString a.port}") allocations;
    checkGroup = _: entries: let
      len = builtins.length entries;
      indices = lib.range 0 (len - 1);
      hasCollision =
        len
        > 1
        && lib.any (
          i:
            lib.any (
              j:
                i
                < j
                && addressesConflict ((builtins.elemAt entries i).address or "127.0.0.1") ((builtins.elemAt entries j).address or "127.0.0.1")
            )
            indices
        )
        indices;
      first = builtins.head entries;
    in
      if hasCollision
      then [
        {
          protocol = first.protocol or "tcp";
          inherit (first) port;
          owners = map (e: "${e.owner} (${e.address or "127.0.0.1"})") entries;
        }
      ]
      else [];
  in
    lib.concatLists (lib.mapAttrsToList checkGroup grouped);
in {
  contract.reverse-proxy.lib = {
    mkPort = {
      docstring = ''
        Deterministically map a service or subdomain identifier to a non-privileged local port in the range `10000..59999`.

        # Inputs

        `name`
        : Service or subdomain identifier used as the deterministic hash seed.

        # Type
        ```
        mkPort :: String -> Int
        ```

        # Examples
        ```nix
        reverse-proxy.mkPort "vaultwarden"
        ```
      '';
      value = mkPort;
    };

    findPortConflicts = {
      docstring = ''
        Inspect a list of port allocations and return descriptors for any colliding `(protocol, port)` bindings with overlapping addresses.

        # Inputs

        `allocations`
        : List of port allocation attribute sets (`{ owner, address ? "127.0.0.1", port, protocol ? "tcp" }`).

        # Type
        ```
        findPortConflicts :: [PortAllocation] -> [PortConflict]
        ```

        # Examples
        ```nix
        reverse-proxy.findPortConflicts config.reverse-proxy.ports
        ```
      '';
      value = findPortConflicts;
    };
  };
}
