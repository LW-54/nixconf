{
  lib,
  config,
  ...
}: let
  core = config.internal.docs.spec.core;

  /**
  Validates a primitive definition against formal repository schema requirements.

  # Inputs

  `kind`
  : Primitive classification: "host", "contract", "impl", or "feature".

  `name`
  : Unique identifier name of the primitive instance.

  `primitive`
  : The evaluated primitive configuration attribute set.

  # Type
  ```
  validatePrimitive :: AttrSet -> [AttrSet]
  ```
  */
  validatePrimitive = {
    kind,
    name,
    primitive,
  }: let
    id = "${kind}:${name}";
    normKind =
      if kind == "impl"
      then "implementation"
      else kind;
    file =
      if kind == "primitive"
      then "primitives/primitive.nix"
      else if kind == "host"
      then "modules/hosts/${name}.nix"
      else if kind == "contract"
      then "modules/contracts/${name}.nix"
      else if kind == "impl" || kind == "implementation"
      then "modules/implementations/${name}.nix"
      else if kind == "feature"
      then "modules/features/${name}.nix"
      else "primitives/lib.nix";

    schema = config.flake.schemas.${normKind} or null;
    checkDetails =
      if schema != null && builtins.isFunction (schema.inventory or null)
      then let
        inv = schema.inventory {${name} = primitive;};
      in
        inv.children.${name}.checkDetails or {}
      else {};

    failedChecks = lib.filterAttrs (_: chk: !(chk.valid or true)) checkDetails;
  in
    lib.mapAttrsToList (
      chkName: chk:
        core.recordTodo {
          inherit id file;
          line = 1;
          kind = "primitive-${chkName}";
          message = chk.message or "Primitive '${id}' failed check '${chkName}'.";
        }
    )
    failedChecks;
in {
  internal.docs.spec.primitives = {
    inherit validatePrimitive;
  };
}
