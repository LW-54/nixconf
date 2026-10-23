{
  lib,
  config,
  ...
}: let
  core = config.internal.docs.spec.core;

  /**
  Validates metadata for an executable package, NixOS module, or development shell.

  # Inputs

  `id`
  : Canonical entity identifier (e.g. "pkg:bw", "shell:sops-admin", "module:git").

  `kind`
  : Entity classification ("pkg", "shell", "module").

  `meta`
  : Metadata attribute set (containing description, maintainers, etc.).

  `name`
  : Entity name identifier.

  # Type
  ```
  validateMeta :: AttrSet -> [AttrSet]
  ```
  */
  validateMeta = {
    kind,
    name,
    meta ? {},
    id ? "${kind}:${name}",
  }: let
    desc = meta.description or null;
  in
    if desc == null || lib.trim desc == ""
    then [
      (core.recordTodo {
        inherit id;
        file = "unknown";
        line = 1;
        kind = "meta-description";
        message = "${kind} '${name}' is missing a meta.description.";
      })
    ]
    else [];
in {
  internal.docs.spec.meta = {
    inherit validateMeta;
  };
}
