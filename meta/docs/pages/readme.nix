# Root repository README.md declaration.
{
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;
  graphLib = config.flake.lib.graph;
  types = config.internal.graph.core.types;

  kinds = lib.filterAttrs (name: _: name != "primitive") config.primitive;

  topologyGraph = graphLib.filterGraph {
    nodeFilter = n: n.stratum == types.strata.onto && kinds ? ${n.kind};
    edgeFilter = e: builtins.elem (lib.toLower (e.relation or "")) [types.relations.IMPORTS types.relations.IMPLEMENTS "consumes"];
  };
in {
  docs.pages.readme = {
    path = "README.md";
    sections = {
      header = {
        order = 10;
        content = ctx: ''
          <h1 align="center">${config.docs.project.name}</h1>

          <p align="center">${config.docs.project.tagline}</p>
        '';
      };

      overview = {
        order = 20;
        content = ctx: ''
          ## Architecture Overview

          The repository architecture is governed by five first-class, symmetrical primitives:

          - [**Hosts (`host`)**](${ctx.link ctx.pages.hosts.path}): ${config.primitive.host.description}
          - [**Contracts (`contract`)**](${ctx.link ctx.pages.contracts.path}): ${config.primitive.contract.description}
          - [**Implementations (`implementation`)**](${ctx.link ctx.pages.implementations.path}): ${config.primitive.implementation.description}
          - [**Features (`feature`)**](${ctx.link ctx.pages.features.path}): ${config.primitive.feature.description}
          - [**Libraries (`lib`)**](${ctx.link ctx.pages.lib.path}): ${config.primitive.lib.description}

          ```mermaid
          flowchart TD
              Host["host<br/><i>Target Machine</i>"]
              Contract{{"contract<br/><i>Abstract Interface</i>"}}
              Implementation["implementation<br/><i>Capability Provider</i>"]
              Feature["feature<br/><i>System Service</i>"]
              Library(["lib<br/><i>Pure Helpers</i>"])

              Host -->|"consumes"| Contract
              Implementation -.->|"implements"| Contract
              Implementation -->|"consumes"| Contract
              Feature -->|"consumes"| Contract
              Contract -.->|"provides"| Library
              Implementation -.->|"provides"| Library
              Feature -.->|"provides"| Library

              click Host "${ctx.link ctx.pages.hosts.path}" "Hosts Documentation"
              click Contract "${ctx.link ctx.pages.contracts.path}" "Contracts Documentation"
              click Implementation "${ctx.link ctx.pages.implementations.path}" "Implementations Documentation"
              click Feature "${ctx.link ctx.pages.features.path}" "Features Documentation"
              click Library "${ctx.link ctx.pages.lib.path}" "Library Documentation"

              classDef default fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
              classDef contract fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
              classDef impl fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
              classDef feat fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
              classDef lib fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;

              class Host default;
              class Contract contract;
              class Implementation impl;
              class Feature feat;
              class Library lib;
          ```

          ${md.details "Full Architecture Diagram (Click to expand)" (ctx.mermaid {
            graph = topologyGraph ctx.graph;
            layout = "TD";
            clusterBy = "kind";
          })}
        '';
      };

      stack = {
        order = 25;
        content = ctx: ''
          ## Core Nix Stack

          The repository infrastructure is structured around four foundational components:

          - **`tack`**: Declarative input pinning and lockfile orchestration tool (`.tack/pins.toml` and `.tack/pins.lock.json`), decoupling external flake inputs from repository code while enabling deterministic updates:
            ```bash
            # Update all pinned inputs
            tack update

            # Update a specific pinned input
            tack update nixpkgs

            # Add a new input pin
            tack add github:owner/repo

            # Remove an input pin
            tack rm repo
            ```

          - **`flake.nix`**: Minimal transparent entrypoint evaluating flake inputs via `import ./.tack`.

          - **`flake-parts`**: Hercules CI modular framework (`mkFlake`) partitioning options, per-system packages, devshells, and automated checks.

          - **`import-tree`**: Automated dendritic module discovery that recursively scans and imports all `.nix` files under `primitives/`, `meta/`, and `modules/` as top-level flake-parts modules.
        '';
      };

      catalog = {
        order = 30;
        content = ctx: let
          hosts = config.host or {};
          contracts = config.contract or {};
          implementations = config.implementation or {};
          features = config.feature or {};
          libraries = config.lib or {};

          hostsTable = md.table {
            headers = ["Host" "Description" "System" "Docs"];
            columns = [
              (h: ctx.instanceLink "host" h)
              (h: md.oneLine (hosts.${h}.description or ""))
              (h: "`${hosts.${h}.system or "x86_64-linux"}`")
              (h: ctx.moreLink "host" h)
            ];
            rows = builtins.attrNames hosts;
          };

          contractsTable = md.table {
            headers = ["Contract" "Description" "Implementations" "Docs"];
            columns = [
              (c: ctx.instanceLink "contract" c)
              (c: md.oneLine (contracts.${c}.description or ""))
              (c: let
                impls = builtins.attrNames (lib.filterAttrs (_: i: (i.contract or "") == c) implementations);
              in
                if impls == []
                then "—"
                else lib.concatMapStringsSep ", " (i: ctx.instanceLink "implementation" i) impls)
              (c: ctx.moreLink "contract" c)
            ];
            rows = builtins.attrNames contracts;
          };

          implementationsTable = md.table {
            headers = ["Implementation" "Description" "Contract" "Docs"];
            columns = [
              (i: ctx.instanceLink "implementation" i)
              (i: md.oneLine (implementations.${i}.description or ""))
              (i: ctx.instanceLink "contract" implementations.${i}.contract)
              (i: ctx.moreLink "implementation" i)
            ];
            rows = builtins.attrNames implementations;
          };

          featuresTable = md.table {
            headers = ["Feature" "Description" "Docs"];
            columns = [
              (f: ctx.instanceLink "feature" f)
              (f: md.oneLine (features.${f}.description or ""))
              (f: ctx.moreLink "feature" f)
            ];
            rows = builtins.attrNames features;
          };

          librariesTable = md.table {
            headers = ["Library Namespace" "Description" "Docs"];
            columns = [
              (l: ctx.instanceLink "lib" l)
              (l: md.oneLine (libraries.${l}.description or ""))
              (l: ctx.moreLink "lib" l)
            ];
            rows = builtins.attrNames libraries;
          };

          packagesBlocks = md.blocks (map (p: ''
            #### [`${p.name}`](${ctx.link ctx.pages.packages.path}#${p.name})
            ${md.oneLine (p.properties.description or "")}

            ${md.code "bash" "nix run .#${p.name}"}

            ${md.code "bash" "nix run ${config.docs.project.flakeRef}#${p.name}"}
          '') (ctx.nodes "package"));

          devshellsBlocks = md.blocks (map (s: ''
            #### [`${s.name}`](${ctx.link ctx.pages.devshells.path}#${s.name})
            ${md.oneLine (s.properties.description or "")}

            ${md.code "bash" "nix develop .#${s.name}"}

            ${md.code "bash" "nix develop ${config.docs.project.flakeRef}#${s.name}"}
          '') (ctx.nodes "devShell"));

          hostDeploymentGuide = ''
            ### Host Installation & Deployment

            Target hosts in this configuration are partitioned declaratively with Disko, persisted through Impermanence, and configured via Nix flakes. Host-specific copy-paste commands are documented on each host's deep-dive page:
            ${ctx.md.bullets (map (h: "${ctx.instanceLink "host" h}: ${ctx.md.oneLine (hosts.${h}.description or "")}") (builtins.attrNames hosts))}

            #### Prerequisites & Requirements

            Before installing a host, verify:
            1. **Architecture & Firmware**: 64-bit x86 target system booted in UEFI mode with network connectivity.
            2. **Disko Partitioning**: The disk definition in the host configuration matches the physical disk device path (e.g. `/dev/sda` or `/dev/nvme0n1`).
            3. **SOPS Age Private Key**: The host's age decryption key must be placed at `/persist/sops-nix/key.txt` with permissions `0400` so secrets decrypt on first boot.

            ${config.internal.docs.installGuide {}}
          '';
        in ''
          ## Configuration Catalog

          ${md.details "<h3>Primitives</h3>" ''
            Foundational structural primitives governing repository architecture, typing, and outputs. Declared in `primitives/`. See ${ctx.pageLink "primitives" "Primitives Documentation"}.

            ${md.table {
              headers = ["Primitive" "Description" "Instances" "Docs"];
              columns = [
                (k:
                  ctx.pageLink (
                    if k == "lib"
                    then "lib"
                    else "${k}s"
                  ) "`${k}`")
                (k: md.oneLine kinds.${k}.schema.doc)
                (k: toString (builtins.length (builtins.attrNames (config.${k} or {}))))
                (k:
                  ctx.morePageLink (
                    if k == "lib"
                    then "lib"
                    else "${k}s"
                  ))
              ];
              rows = builtins.attrNames kinds;
            }}
          ''}

          ${md.details "<h3>Hosts</h3>" ''
            Master registry of target hosts declared via `host.<name>`. See ${ctx.pageLink "hosts" "Hosts Documentation"}.

            ${hostsTable}

            ${hostDeploymentGuide}
          ''}

          ${md.details "<h3>Contracts</h3>" ''
            Pure contract interfaces defining shared option schemas decoupled from backends. Declared via `contract.<name>`. See ${ctx.pageLink "contracts" "Contracts Documentation"}.

            ${contractsTable}
          ''}

          ${md.details "<h3>Implementations</h3>" ''
            Concrete capability providers satisfying contract interfaces with services and packages. Declared via `implementation.<name>`. See ${ctx.pageLink "implementations" "Implementations Documentation"}.

            ${implementationsTable}
          ''}

          ${md.details "<h3>Features</h3>" ''
            Reusable system configurations and desktop services consuming contracts. Declared via `feature.<name>`. See ${ctx.pageLink "features" "Features Documentation"}.

            ${featuresTable}
          ''}

          ${md.details "<h3>Libraries</h3>" ''
            Pure reusable helper functions, data types, calculations, and presets. Declared via `lib.<name>`. See ${ctx.pageLink "lib" "Library Documentation"}.

            ${librariesTable}
          ''}

          ${md.details "<h3>Packages</h3>" ''
            Executable packages exported across target platforms on `flake.packages`. See ${ctx.pageLink "packages" "Packages Documentation"}.

            ${packagesBlocks}
          ''}

          ${md.details "<h3>DevShells</h3>" ''
            Interactive development and administrative shells exported on `flake.devShells`. See ${ctx.pageLink "devshells" "DevShells Documentation"}.

            ${devshellsBlocks}
          ''}

          ${md.details "<h3>Engine & Tooling (<code>meta/</code>)</h3>" ''
            The operational engine that inspects, documents, tests, and builds the repository infrastructure:

            - [**Semantic Code Property Graph (`meta/graph`)**](${ctx.link ctx.pages.graph.path}): Pure-Nix CPG merging syntax, dataflow, and derivations.
            - [**Documentation Generator & Audit (`meta/docs`)**](${ctx.link ctx.pages.documentation.path}): Type-checked markdown compiler maintaining 100% doc coverage ([Audit Dashboard](${ctx.link ctx.pages.coverage.path})).
            - [**Testing Harness (`meta/tests`)**](${ctx.link ctx.pages.testing.path}): Progressive 6-tier test driver (<code>eval</code>, <code>inspect</code>, <code>vm</code>, <code>install</code>, <code>interactive</code>, <code>run</code>).
            - [**CI Compiler (`meta/ci`)**](${ctx.link ctx.pages.ci.path}): Declarative GitHub Actions workflow compilation and drift checking.
            - [**Developer Environment (`meta/devenv` &amp; `meta/menu`)**]: Interactive devenv shell and fuzzy command palette (<code>menu</code>).
          ''}
        '';
      };

      documentation = {
        order = 40;
        content = ctx: ''
          ## Documentation

          Comprehensive documentation is generated directly from Nix evaluation using the pure-Nix Labeled Property Graph (LPG) pipeline:

          - **${ctx.pageLink "hosts" "Hosts Documentation"}**: Target host declarations, architecture specs, and hardware manifests.
          - **${ctx.pageLink "contracts" "Contracts Documentation"}**: Pure contract interfaces, schema options, and custom types.
          - **${ctx.pageLink "implementations" "Implementations Documentation"}**: Provider implementations satisfying contracts.
          - **${ctx.pageLink "features" "Features Documentation"}**: Modular system services, applications, and desktop environments.
          - **${ctx.pageLink "modules" "Modules Documentation"}**: Directory of all exported NixOS modules.
          - **${ctx.pageLink "packages" "Packages Documentation"}**: Executable packages exported across platforms.
          - **${ctx.pageLink "devshells" "DevShells Documentation"}**: Administrative and development shell environments.
          - **${ctx.pageLink "lib" "Library Documentation"}**: Flake library functions, type signatures, and RFC 145 docstrings.
          - **${ctx.pageLink "graph" "Semantic Code Property Graph Architecture"}**: Unified pure-Nix CPG merging AST, CFG, and PDG.
          - **${ctx.pageLink "documentation" "Documentation Pipeline Reference"}**: Pure-Nix LPG graph IR and documentation generator guide.
          - **${ctx.pageLink "testing" "Testing Architecture & Verification Tiers"}**: Multi-tier automated test harness from evaluation checks to QEMU VMs.
          - **${ctx.pageLink "ci" "Continuous Integration & Automation"}**: Declarative GitHub Actions workflows, Cachix caching, and drift verification.

          To re-generate or verify documentation integrity, use the `docs` CLI package:

          ```bash
          nix run .#docs -- --write
          nix run .#docs -- --check
          ```
        '';
      };

      license = {
        order = 90;
        content = ctx: ''
          ## License

          This project is licensed under the [MIT License](LICENSE).
        '';
      };
    };
  };
}
