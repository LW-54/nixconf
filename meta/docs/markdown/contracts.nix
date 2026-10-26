{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.graph;
  mermaidLib = config.flake.lib.docsMermaid;
  shared = config.internal.docs.markdown.shared;

  renderContractDoc = {
    graph,
    contractNode,
  }: let
    name = contractNode.name;
    props = contractNode.properties;
    desc = props.description or "";
    implementers = props.implementers or [];
    libExports = props.lib or [];
    packages = props.packages or [];
    devShells = props.devShells or [];

    # Related nodes from graph
    opts = builtins.filter (n: (n.kind == "opt" || n.kind == "option") && (n.properties.contract or "") == name) (builtins.attrValues graph.nodes);
    types = builtins.filter (n: n.kind == "type" && (n.properties.contract or "") == name) (builtins.attrValues graph.nodes);

    contractNeighborhood = graphLib.getNeighborhood {
      inherit graph;
      nodeId = contractNode.id;
      depth = 2;
    };
    contractMermaid = mermaidLib.renderMermaid contractNeighborhood;

    renderImplRow = i: "| [`${i.name}`](../implementations/${i.name}.md) | ${i.description} | [More →](../implementations/${i.name}.md) |";

    # Consumers partitioned by Hosts, Implementations, Features
    consumerEdges = builtins.filter (e: e.target == contractNode.id && (e.kind == "CONSUMES" || e.relation == "CONSUMES")) graph.edges;
    hostConsumerEdges = builtins.filter (e: lib.hasInfix "host:" e.source) consumerEdges;
    implConsumerEdges = builtins.filter (e: lib.hasInfix "impl" e.source) consumerEdges;
    featureConsumerEdges = builtins.filter (e: lib.hasInfix "feature:" e.source) consumerEdges;

    renderConsumer = e: let
      srcNode = graph.nodes.${e.source} or null;
      srcName =
        if srcNode != null
        then srcNode.name
        else e.source;
      srcKind =
        if lib.hasInfix "host:" e.source
        then "hosts"
        else if lib.hasInfix "impl" e.source
        then "implementations"
        else "features";
      optsWritten =
        e.properties.optionsWritten or (
          if e ? qualifier && e.qualifier != null
          then [e.qualifier]
          else []
        );
      optsStr =
        if optsWritten != []
        then lib.concatStringsSep ", " (map (o: "`${o}`") optsWritten)
        else "*general contract configuration*";
      codeSnippet =
        if e.properties ? codeSnippet && e.properties.codeSnippet != ""
        then e.properties.codeSnippet
        else let
          snippet = lib.concatMapStringsSep "\n" (o: "  ${o} = ...;") optsWritten;
        in ''
          config = {
          ${snippet}
          };
        '';
    in ''
      <details>
      <summary><code><a href="../${srcKind}/${srcName}.md">${srcName}</a></code></summary>

      Configures options: ${optsStr}

      ```nix
      ${codeSnippet}
      ```

      </details>
    '';
  in ''
    # Contract: `${name}`

    ${desc}

    [← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

    ## Metadata

    - **Contract Name**: `${name}`
    - **Description**: ${desc}
    - **Definition File**: [`${props.file}`](../../${props.file})

    ## Architecture Diagram

    ${contractMermaid}

    ## Option Schema Definitions

    ${
      if opts != []
      then ''
        | Option Path | Type | Default | Example | Description |
        | :--- | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" shared.renderOptRow opts}
      ''
      else "*No direct options declared.*"
    }

    ## Outputs

    ### Custom Submodule Types

    ${
      if types != []
      then ''
        | Type Name | Description | Docs |
        | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (t:
          shared.renderTypeRow {
            inherit t;
            cName = name;
          })
        types}
      ''
      else "*No custom types declared directly on this contract.*"
    }

    ### Library Helpers

    ${
      if libExports != []
      then ''
        | Symbol | Description | Docs |
        | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (sym:
          shared.renderLibRow {
            inherit sym;
            ns = name;
            desc = "Contract option constructor / binding helper";
          })
        libExports}
      ''
      else "*No library helpers exported.*"
    }${
      if packages != []
      then ''


        ### Executable Packages

        | Package Attribute | Command | Description | Docs |
        | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (p: shared.renderPkgRow {inherit p;}) packages}''
      else ""
    }${
      if devShells != []
      then ''


        ### Development Shells

        | Shell Attribute | Command | Description | Docs |
        | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (s: shared.renderShellRow {inherit s;}) devShells}''
      else ""
    }

    ## Implementations

    Providers satisfying the `${name}` contract capability:

    | Implementation | Description | Docs |
    | :--- | :--- | :--- |
    ${
      if implementers != []
      then lib.concatMapStringsSep "\n" renderImplRow implementers
      else "*No active implementations satisfying this contract.*"
    }

    ## Contract Consumers

    Modules configuring options under the `${name}` contract capability:

    ### Hosts

    ${
      if hostConsumerEdges != []
      then lib.concatMapStringsSep "\n\n" renderConsumer hostConsumerEdges
      else "*No hosts configure this contract directly.*"
    }

    ### Implementations

    ${
      if implConsumerEdges != []
      then lib.concatMapStringsSep "\n\n" renderConsumer implConsumerEdges
      else "*No implementations configure this contract.*"
    }

    ### Features

    ${
      if featureConsumerEdges != []
      then lib.concatMapStringsSep "\n\n" renderConsumer featureConsumerEdges
      else "*No features configure this contract.*"
    }
  '';

  renderContractsIndex = {graph}: let
    contracts = builtins.filter (n: n.kind == "contract") (builtins.attrValues graph.nodes);
    contractRow = c: let
      desc = c.properties.description or "";
      implList = map (i: "[`${i.name}`](implementations/${i.name}.md)") (c.properties.implementers or []);
      implStr =
        if implList != []
        then lib.concatStringsSep ", " implList
        else "*none*";
    in "| [`${c.name}`](contracts/${c.name}.md) | ${desc} | ${implStr} | [More →](contracts/${c.name}.md) |";
  in ''
    # Contracts Documentation

    Pure abstract interfaces declared via `options.contract` in [`primitives/contract/default.nix`](../primitives/contract/default.nix).

    [← Back to Main README](../README.md)

    ## Primitive Specification

    ${options.contract.description}

    ### Option Schema (`options.contract.<name>`)

    - `description` (string, required): Formal description of the contract.
    - `options` (raw, required): NixOS option declarations defined for this contract.
    - `types` (attrsOf raw, default: `{}`): Custom submodule types exposed on `self.lib.<name>.types`.
    - `mkOption` (raw, default: `null`): Submodule option constructor for features.
    - `mkConfig` (raw, default: `null`): Configuration binding helper.
    - `packages` (raw, default: `{}`): Contract packages or generator function.
    - `devShells` (raw, default: `{}`): Contract development shells or generator function.
    - `lib` (attrsOf raw, default: `{}`): Extra library helpers and symbols exported on `flake.lib.<name>`.

    ### Declaration Example (`contract.<name>`)

    ```nix
    contract.example = {
      description = "Abstract contract interface.";
      options = {
        enable = lib.mkEnableOption "example contract";
      };
    };
    ```

    ## Contracts Catalog

    | Contract | Description | Implementations | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" contractRow contracts}
  '';
in {
  internal.docs.markdown.contracts = {
    inherit
      renderContractDoc
      renderContractsIndex
      ;
  };
}
