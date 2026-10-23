{
  lib,
  config,
  options,
  ...
}: let
  renderModulesIndex = {graph}: let
    modules = builtins.filter (n: n.kind == "module") (builtins.attrValues graph.nodes);
    modRow = m: let
      desc = m.properties.description or "";
    in "| [`${m.name}`](modules/${m.name}.md) | ${desc} | [More →](modules/${m.name}.md) |";
  in ''
    # Modules Documentation

    Complete directory of all NixOS modules exported on `flake.nixosModules`.

    [← Back to Main README](../README.md)

    ## Exported Modules Catalog

    | Module | Description | Docs |
    | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" modRow modules}
  '';

  renderModuleDoc = {
    graph,
    moduleNode,
  }: let
    name = moduleNode.name;
    props = moduleNode.properties;
    desc = props.description or "";
    importingHosts = props.importingHosts or [];
    hostConfigs = props.hostConfigurations or {};
    options = props.options or [];

    renderHostConfig = h: let
      snippet = hostConfigs.${h} or "";
    in ''
      <details>
      <summary><code><a href="../hosts/${h}.md">${h}</a></code></summary>

      ```nix
      ${snippet}
      ```

      </details>
    '';

    renderOpt = o: "| `options.${o.path}` | `${o.type}` | ${builtins.replaceStrings ["\n" "|"] [" " "\\|"] (lib.trim o.description)} |";
  in ''
    # Module: `${name}`

    ${desc}

    [← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

    ## Metadata

    - **Module Attribute**: `flake.nixosModules.${name}`
    - **Description**: ${desc}

    ## Importing Hosts

    Hosts that import this module into their system configurations:

    ${
      if importingHosts != []
      then lib.concatMapStringsSep "\n\n" renderHostConfig importingHosts
      else "*Not currently imported by any host.*"
    }

    ## Declared Options

    NixOS options declared directly by this module:

    ${
      if options != []
      then ''
        | Option Path | Type | Description |
        | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" renderOpt options}
      ''
      else "*No direct top-level options declared.*"
    }
  '';

  renderPackagesIndex = {graph}: let
    pkgs = builtins.filter (n: n.kind == "pkg") (builtins.attrValues graph.nodes);
    pkgBlock = p: ''
      <a id="${p.name}"></a>
      ### `${p.name}`

      ${p.properties.description}

      ```bash
      ${p.properties.runCommand}
      ```
    '';
  in ''
    # Packages Documentation

    Master registry of executable packages exported on `flake.packages`.

    [← Back to Main README](../README.md)

    ## Exported Packages Catalog

    ${lib.concatMapStringsSep "\n\n" pkgBlock pkgs}
  '';

  renderDevshellsIndex = {graph}: let
    shells = builtins.filter (n: n.kind == "shell") (builtins.attrValues graph.nodes);
    shellBlock = s: ''
      <a id="${s.name}"></a>
      ### `${s.name}`

      ${s.properties.description}

      ```bash
      ${s.properties.developCommand}
      ```
    '';
  in ''
    # DevShells Documentation

    Master registry of interactive environments exported on `flake.devShells`.

    [← Back to Main README](../README.md)

    ## Exported Development Shells

    ${lib.concatMapStringsSep "\n\n" shellBlock shells}
  '';

  renderLibIndex = {
    graph,
    sublibNames,
    sublibGroups ? {},
  }: let
    sublibRow = s: let
      libNode = graph.nodes."lib:${s}" or null;
      desc =
        if libNode != null && libNode.properties ? description
        then libNode.properties.description
        else "Library helpers and symbols for ${s}.";
      fns = sublibGroups.${s} or [];
      fnNames = map (f: f.name) fns;
      shortNames = map (n: let
        p = lib.splitString "." n;
      in
        if builtins.length p > 1
        then builtins.elemAt p 1
        else n)
      fnNames;
      fnList =
        if shortNames != []
        then lib.concatStringsSep ", " (map (f: "[`${f}`](lib/${s}.md#${f})") shortNames)
        else "*namespace helpers*";
    in "| [`flake.lib.${s}`](lib/${s}.md) | ${desc} | ${fnList} | [More →](lib/${s}.md) |";
  in ''
    # Library Documentation

    Pure reusable helper functions, data types, calculations, and presets declared via `options.lib` in [`modules/meta/primitives/lib.nix`](../modules/meta/primitives/lib.nix).

    [← Back to Main README](../README.md)

    ## Primitive Specification

    ${options.lib.description}

    ### Option Schema (`options.lib.<name>`)

    - `description` (string, required): Formal description of this library namespace and its capabilities.
    - `symbols` (attrsOf raw, default: `{}`): Exported library functions and values under `flake.lib.<name>.<symbol>`. Can be declared either as raw values or as attribute sets containing an RFC 145 docstring (`{ docstring = "..."; value = ...; }`).

    ### Declaration Example (`lib.<name>`)

    ```nix
    lib.math = {
      description = "Mathematical utility functions and numeric helpers.";
      symbols = {
        add = {
          docstring = '''
            Adds two integers.

            # Inputs

            - `a`: First integer
            - `b`: Second integer

            # Type

            ```
            Int -> Int -> Int
            ```
          ''';
          value = a: b: a + b;
        };
      };
    };
    ```

    ## Library Namespaces Catalog

    | Library Namespace | Description | Exported Functions / Symbols | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" sublibRow sublibNames}
  '';

  renderSublibDoc = {
    graph ? null,
    sublib,
    functions,
  }: let
    libNode =
      if graph != null
      then graph.nodes."lib:${sublib}" or null
      else null;
    desc =
      if libNode != null && libNode.properties ? description
      then libNode.properties.description
      else "Exported library functions and symbols for the `${sublib}` namespace.";

    firstFn =
      if functions != []
      then let
        f0 = builtins.head functions;
        p = lib.splitString "." f0.name;
      in
        if builtins.length p > 1
        then lib.last p
        else f0.name
      else "exampleSymbol";

    renderFunction = f: let
      props = f.properties;
      summary = props.summary or "";
      body = props.body or "";
      typeSig = props.typeSignature or "";
      examples = props.examples or "";
      inputs = props.inputs or [];
      p = lib.splitString "." f.name;
      shortName =
        if builtins.length p > 1
        then lib.last p
        else f.name;

      renderInput = inp: "- `${inp.name}`: ${inp.description}";
    in ''
      <a id="${shortName}"></a>
      ### `${shortName}`

      ${summary}

      ${lib.optionalString (body != "") body}

      ${
        if inputs != []
        then ''
          #### Inputs

          ${lib.concatMapStringsSep "\n" renderInput inputs}
        ''
        else ""
      }

      ${
        if typeSig != ""
        then ''
          #### Type

          ```
          ${typeSig}
          ```
        ''
        else ""
      }

      ${
        if examples != ""
        then ''
          #### Examples

          ```nix
          ${examples}
          ```
        ''
        else ""
      }
    '';
  in ''
    # Library Namespace: `flake.lib.${sublib}`

    ${desc}

    [← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

    ## Usage

    This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

    ### Internal Usage

    Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.${sublib}`:

    ```nix
    { self, lib, pkgs, ... }: {
      # Access helpers directly from self.lib.${sublib}
      example = self.lib.${sublib}.${firstFn};
    }
    ```

    ### External Usage

    When consuming this flake as an input in another `flake.nix`:

    ```nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixconf.url = "github:LW-54/nixconf";
      };

      outputs = { self, nixpkgs, nixconf, ... }: {
        # Access exported helpers from inputs.nixconf.lib.${sublib}
        example = nixconf.lib.${sublib}.${firstFn};
      };
    }
    ```

    ## Exported Symbols

    ${lib.concatMapStringsSep "\n\n" renderFunction functions}
  '';
in {
  internal.docs.markdown.outputs = {
    inherit
      renderModulesIndex
      renderModuleDoc
      renderPackagesIndex
      renderDevshellsIndex
      renderLibIndex
      renderSublibDoc
      ;
  };
}
