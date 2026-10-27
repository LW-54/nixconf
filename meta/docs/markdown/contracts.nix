{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.graph;
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
    contractMermaid = graphLib.renderMermaid {
      graph = contractNeighborhood;
      layout = "LR";
      linkFn = shared.makeDocLinkFn {relPrefix = "..";};
    };

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

    ${shared.renderOptTable {options = opts;}}

    ## Outputs

    ### Custom Submodule Types

    ${shared.renderTypeTable {
      inherit types;
      cName = name;
    }}

    ### Library Helpers

    ${shared.renderLibTable {
      inherit libExports;
      ns = name;
      desc = "Contract option constructor / binding helper";
    }}${
      if packages != []
      then ''


        ### Executable Packages

        ${shared.renderPkgTable {inherit packages;}}''
      else ""
    }${
      if devShells != []
      then ''


        ### Development Shells

        ${shared.renderShellTable {inherit devShells;}}''
      else ""
    }

    ## Implementations

    Providers satisfying the `${name}` contract capability:

    ${
      if implementers != []
      then
        graphLib.renderTable {
          headers = ["Implementation" "Description" "Docs"];
          columns = [
            (i: "[`${i.name}`](../implementations/${i.name}.md)")
            (i: i.description or "")
            (i: "[More →](../implementations/${i.name}.md)")
          ];
          rows = implementers;
        }
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
    contractsCatalog = graphLib.renderTable {
      headers = ["Contract" "Description" "Implementations" "Docs"];
      columns = [
        (c: "[`${c.name}`](contracts/${c.name}.md)")
        (c: c.properties.description or "")
        (
          c: let
            implList = map (i: "[`${i.name}`](implementations/${i.name}.md)") (c.properties.implementers or []);
          in
            if implList != []
            then lib.concatStringsSep ", " implList
            else "*none*"
        )
        (c: "[More →](contracts/${c.name}.md)")
      ];
      rows = contracts;
    };
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

    ${contractsCatalog}
  '';
in {
  internal.docs.markdown.contracts = {
    inherit
      renderContractDoc
      renderContractsIndex
      ;
  };
}
