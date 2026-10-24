{lib, ...}: let
  /**
  Normalizes a message string into a single trimmed line.

  # Inputs

  `msg`
  : Raw multiline or unformatted string message.

  # Type
  ```
  cleanMsg :: String -> String
  ```
  */
  cleanMsg = msg: lib.concatStringsSep " " (lib.filter (s: s != "") (lib.splitString "\n" msg));

  /**
  Records a documentation technical debt diagnostic and emits an evaluation warning.

  # Inputs

  `file`
  : File path where technical debt was detected.

  `id`
  : Canonical entity identifier generating the diagnostic.

  `kind`
  : Diagnostic classification tag (e.g. option, docstring, contract-example).

  `line`
  : Line number where technical debt was detected.

  `message`
  : Diagnostic summary explaining the non-conformance.

  # Type
  ```
  recordTodo :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  recordTodo {
    id = "fn:example";
    kind = "docstring";
    file = "modules/example.nix";
    line = 42;
    message = "Missing RFC 145 docstring.";
  }
  ```
  */
  recordTodo = {
    id,
    kind,
    file,
    line,
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

  # Canonical node kinds recognized by the documentation graph
  nodeKinds = [
    "host"
    "contract"
    "impl"
    "feature"
    "module"
    "pkg"
    "shell"
    "fn"
    "type"
    "opt"
  ];

  # Canonical directed edge kinds recognized by the documentation graph
  edgeKinds = [
    "IMPORTS"
    "IMPLEMENTS"
    "CONSUMES"
    "DECLARES"
  ];
in {
  internal.docs.spec.core = {
    inherit
      cleanMsg
      recordTodo
      nodeKinds
      edgeKinds
      ;
  };
}
