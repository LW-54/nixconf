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
    file = "modules/${
      if kind == "host"
      then "hosts/${name}.nix"
      else if kind == "contract"
      then "contracts/${name}.nix"
      else if kind == "impl"
      then "implementations/${name}.nix"
      else if kind == "feature"
      then "features/${name}.nix"
      else "meta/primitives/lib.nix"
    }";
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
