{lib, ...}: let
  /**
  List of directory or file paths to persist, either strings or custom bind-mount attribute sets.

  # Type
  ```
  entries :: Type
  ```
  */
  entries = lib.types.listOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything));

  scope = subject: {
    directories = lib.mkOption {
      type = entries;
      default = [];
      example = ["/var/log"];
      description = ''
        List of directory paths to persist across reboots, ${subject}.
        Can be string paths or attribute sets defining custom ownership and bind-mount modes.
      '';
    };

    files = lib.mkOption {
      type = entries;
      default = [];
      example = ["/etc/machine-id"];
      description = ''
        List of individual file paths to persist across reboots, ${subject}.
        Can be string paths or attribute sets defining custom ownership and bind-mount modes.
      '';
    };
  };
  userSubmodule = lib.types.submodule {
    options = {
      data = lib.mkOption {
        type = lib.types.submodule {
          options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/data`";
        };
        default = {};
      };
      cache = lib.mkOption {
        type = lib.types.submodule {
          options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/cache`";
        };
        default = {};
      };
    };
  };

  # Pluggable persisted state formatter distinguishing [dir] vs [file]
  formatPersistence = {
    roots,
    tree,
    ...
  }: let
    entryStr = e:
      if builtins.isString e
      then e
      else e.directory or (e.file or "?");

    cleanPath = p: lib.removePrefix "/" p;

    renderRoot = path: r: let
      dirs = map (d: "[dir]  /${cleanPath (entryStr d)}/") (r.directories or []);
      files = map (f: "[file] /${cleanPath (entryStr f)}") (r.files or []);
      userDirs =
        lib.concatLists (lib.mapAttrsToList (user: u:
            map (d: "[dir]  ~${user}/${cleanPath (entryStr d)}/") (u.directories or [])) (r.users or {}));
      userFiles =
        lib.concatLists (lib.mapAttrsToList (user: u:
            map (f: "[file] ~${user}/${cleanPath (entryStr f)}") (u.files or [])) (r.users or {}));
      allLeaves = lib.sort (a: b: a < b) (dirs ++ files ++ userDirs ++ userFiles);
    in {
      label = path;
      children = map (l: {label = l;}) allLeaves;
    };

    activeRoots = lib.filterAttrs (_: r:
      (r.directories or [])
      != []
      || (r.files or []) != []
      || lib.any (u: (u.directories or []) != [] || (u.files or []) != []) (builtins.attrValues (r.users or {})))
    roots;

    treeNodes = lib.mapAttrsToList renderRoot activeRoots;
  in
    if treeNodes == []
    then null
    else lib.concatMapStringsSep "\n\n" tree treeNodes;
in {
  contract.persistence = {
    description = "Declarative state preservation across ephemeral reboots for system and user directories.";

    options =
      {
        enable = lib.mkEnableOption "declarative filesystem persistence contract" // {default = true;};

        users = lib.mkOption {
          type = lib.types.attrsOf userSubmodule;
          default = {};
          example = {
            lw = {
              data.directories = [".ssh"];
            };
          };
          description = ''
            Per-user persistence declarations keyed by username.
            `data` and `cache` root names are repository conventions, not upstream impermanence requirements.
          '';
        };
      }
      // scope "as absolute system paths under `/persist/system`";

    types = {
      inherit entries;
      user = userSubmodule;
    };

    lib = {
      entries = {
        docstring = ''
          List of directory or file paths to persist, either strings or custom bind-mount attribute sets.

          # Type
          ```
          entries :: Type
          ```
        '';
        value = entries;
      };
    };
  };

  # Persisted state section on every host page, rendered from evaluated persistence.
  docs.sections.host.persistence = {
    order = 46;
    content = ctx: let
      roots = ctx.query.eval ctx.name ["environment" "persistence"] {};
      treeText = formatPersistence {
        inherit roots;
        inherit (ctx.md) tree;
      };
    in
      if treeText == null
      then null
      else ''
        ## Persisted State

        State preserved across reboots by fulfilling the ${ctx.instanceLink "contract" "persistence"} contract:

        ${ctx.md.code "text" treeText}
      '';
  };
}
