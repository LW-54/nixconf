{
  lib,
  config,
  ...
}: let
  graphLib = config.flake.lib.graph;
  hostsMod = config.internal.docs.markdown.hosts;
  contractsMod = config.internal.docs.markdown.contracts;
  implsMod = config.internal.docs.markdown.implementations;
  featuresMod = config.internal.docs.markdown.features;
  outputsMod = config.internal.docs.markdown.outputs;
  rootMod = config.internal.docs.markdown.root;

  /**
  Generates all markdown documentation files for hosts, contracts, implementations, features, modules, and lib symbols.

  # Inputs

  `cpg`
  : Evaluated Semantic Code Property Graph (optional).

  `graph`
  : Evaluated documentation graph (optional).

  `system`
  : Target host platform system (default: "x86_64-linux").

  # Type
  ```
  generateAll :: AttrSet -> AttrSet
  ```
  */
  generateAll = {
    system ? "x86_64-linux",
    cpg ? graphLib.buildCPG {inherit system;},
    graph ? graphLib.buildGraph {inherit system;},
  }: let
    hosts = builtins.filter (n: n.kind == "host") (builtins.attrValues graph.nodes);
    contracts = builtins.filter (n: n.kind == "contract") (builtins.attrValues graph.nodes);
    impls = builtins.filter (n: n.kind == "impl" || n.kind == "implementation") (builtins.attrValues graph.nodes);
    features = builtins.filter (n: n.kind == "feature") (builtins.attrValues graph.nodes);
    modules = builtins.filter (n: n.kind == "module") (builtins.attrValues graph.nodes);
    allSymbols = builtins.filter (n: n.kind == "fn" || n.kind == "function" || n.kind == "symbol") (builtins.attrValues graph.nodes);

    # Partition symbols by namespace
    getNamespace = sym: let
      parts = lib.splitString "." sym.name;
    in
      if builtins.length parts > 1
      then builtins.head parts
      else "core";

    sublibGroups = lib.groupBy getNamespace allSymbols;
    sublibNames = builtins.attrNames sublibGroups;

    # Per-host files
    hostFiles = lib.listToAttrs (map (h: {
        name = "docs/hosts/${h.name}.md";
        value = hostsMod.renderHostDoc {
          inherit graph;
          hostNode = h;
        };
      })
      hosts);

    # Per-contract files
    contractFiles = lib.listToAttrs (map (c: {
        name = "docs/contracts/${c.name}.md";
        value = contractsMod.renderContractDoc {
          inherit graph;
          contractNode = c;
        };
      })
      contracts);

    # Per-implementation files
    implFiles = lib.listToAttrs (map (i: {
        name = "docs/implementations/${i.name}.md";
        value = implsMod.renderImplDoc {
          inherit graph;
          implNode = i;
        };
      })
      impls);

    # Per-feature files
    featureFiles = lib.listToAttrs (map (f: {
        name = "docs/features/${f.name}.md";
        value = featuresMod.renderFeatureDoc {
          inherit graph;
          featureNode = f;
        };
      })
      features);

    # Per-module files
    moduleFiles = lib.listToAttrs (map (m: {
        name = "docs/modules/${m.name}.md";
        value = outputsMod.renderModuleDoc {
          inherit graph;
          moduleNode = m;
        };
      })
      modules);

    # Per-sublib files
    sublibFiles = lib.listToAttrs (map (ns: {
        name = "docs/lib/${ns}.md";
        value = outputsMod.renderSublibDoc {
          inherit graph;
          sublib = ns;
          functions = sublibGroups.${ns};
        };
      })
      sublibNames);

    # Top-level index files
    indexFiles = {
      "README.md" = rootMod.renderReadme {inherit graph;};
      "docs/GRAPH.md" = rootMod.renderGraphDoc {inherit graph cpg;};
      "docs/DOCS.md" = rootMod.renderDocsGuide {inherit graph;};
      "docs/PRIMITIVES.md" = rootMod.renderPrimitivesIndex {inherit graph;};
      "docs/HOSTS.md" = hostsMod.renderHostsIndex {inherit graph;};
      "docs/CONTRACTS.md" = contractsMod.renderContractsIndex {inherit graph;};
      "docs/IMPLEMENTATIONS.md" = implsMod.renderImplementationsIndex {inherit graph;};
      "docs/FEATURES.md" = featuresMod.renderFeaturesIndex {inherit graph;};
      "docs/MODULES.md" = outputsMod.renderModulesIndex {inherit graph;};
      "docs/PACKAGES.md" = outputsMod.renderPackagesIndex {inherit graph;};
      "docs/DEVSHELLS.md" = outputsMod.renderDevshellsIndex {inherit graph;};
      "docs/LIB.md" = outputsMod.renderLibIndex {
        inherit graph sublibNames sublibGroups;
      };
    };
  in
    indexFiles
    // hostFiles
    // contractFiles
    // implFiles
    // featureFiles
    // moduleFiles
    // sublibFiles;
  generateAllSym = {
    docstring = ''
      Generates all markdown documentation files for hosts, contracts, implementations, features, modules, and lib symbols.

      # Inputs

      `cpg`
      : Evaluated Semantic Code Property Graph (optional).

      `graph`
      : Evaluated documentation graph (optional).

      `system`
      : Target host platform system (default: "x86_64-linux").

      # Type
      ```
      generateAll :: AttrSet -> AttrSet
      ```
    '';
    value = generateAll;
  };

  renderReadmeSym = {
    docstring = ''
      Renders the repository root README.md documentation file.

      # Inputs

      `graph`
      : Evaluated documentation graph.

      # Type
      ```
      renderReadme :: AttrSet -> String
      ```
    '';
    value = rootMod.renderReadme;
  };
in {
  lib.docsMarkdown = {
    description = "Markdown documentation rendering engine for Nixconf architecture.";
    symbols = {
      generateAll = generateAllSym;
      renderReadme = renderReadmeSym;
    };
  };
}
