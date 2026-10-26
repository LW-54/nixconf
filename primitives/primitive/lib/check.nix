{
  lib,
  parser,
  ...
}: let
  /**
  Normalizes a message string into a single trimmed line.
  */
  cleanMsg = msg: lib.concatStringsSep " " (lib.filter (s: s != "") (lib.splitString "\n" msg));

  /**
  Records a documentation diagnostic and emits an evaluation warning.
  */
  recordTodo = {
    id,
    kind,
    file ? "unknown",
    line ? 1,
    message,
  }: let
    diag = {
      inherit
        id
        kind
        file
        line
        ;
      message = cleanMsg message;
    };
    warnMsg = "[docs-todo] ${file}:${toString line} (${id}): ${diag.message}";
  in
    lib.warn warnMsg diag;

  /**
  Validates a NixOS option description, types, and defaults against the repository style specification.
  */
  validOption = {
    path,
    option,
    isContract ? false,
    file ? "unknown",
    line ? 1,
  }: let
    id = "opt:${path}";
    rawDesc = option.description or null;
  in
    if rawDesc == null || lib.trim rawDesc == ""
    then [
      (recordTodo {
        inherit id file line;
        kind = "option";
        message = "Option '${path}' has an empty or missing description.";
      })
    ]
    else let
      desc = lib.trim rawDesc;
      isTodo = lib.hasPrefix "TODO" desc;
    in
      if isTodo
      then [
        (recordTodo {
          inherit id file line;
          kind = "option";
          message = desc;
        })
      ]
      else let
        len = builtins.stringLength desc;
        lenCheck =
          if len < 15
          then builtins.throw "Option '${path}' description is too short (${toString len} chars, min 15): '${desc}'"
          else true;

        startMatch = builtins.match "^[A-Z0-9`].*" desc;
        startCheck =
          if startMatch == null
          then builtins.throw "Option '${path}' description must start with a capital letter, digit, or backtick: '${desc}'"
          else true;

        endCheck =
          if !(lib.hasSuffix "." desc || lib.hasSuffix "`" desc || lib.hasSuffix ")" desc)
          then builtins.throw "Option '${path}' description must end with terminal punctuation (., `, or )): '${desc}'"
          else true;

        typeName = option.type.name or "";
        boolCheck =
          if typeName == "bool" && !(lib.hasPrefix "Whether " desc)
          then builtins.throw "Boolean option '${path}' description must start with 'Whether ': '${desc}'"
          else true;

        contractExampleCheck =
          if isContract && (option.default or "NO_DEFAULT" == null || option.default or "NO_DEFAULT" == [] || option.default or "NO_DEFAULT" == {})
          then
            if !(option ? example && option.example != null)
            then [
              (recordTodo {
                inherit id file line;
                kind = "contract-example";
                message = "Contract option '${path}' has empty default but no example declared.";
              })
            ]
            else []
          else [];
      in
        assert lenCheck;
        assert startCheck;
        assert endCheck;
        assert boolCheck; contractExampleCheck;

  /**
  Recursively traverses an option attribute tree and validates each option declaration.
  */
  collectAndValidateOptions = {
    prefix,
    attrs,
    isContract ? false,
    file ? "unknown",
  }:
    lib.concatMap (k: let
      v = attrs.${k};
      currPath =
        if prefix == ""
        then k
        else "${prefix}.${k}";
    in
      if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
      then
        validOption {
          path = currPath;
          option = v;
          inherit isContract file;
          line = 1;
        }
      else if builtins.isAttrs v && !lib.isDerivation v
      then
        collectAndValidateOptions {
          prefix = currPath;
          attrs = v;
          inherit isContract file;
        }
      else []) (builtins.attrNames attrs);

  /**
  Validates an RFC 145 function docstring and enforces parameter zero-drift.
  */
  validFunction = {
    name,
    f,
    doc,
    file ? "unknown",
    line ? 1,
  }: let
    id = "fn:${name}";
  in
    if doc == null
    then [
      (recordTodo {
        inherit id file line;
        kind = "docstring";
        message = "Missing RFC 145 docstring block above function '${name}'.";
      })
    ]
    else if doc.isTodo
    then [
      (recordTodo {
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
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a summary sentence.";
          })
        ]
        else [];

      typeTodo =
        if doc.typeSignature == ""
        then [
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a '# Type' signature.";
          })
        ]
        else [];

      paramMissingTodo =
        if missingArgs != []
        then [
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' has undocumented formal parameters: ${lib.concatStringsSep ", " missingArgs}.";
          })
        ]
        else [];

      paramExtraTodo =
        if extraArgs != []
        then [
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' documents non-existent formal parameters: ${lib.concatStringsSep ", " extraArgs}.";
          })
        ]
        else [];
    in
      summaryTodo ++ typeTodo ++ paramMissingTodo ++ paramExtraTodo;

  /**
  Validates documentation metadata for an individual symbol (function or non-function value).
  */
  validDocstring = {
    name,
    val,
    parsedDoc,
    file ? "unknown",
    line ? 1,
  }: let
    id = "fn:${name}";
    isFn = builtins.isFunction val;
  in
    if parsedDoc == null || parsedDoc.summary == ""
    then [
      (recordTodo {
        inherit id file line;
        kind = "docstring";
        message = "Library symbol 'flake.lib.${name}' is missing documentation.";
      })
    ]
    else if isFn
    then
      validFunction {
        inherit name file line;
        f = val;
        doc = parsedDoc;
      }
    else let
      summaryTodo =
        if parsedDoc.summary == ""
        then [
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a summary sentence.";
          })
        ]
        else [];
      typeTodo =
        if parsedDoc.typeSignature == ""
        then [
          (recordTodo {
            inherit id file line;
            kind = "docstring";
            message = "Symbol '${name}' docstring is missing a '# Type' signature.";
          })
        ]
        else [];
    in
      summaryTodo ++ typeTodo;

  check = {
    inherit
      cleanMsg
      recordTodo
      validOption
      validFunction
      validDocstring
      ;

    mkCheck = predicate: message: inst: {
      valid = predicate inst;
      message =
        if message != null
        then message
        else "Failed custom check predicate.";
    };

    hasAttr = attr: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = inst ? ${attr};
          message = msgOrInst;
        }
      else {
        valid = msgOrInst ? ${attr};
        message = "Must declare '${attr}'.";
      };

    hasAttrs = attr: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = inst ? ${attr} && builtins.isAttrs inst.${attr};
          message = msgOrInst;
        }
      else {
        valid = msgOrInst ? ${attr} && builtins.isAttrs msgOrInst.${attr};
        message = "Attribute '${attr}' must be an attribute set.";
      };

    hasNonEmptyAttrs = attr: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = inst ? ${attr} && builtins.isAttrs inst.${attr} && inst.${attr} != {};
          message = msgOrInst;
        }
      else {
        valid = msgOrInst ? ${attr} && builtins.isAttrs msgOrInst.${attr} && msgOrInst.${attr} != {};
        message = "Attribute '${attr}' must be a non-empty attribute set.";
      };

    hasString = attr: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = inst ? ${attr} && builtins.isString inst.${attr} && inst.${attr} != "";
          message = msgOrInst;
        }
      else {
        valid = msgOrInst ? ${attr} && builtins.isString msgOrInst.${attr} && msgOrInst.${attr} != "";
        message = "Attribute '${attr}' must be a non-empty string.";
      };

    hasFunction = attr: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = inst ? ${attr} && builtins.isFunction inst.${attr};
          message = msgOrInst;
        }
      else {
        valid = msgOrInst ? ${attr} && builtins.isFunction msgOrInst.${attr};
        message = "Attribute '${attr}' must be a function.";
      };

    any = checkList: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = lib.any (c: let
            res = c inst;
          in
            if builtins.isAttrs res && res ? valid
            then res.valid
            else res)
          checkList;
          message = msgOrInst;
        }
      else {
        valid = lib.any (c: let
          res = c msgOrInst;
        in
          if builtins.isAttrs res && res ? valid
          then res.valid
          else res)
        checkList;
        message = "At least one condition must be satisfied.";
      };

    all = checkList: msgOrInst:
      if builtins.isString msgOrInst
      then
        inst: {
          valid = lib.all (c: let
            res = c inst;
          in
            if builtins.isAttrs res && res ? valid
            then res.valid
            else res)
          checkList;
          message = msgOrInst;
        }
      else {
        valid = lib.all (c: let
          res = c msgOrInst;
        in
          if builtins.isAttrs res && res ? valid
          then res.valid
          else res)
        checkList;
        message = "All conditions must be satisfied.";
      };

    /**
    Schema check verifying that all options in an instance (such as a contract) satisfy style guidelines.
    */
    validOptions = inst: let
      rawOptions = inst.options or {};
      todos =
        if builtins.isAttrs rawOptions
        then
          collectAndValidateOptions {
            prefix = "";
            attrs = rawOptions;
            isContract = true;
          }
        else [];
      isValid = todos == [];
    in {
      valid = isValid;
      message =
        if isValid
        then "All declared options conform to the option specification."
        else "Instance has ${toString (builtins.length todos)} non-conforming option declaration(s).";
      inherit todos;
    };

    /**
    Schema check verifying that all library symbols in an instance satisfy RFC 145 docstring specifications.
    */
    validSymbols = inst: let
      symAttrs = inst.symbols or (inst.lib or {});
      todos =
        if builtins.isAttrs symAttrs
        then
          lib.concatMap (symName: let
            rawSym = symAttrs.${symName};
            hasDocAttr = builtins.isAttrs rawSym && rawSym ? docstring && rawSym.docstring != null;
            rawComment =
              if hasDocAttr
              then rawSym.docstring
              else null;
            val =
              if builtins.isAttrs rawSym && rawSym ? value
              then rawSym.value
              else rawSym;
            parsedDoc =
              if parser != null
              then parser.parseDocstring rawComment
              else null;
          in
            if symName == "types" || symName == "options"
            then []
            else
              validDocstring {
                name = symName;
                inherit val parsedDoc;
                file = "unknown";
                line = 1;
              }) (builtins.attrNames symAttrs)
        else [];
      isValid = todos == [];
    in {
      valid = isValid;
      message =
        if isValid
        then "All exported symbols conform to RFC 145 docstring specifications."
        else "Instance has ${toString (builtins.length todos)} undocumented or non-conforming symbol(s).";
      inherit todos;
    };

    /**
    Schema check verifying that metadata descriptions are defined on packages and development shells.
    */
    validMeta = inst: let
      pkgs =
        if inst ? packages && builtins.isAttrs inst.packages
        then inst.packages
        else {};
      shells =
        if inst ? devShells && builtins.isAttrs inst.devShells
        then inst.devShells
        else {};

      checkItem = kind: name: item: let
        desc = item.meta.description or (item.description or null);
      in
        if desc == null || lib.trim desc == ""
        then [
          (recordTodo {
            id = "${kind}:${name}";
            inherit kind;
            file = "unknown";
            line = 1;
            message = "${kind} '${name}' is missing a meta.description.";
          })
        ]
        else [];

      pkgTodos = lib.concatLists (lib.mapAttrsToList (checkItem "pkg") pkgs);
      shellTodos = lib.concatLists (lib.mapAttrsToList (checkItem "shell") shells);
      allTodos = pkgTodos ++ shellTodos;
      isValid = allTodos == [];
    in {
      valid = isValid;
      message =
        if isValid
        then "All packages and shells declare valid metadata descriptions."
        else "Instance has ${toString (builtins.length allTodos)} entity(ies) missing metadata.";
      todos = allTodos;
    };

    /**
    Flattens a nested option attribute tree into a flat attrset mapping dot-separated paths to option definitions.
    */
    flattenOptions = prefix: attrs:
      lib.concatMapAttrs (
        k: v: let
          currPath =
            if prefix == ""
            then k
            else "${prefix}.${k}";
        in
          if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
          then {${currPath} = v;}
          else if builtins.isAttrs v && !lib.isDerivation v
          then check.flattenOptions currPath v
          else {}
      )
      attrs;
  };
