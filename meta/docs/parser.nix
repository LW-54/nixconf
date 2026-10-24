{lib, ...}: let
  /**
  Determines common leading whitespace indentation to strip from docstring lines.

  # Inputs

  `text`
  : Raw text containing indentation.

  # Type
  ```
  stripLeadingIndentation :: String -> String
  ```

  # Examples
  ```nix
  stripLeadingIndentation "  hello\n  world"
  ```
  */
  stripLeadingIndentation = text: let
    lines = lib.splitString "\n" text;
    nonEmpty = lib.filter (l: lib.trim l != "") lines;
    getIndent = l: let
      match = builtins.match "( +).*" l;
    in
      if match != null
      then builtins.stringLength (builtins.head match)
      else 0;
    minIndent =
      if nonEmpty == []
      then 0
      else
        lib.foldl' (acc: l: let
          i = getIndent l;
        in
          if i < acc
          then i
          else acc)
        9999
        nonEmpty;
    strip = l:
      if lib.trim l == ""
      then ""
      else if minIndent > 0 && builtins.stringLength l >= minIndent
      then builtins.substring minIndent (builtins.stringLength l - minIndent) l
      else l;
  in
    lib.concatStringsSep "\n" (map strip lines);

  /**
  Parses an RFC 145 docstring into structured sections (summary, body, inputs, type, examples).

  # Inputs

  `rawComment`
  : Raw multiline comment text or null.

  # Type
  ```
  parseDocstring :: NullOr String -> NullOr AttrSet
  ```

  # Examples
  ```nix
  parseDocstring "Summary sentence."
  ```
  */
  parseDocstring = rawComment:
    if rawComment == null
    then null
    else let
      comment = stripLeadingIndentation rawComment;
      trimmed = lib.trim comment;
      isTodo = lib.hasPrefix "TODO" trimmed;

      lines = lib.splitString "\n" comment;

      # Identifies header index or returns -1
      findHeaderIndex = prefixes: let
        indexed = lib.imap0 (i: l: {inherit i l;}) lines;
        matches = lib.filter ({
          i,
          l,
        }: let
          t = lib.trim l;
        in
          lib.any (p: lib.hasPrefix p t) prefixes)
        indexed;
      in
        if matches == []
        then -1
        else (builtins.head matches).i;

      inputIdx = findHeaderIndex ["# Inputs" "# Input" "### Inputs" "### Input"];
      typeIdx = findHeaderIndex ["# Type" "# Types" "### Type" "### Types"];
      exampleIdx = findHeaderIndex ["# Examples" "# Example" "### Examples" "### Example"];

      # Collect indices of sections in order
      allHeaders = lib.sort (a: b: a.idx < b.idx) (
        lib.filter (h: h.idx != -1) [
          {
            name = "inputs";
            idx = inputIdx;
          }
          {
            name = "type";
            idx = typeIdx;
          }
          {
            name = "examples";
            idx = exampleIdx;
          }
        ]
      );

      # Slice lines for preamble (before any # section)
      firstHeaderIdx =
        if allHeaders == []
        then builtins.length lines
        else (builtins.head allHeaders).idx;
      preambleLines = lib.sublist 0 firstHeaderIdx lines;
      preambleText = lib.trim (lib.concatStringsSep "\n" preambleLines);

      # Split preamble into summary (first paragraph) and body (rest)
      preambleParagraphs = lib.splitString "\n\n" preambleText;
      summary =
        if preambleParagraphs != []
        then lib.trim (builtins.head preambleParagraphs)
        else "";
      body =
        if builtins.length preambleParagraphs > 1
        then lib.trim (lib.concatStringsSep "\n\n" (builtins.tail preambleParagraphs))
        else "";

      # Helper to extract section text
      getSectionText = name: let
        matching = lib.filter (h: h.name == name) allHeaders;
      in
        if matching == []
        then ""
        else let
          current = builtins.head matching;
          after = lib.filter (h: h.idx > current.idx) allHeaders;
          endIdx =
            if after == []
            then builtins.length lines
            else (builtins.head after).idx;
          sectionLines = lib.sublist (current.idx + 1) (endIdx - current.idx - 1) lines;
        in
          lib.trim (lib.concatStringsSep "\n" sectionLines);

      rawInputsText = getSectionText "inputs";
      rawTypeText = getSectionText "type";
      rawExamplesText = getSectionText "examples";

      # Extracts code block content from a section
      extractCodeBlock = text: let
        lines = lib.splitString "\n" text;
        codeLines = lib.filter (l: !lib.hasPrefix "```" (lib.trim l)) lines;
      in
        lib.trim (lib.concatStringsSep "\n" codeLines);

      typeSignature = extractCodeBlock rawTypeText;
      examples = extractCodeBlock rawExamplesText;

      # Parse input items: lines with `arg` followed by description
      parseInputs = text: let
        inputLines = lib.splitString "\n" text;
        folder = acc: line: let
          t = lib.trim line;
          matchItem = builtins.match "^`([a-zA-Z0-9_.-]+)`[[:space:]]*(:?[[:space:]]*(.*))?$" t;
        in
          if matchItem != null
          then let
            name = builtins.elemAt matchItem 0;
            rest = builtins.elemAt matchItem 2;
          in
            acc
            ++ [
              {
                inherit name;
                description =
                  if rest != null && rest != ""
                  then lib.trim (lib.removePrefix ":" rest)
                  else "";
              }
            ]
          else if acc != [] && lib.hasPrefix ":" t
          then let
            last = lib.last acc;
            updated =
              last
              // {
                description = lib.trim (
                  if last.description == ""
                  then lib.removePrefix ":" t
                  else "${last.description} ${lib.removePrefix ":" t}"
                );
              };
          in
            (lib.init acc) ++ [updated]
          else if acc != [] && t != "" && !lib.hasPrefix "#" t
          then let
            last = lib.last acc;
            updated =
              last
              // {
                description = lib.trim "${last.description} ${t}";
              };
          in
            (lib.init acc) ++ [updated]
          else acc;
      in
        lib.foldl' folder [] inputLines;

      inputs = parseInputs rawInputsText;
    in {
      inherit
        isTodo
        summary
        body
        inputs
        typeSignature
        examples
        ;
      raw = comment;
    };
in {
  flake.lib.docsParser = {
    inherit
      stripLeadingIndentation
      parseDocstring
      ;
  };
}
