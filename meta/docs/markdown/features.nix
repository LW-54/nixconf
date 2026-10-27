{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.graph;
  shared = config.internal.docs.markdown.shared;

  renderFeatureDoc = {
    graph,
    featureNode,
  }: let
    name = featureNode.name;
    props = featureNode.properties;
    desc = props.description or "";
    modules = props.modules or [];
    packages = props.packages or [];
    devShells = props.devShells or [];
    libExports = props.lib or [];
    types = props.types or [];

    featNeighborhood = graphLib.getNeighborhood {
      inherit graph;
      nodeId = featureNode.id;
      depth = 2;
    };
    featMermaid = graphLib.renderMermaid {
      graph = featNeighborhood;
      layout = "LR";
      linkFn = shared.makeDocLinkFn {relPrefix = "..";};
    };

    consumedEdges = builtins.filter (e: e.source == featureNode.id && (e.kind == "CONSUMES" || e.relation == "CONSUMES")) graph.edges;

    renderConsumedContract = e: let
      cNode = graph.nodes.${e.target} or null;
      targetName =
        if cNode != null
        then cNode.name
        else e.target;
      opts =
        e.properties.optionsWritten or (
          if e ? qualifier && e.qualifier != null
          then [e.qualifier]
          else []
        );
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
    # Feature: `${name}`

    ${desc}

    [← Back to Features Documentation](../FEATURES.md) | [← Back to Main README](../../README.md)

    ## Metadata

    - **Feature Name**: `${name}`
    - **Description**: ${desc}
    - **Definition File**: [`${props.file}`](../../${props.file})

    ## Architecture Diagram

    ${featMermaid}

    ## Outputs

    ### NixOS Modules

    ${shared.renderModTable {
      inherit modules;
      desc = "System service module exported by `${name}`";
    }}

    ### Executable Packages

    ${shared.renderPkgTable {inherit packages;}}

    ### Development Shells

    ${shared.renderShellTable {inherit devShells;}}

    ### Library Helpers

    ${shared.renderLibTable {
      inherit libExports;
      ns = name;
    }}${
      if types != []
      then ''


        ### Custom Types

        ${graphLib.renderTable {
          headers = ["Type Symbol" "Description" "Docs"];
          columns = [
            (t: "[`${t}`](../lib/${name}.md#${t})")
            (_: "Custom option type declared by `${name}`")
            (t: "[More →](../lib/${name}.md#${t})")
          ];
          rows = types;
        }}''
      else ""
    }

    ## Consumed Contracts

    Contracts configured by this feature:

    ${
      if consumedEdges != []
      then lib.concatMapStringsSep "\n\n" renderConsumedContract consumedEdges
      else "*No contracts consumed by this feature.*"
    }
  '';

  renderFeaturesIndex = {graph}: let
    features = builtins.filter (n: n.kind == "feature") (builtins.attrValues graph.nodes);
    featuresCatalog = graphLib.renderTable {
      headers = ["Feature" "Description" "Docs"];
      columns = [
        (f: "[`${f.name}`](features/${f.name}.md)")
        (f: f.properties.description or "")
        (f: "[More →](features/${f.name}.md)")
      ];
      rows = features;
    };
  in ''
    # Features Documentation

    Reusable system services and applications declared via `options.feature` in [`primitives/feature.nix`](../primitives/feature.nix).

    [← Back to Main README](../README.md)

    ## Primitive Specification

    ${options.feature.description}

    ### Option Schema (`options.feature.<name>`)

    - `description` (string, required): Formal description of the feature and service scope.
    - `modules` (attrsOf deferredModule, default: `{}`): Named NixOS configuration modules exported by this feature.
    - `packages` (raw, default: `{}`): Executable packages or package generator function exported on `flake.packages`.
    - `devShells` (raw, default: `{}`): Development environments or shell generator function exported on `flake.devShells`.
    - `lib` (attrsOf raw, default: `{}`): Helper functions exported on `flake.lib.<name>`.
    - `types` (attrsOf raw, default: `{}`): Custom option submodules and types.

    ### Declaration Example (`feature.<name>`)

    ```nix
    feature.example-feature = {
      description = "Application and service environment.";
      modules = {
        example-feature = { pkgs, ... }: { ... };
      };
    };
    ```

    ## Features Catalog

    ${featuresCatalog}
  '';
in {
  internal.docs.markdown.features = {
    inherit
      renderFeatureDoc
      renderFeaturesIndex
      ;
  };
}