in {
  _module.args = {
    inherit check;
    checkHelpers = check;
  };

  primitive.primitive.lib = {
    check = {
      docstring = ''
        Generic validation check constructors, predicates, and style specification verifiers.

        # Type
        ```
        check :: AttrSet
        ```

        # Values
        - `cleanMsg msg`: Normalizes multiline messages into single-line strings.
        - `recordTodo diag`: Standard diagnostic constructor emitting evaluation warnings.
        - `validOption args`: Validates individual NixOS option declarations.
        - `validOptions inst`: Validates all options in a contract or submodule tree.
        - `validFunction args`: Validates RFC 145 function docstrings and parameter drift.
        - `validDocstring args`: Validates symbol docstring summaries and signatures.
        - `validSymbols inst`: Validates all symbols in a library instance.
        - `validMeta inst`: Validates metadata descriptions on packages and shells.
        - `mkCheck predicate [message]`: Constructs a custom check from a predicate function.
        - `hasAttr attr [message]`: Validates that an attribute exists on the instance.
        - `hasAttrs attr [message]`: Validates that an attribute exists and is an attribute set.
        - `hasNonEmptyAttrs attr [message]`: Validates that an attribute is a non-empty attribute set.
        - `hasString attr [message]`: Validates that an attribute is a non-empty string.
        - `hasFunction attr [message]`: Validates that an attribute is a function.
        - `any checkList [message]`: Validates that at least one check passes.
        - `all checkList [message]`: Validates that all checks pass.
      '';
      value = check;
    };
  };
}
