{
  lib,
  config,
  ...
}: let
  core = config.internal.docs.spec.core;

  /**
  Validates a NixOS option description, types, and defaults against the style specification.

  # Inputs

  `file`
  : File declaring the option (defaults to "unknown").

  `isContract`
  : Whether the option belongs to a pure capability contract (defaults to false).

  `line`
  : Line number declaring the option (defaults to 1).

  `option`
  : Evaluated option attribute set containing description, type, and default.

  `path`
  : Dot-separated option attribute path.

  # Type
  ```
  validateOption :: AttrSet -> [AttrSet]
  ```

  # Examples
  ```nix
  validateOption {
    path = "reverse-proxy.domain";
    option = { description = "The root domain name."; };
    isContract = true;
    file = "modules/contracts/reverse-proxy.nix";
    line = 20;
  }
  ```
  */
  validateOption = {
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
      (core.recordTodo {
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
        (core.recordTodo {
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
              (core.recordTodo {
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
  Extracts cross-references to other contract options from backticked tokens.

  # Inputs

  `description`
  : Option description text to scan for backticked references.

  `path`
  : Dot-separated option attribute path being evaluated.

  `validContractNames`
  : List of known pure capability contract names.

  `validOptionPaths`
  : List of known valid contract option paths.

  # Type
  ```
  findReferences :: AttrSet -> [String]
  ```

  # Examples
  ```nix
  findReferences {
    path = "vaultwarden.domain";
    description = "Configures `reverse-proxy.domain` bindings.";
    validContractNames = ["reverse-proxy"];
    validOptionPaths = ["reverse-proxy.domain"];
  }
  ```
  */
  findReferences = {
    path,
    description,
    validContractNames,
    validOptionPaths,
  }: let
    words = lib.splitString " " (lib.concatStringsSep " " (lib.splitString "\n" description));
    findBacktickTokens = s: let
      m = builtins.match ".*`([a-zA-Z0-9_-]+\\.[a-zA-Z0-9_.-]+)`.*" s;
    in
      if m != null
      then builtins.head m
      else null;
    rawTokens = lib.filter (x: x != null) (map findBacktickTokens words);
    isContractRef = tok: let
      parts = lib.splitString "." tok;
      contract = builtins.head parts;
    in
      builtins.elem contract validContractNames;
    contractRefs = lib.unique (lib.filter isContractRef rawTokens);
  in
    contractRefs;
in {
  internal.docs.spec.options = {
    inherit
      validateOption
      findReferences
      ;
  };
}
