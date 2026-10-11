{ self, ... }:

{
  flake.nixosModules.persistence = { lib, ... }:
    let
      entryType = lib.types.oneOf [
        lib.types.str
        (lib.types.attrsOf lib.types.anything)
      ];

      userPathsSubmodule = lib.types.submodule {
        options = {
          directories = lib.mkOption {
            type = lib.types.listOf entryType;
            default = [ ];
            description = "Relative home-directory paths (or impermanence attribute sets) persisted for this user.";
          };

          files = lib.mkOption {
            type = lib.types.listOf entryType;
            default = [ ];
            description = "Relative home-file paths (or impermanence attribute sets) persisted for this user.";
          };
        };
      };
    in
    {
      options.persistence = {
        enable = lib.mkEnableOption "multi-user persistence mapped to impermanence";

        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              data = lib.mkOption {
                type = userPathsSubmodule;
                default = { };
                description = ''
                  User data persisted under `/persist/users/<name>/userdata`.
                  Entries here are interpreted as paths relative to `/home/<name>` when passed through `environment.persistence.<root>.users.<name>`.
                '';
              };

              cache = lib.mkOption {
                type = userPathsSubmodule;
                default = { };
                description = ''
                  User cache persisted under `/persist/users/<name>/usercache`.
                  `userdata` and `usercache` are repository naming conventions, not upstream impermanence requirements.
                '';
              };
            };
          });
          default = { };
          description = "Per-user persistence declarations keyed by username.";
          example = {
            alice = {
              data.directories = [ "Documents" "Projects" ".ssh" ];
              cache.directories = [ ".cache/nix-index" ];
            };
          };
        };

        directories = lib.mkOption {
          type = lib.types.listOf entryType;
          default = [ ];
          description = "Additional absolute system directories persisted under `/persist/system`.";
        };

        files = lib.mkOption {
          type = lib.types.listOf entryType;
          default = [ ];
          description = "Additional absolute system files persisted under `/persist/system`.";
        };
      };
    };
}
