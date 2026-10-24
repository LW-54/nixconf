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
    file =
      if kind == "primitive"
      then "primitives/primitive.nix"
      else if kind == "host"
      then "modules/hosts/${name}.nix"
      else if kind == "contract"
      then "modules/contracts/${name}.nix"
      else if kind == "impl"
      then "modules/implementations/${name}.nix"
      else if kind == "feature"
      then "modules/features/${name}.nix"
      else "primitives/lib.nix";
    desc = primitive.description or "";
  in
    if desc == ""
    then [
      (core.recordTodo {
        inherit id file;
        line = 1;
        kind = "primitive-description";
        message = "Primitive '${id}' is missing a required formal description.";
      })
    ]
    else [];
in {
  internal.docs.spec.primitives = {
    inherit validatePrimitive;
  };
}
