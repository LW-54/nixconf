{ ... }:

{
  flake.nixosModules.persistence = { lib, ... }:
    let
      entries = lib.types.listOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything));

      scope = subject: {
        directories = lib.mkOption {
          type = entries;
          default = [ ];
          description = "Directories to persist, ${subject}.";
        };

        files = lib.mkOption {
          type = entries;
          default = [ ];
          description = "Files to persist, ${subject}.";
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
                type = lib.types.submodule {
                  options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/userdata`";
                };
                default = { };
              };
              cache = lib.mkOption {
                type = lib.types.submodule {
                  options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/usercache`";
                };
                default = { };
              };
            };
          });
          default = { };
          description = ''
            Per-user persistence declarations keyed by username.
            `userdata` and `usercache` are repository conventions, not upstream impermanence requirements.
          '';
          example = {
            alice = {
              data.directories = [ "Documents" "Projects" ".ssh" ];
              cache.directories = [ ".cache/nix-index" ];
            };
          };
        };
      } // scope "as absolute system paths under `/persist/system`";
    };
}
