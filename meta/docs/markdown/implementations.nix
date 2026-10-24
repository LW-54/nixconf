{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.docsGraph;
  mermaidLib = config.flake.lib.docsMermaid;
  shared = config.internal.docs.markdown.shared;

  renderImplDoc = {
    graph,
    implNode,
  }: let
    name = implNode.name;
    props = implNode.properties;
    desc = props.description or "";
    cName = props.contract or "";
    cDesc = props.contractDescription or "";
    modules = props.modules or [name];
    packages = props.packages or [];
    devShells = props.devShells or [];
    libExports = props.lib or [];
    importingHosts = props.importingHosts or [];

    implNeighborhood = graphLib.getNeighborhood {
      inherit graph;
      nodeId = implNode.id;
      depth = 2;
    };
    implMermaid = mermaidLib.renderMermaid implNeighborhood;

    renderHost = h: let
      hostNode = graph.nodes."host:${h}" or null;
      hDesc =
        if hostNode != null
        then hostNode.properties.description or ""
        else "";
      hSys =
        if hostNode != null
        then hostNode.properties.system or "x86_64-linux"
        else "x86_64-linux";
    in "- [`${h}`](../hosts/${h}.md) (`${hSys}`): ${hDesc}";

    consumedEdges = builtins.filter (e: e.source == implNode.id && e.kind == "CONSUMES") graph.edges;

    renderConsumedContract = e: let
      cNode = graph.nodes.${e.target} or null;
      targetName =
        if cNode != null
        then cNode.name
        else e.target;
      opts = e.properties.optionsWritten or [];
      optsStr =
        if opts != []
        then lib.concatStringsSep ", " (map (o: "`${o}`") opts)
        else "*general capability bindings*";
      codeSnippet =
        if e.properties ? codeSnippet && e.properties.codeSnippet != ""
        then e.properties.codeSnippet
        else let
          snippet = lib.concatMapStringsSep "\n" (o: "  ${o} = ...;") opts;
        in ''
          config = {
          ${snippet}
          };
        '';
    in ''
      <details>
      <summary><code><a href="../contracts/${targetName}.md">${targetName}</a></code></summary>

      Configures options: ${optsStr}

      ```nix
      ${codeSnippet}
      ```

      </details>
    '';
  in ''
    # Implementation: `${name}`

    ${desc}

    [← Back to Implementations Documentation](../IMPLEMENTATIONS.md) | [← Back to Main README](../../README.md)

    ## Metadata

    - **Provider Name**: `${name}`
    - **Contract Satisfied**: [`${cName}`](../contracts/${cName}.md)
    - **Contract Description**: ${cDesc}
    - **Source File**: [`${props.file}`](../../${props.file})

    ## Architecture Diagram

    ${implMermaid}

    ## Outputs

    ### NixOS Modules

    | Module Attribute | Description | Docs |
    | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" (m:
      shared.renderModRow {
        inherit m;
        desc = "Provider module satisfying `${cName}` contract";
      })
    modules}

    ### Executable Packages

    ${
      if packages != []
      then ''
        | Package Attribute | Command | Description | Docs |
        | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (p: shared.renderPkgRow {inherit p;}) packages}
      ''
      else "*No executable packages exported.*"
    }

    ### Development Shells

    ${
      if devShells != []
      then ''
        | Shell Attribute | Command | Description | Docs |
        | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (s: shared.renderShellRow {inherit s;}) devShells}
      ''
      else "*No development shells exported.*"
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
          })
        libExports}
      ''
      else "*No library helpers exported.*"
    }

    ## Importing Hosts

    Hosts enabling this provider to fulfill the [`${cName}`](../contracts/${cName}.md) contract capability:

    ${
      if importingHosts != []
      then lib.concatMapStringsSep "\n" renderHost importingHosts
      else "*Not currently imported by any host.*"
    }

    ## Consumed Contracts

    Capability contracts configured by this implementation:

    ${
      if consumedEdges != []
      then lib.concatMapStringsSep "\n\n" renderConsumedContract consumedEdges
      else "*No external contracts consumed by this implementation.*"
    }
  '';

  renderImplementationsIndex = {graph}: let
    impls = builtins.filter (n: n.kind == "impl") (builtins.attrValues graph.nodes);
    implRow = i: let
      desc = i.properties.description or "";
      cName = i.properties.contract or "";
      cLink =
        if cName != ""
        then "[`${cName}`](contracts/${cName}.md)"
        else "*none*";
    in "| [`${i.name}`](implementations/${i.name}.md) | ${desc} | ${cLink} | [More →](implementations/${i.name}.md) |";
  in ''
    # Implementations Documentation

    Concrete capability providers declared via `options.implementation` in [`primitives/implementation.nix`](../primitives/implementation.nix).

    [← Back to Main README](../README.md)

    ## Primitive Specification

    ${options.implementation.description}

    ### Option Schema (`options.implementation.<name>`)

    - `contract` (string, required): Name of the capability contract this module implements.
    - `description` (string, required): Formal description of how this provider satisfies the contract.
    - `module` (deferredModule, required): NixOS module implementing the contract capability.
    - `packages` (raw, default: `{}`): Implementation package declarations or generator function.
    - `devShells` (raw, default: `{}`): Implementation development shells or generator function.
    - `lib` (attrsOf raw, default: `{}`): Exported library helpers and identity definitions on `flake.lib.<name>`.

    ### Declaration Example (`implementation.<name>`)

    ```nix
    implementation.example-provider = {
      contract = "reverse-proxy";
      description = "Reverse proxy capability provider using example backend.";
      module = { ... }: { ... };
    };
    ```

    ## Implementations Catalog

    | Implementation | Description | Contract Satisfied | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" implRow impls}
  '';
in {
  internal.docs.markdown.implementations = {
    inherit
      renderImplDoc
      renderImplementationsIndex
      ;
  };
}
