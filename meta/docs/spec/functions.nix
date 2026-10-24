{
  lib,
  config,
  ...
}: let
  core = config.internal.docs.spec.core;

  /**
  Validates an RFC 145 function docstring and enforces parameter zero-drift.

  # Inputs

  `doc`
  : Parsed RFC 145 docstring attribute set.

  `f`
  : Evaluated function object to inspect for formal parameters.

  `file`
  : File path declaring the function.

  `line`
  : Line number declaring the function.

  `name`
  : Qualified function symbol name.

  # Type
  ```
  validateFunction :: AttrSet -> [AttrSet]
  ```

  # Examples
  ```nix
  validateFunction {
    name = "docsSpec.recordTodo";
    f = core.recordTodo;
    doc = null;
    file = "meta/docs/spec/core.nix";
    line = 10;
  }
  ```
  */
  validateFunction = {
    name,
    f,
    doc,
    file,
    line,
  }: let
    id = "fn:${name}";
  in
    if doc == null
    then [
      (core.recordTodo {
        inherit id file line;
        kind = "docstring";
        message = "Missing RFC 145 docstring block above function '${name}'.";
      })
    ]
    else if doc.isTodo
    then [
      (core.recordTodo {
        inherit id file line;
        kind = "docstring";
        message = doc.summary;
      })
    ]
    else let
      formalArgs = builtins.functionArgs f;
      hasFormalArgs = formalArgs != {};
      expectedNames =
        if hasFormalArgs
        then builtins.attrNames formalArgs
        else [];
      documentedNames = map (i: i.name) doc.inputs;
      missingArgs = lib.filter (arg: !builtins.elem arg documentedNames) expectedNames;
      extraArgs =
        if hasFormalArgs
        then lib.filter (arg: !builtins.elem arg expectedNames) documentedNames
        else [];

      summaryTodo =
        if doc.summary == ""
        then [
          (core.recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a summary sentence.";
          })
        ]
        else [];

      typeTodo =
        if doc.typeSignature == ""
        then [
          (core.recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a '# Type' signature.";
          })
        ]
        else [];

      paramMissingTodo =
        if missingArgs != []
        then [
          (core.recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' has undocumented formal parameters: ${lib.concatStringsSep ", " missingArgs}.";
          })
        ]
        else [];

      paramExtraTodo =
        if extraArgs != []
        then [
          (core.recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' documents non-existent formal parameters: ${lib.concatStringsSep ", " extraArgs}.";
          })
        ]
        else [];
    in
      summaryTodo ++ typeTodo ++ paramMissingTodo ++ paramExtraTodo;
in {
  internal.docs.spec.functions = {
    inherit validateFunction;
  };
}
