{lib, ...}: {
  flake.lib.user = {
    /**
    Filters `config.users.users` down to normal human user accounts (`isNormalUser = true`).

    # Inputs

    `config`
    : Evaluated NixOS system configuration.

    # Type

    ```
    normalUsers :: Config -> AttrSet
    ```
    */
    normalUsers = config: lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users;

    /**
    Returns list of usernames for all normal users on the system.

    # Inputs

    `config`
    : Evaluated NixOS system configuration.

    # Type

    ```
    normalUserNames :: Config -> [String]
    ```
    */
    normalUserNames = config: builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);

    /**
    Maps an attribute set generation function across all normal users.

    # Inputs

    `config`
    : Evaluated NixOS system configuration.

    `f`
    : Function `(userName -> userAttrs -> AttrSet)`.

    # Type

    ```
    forNormalUsers :: Config -> (String -> AttrSet -> AttrSet) -> AttrSet
    ```
    */
    forNormalUsers = config: f:
      lib.mapAttrs (userName: user: f userName user) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
  };
}
