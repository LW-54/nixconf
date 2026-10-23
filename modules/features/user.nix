{lib, ...}: let
  normalUsers = config: lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users;
  normalUserNames = config: builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
  forNormalUsers = config: f:
    lib.mapAttrs (userName: user: f userName user) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
in {
  feature.user = {
    description = "Normal user account helper functions and querying utilities.";
    lib = {
      normalUsers = {
        docstring = ''
          Filters `config.users.users` down to normal human user accounts (`isNormalUser = true`).

          # Inputs

          `config`
          : Evaluated NixOS system configuration.

          # Type

          ```
          normalUsers :: Config -> AttrSet
          ```

          # Examples
          ```nix
          normalUsers config
          ```
        '';
        value = normalUsers;
      };

      normalUserNames = {
        docstring = ''
          Returns list of usernames for all normal users on the system.

          # Inputs

          `config`
          : Evaluated NixOS system configuration.

          # Type

          ```
          normalUserNames :: Config -> [String]
          ```

          # Examples
          ```nix
          normalUserNames config
          ```
        '';
        value = normalUserNames;
      };

      forNormalUsers = {
        docstring = ''
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

          # Examples
          ```nix
          forNormalUsers config (userName: user: {
            data.directories = [".config/example"];
          })
          ```
        '';
        value = forNormalUsers;
      };
    };
  };
}
