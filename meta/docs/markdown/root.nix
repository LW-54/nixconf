{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.graph;
  shared = config.internal.docs.markdown.shared;

  conceptualDiagram = ''
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
  '';

  renderReadme = {graph}: let
    hosts = builtins.filter (n: n.kind == "host") (builtins.attrValues graph.nodes);
    contracts = builtins.filter (n: n.kind == "contract") (builtins.attrValues graph.nodes);
    impls = builtins.filter (n: n.kind == "impl" || n.kind == "implementation") (builtins.attrValues graph.nodes);
    features = builtins.filter (n: n.kind == "feature") (builtins.attrValues graph.nodes);
    libs = builtins.filter (n: n.kind == "lib") (builtins.attrValues graph.nodes);
    pkgs = builtins.filter (n: n.kind == "pkg" || n.kind == "package") (builtins.attrValues graph.nodes);
    shells = builtins.filter (n: n.kind == "shell" || n.kind == "devShell") (builtins.attrValues graph.nodes);

    topologyGraph =
      graphLib.filterGraph {
        nodeFilter = n: builtins.elem n.kind ["host" "contract" "impl" "implementation" "feature" "lib"];
        edgeFilter = e: builtins.elem (lib.toUpper (e.relation or (e.kind or ""))) ["IMPORTS" "IMPLEMENTS" "CONSUMES" "EXPORTS" "PROVIDES"];
      }
      graph;

    topologyMermaid = graphLib.renderMermaid {
      graph = topologyGraph;
      layout = "TD";
      clusterBy = "kind";
      linkFn = shared.makeDocLinkFn {relPrefix = "docs";};
    };

    primitivesTable = graphLib.renderTable {
      headers = ["Primitive" "Description" "Source File"];
      columns = [
        (p: "**`${p.name}`**")
        (p: p.desc)
        (p: "[`${p.file}`](${p.file})")
      ];
      rows = [
        {
          name = "primitive";
          desc = "Meta-primitive defining how primitives are constructed and registered.";
          file = "primitives/primitive/default.nix";
        }
        {
          name = "host";
          desc = "Declarative NixOS target machines binding hardware, platform, and enabled features.";
          file = "primitives/host/default.nix";
        }
        {
          name = "contract";
          desc = "Abstract contract interfaces defining shared option schemas decoupled from backends.";
          file = "primitives/contract/default.nix";
        }
        {
          name = "implementation";
          desc = "Concrete capability providers satisfying contract interfaces with services and packages.";
          file = "primitives/implementation.nix";
        }
        {
          name = "feature";
          desc = "Reusable system configurations and desktop services consuming contracts.";
          file = "primitives/feature.nix";
        }
        {
          name = "lib";
          desc = "Pure reusable helper functions, data types, calculations, and presets.";
          file = "primitives/lib.nix";
        }
      ];
    };

    hostsTable = graphLib.renderTable {
      headers = ["Host" "Description" "System" "Docs"];
      columns = [
        (h: "[`${h.name}`](docs/hosts/${h.name}.md)")
        (h: h.properties.description or "")
        (h: "`${h.properties.system or "x86_64-linux"}`")
        (h: "[More →](docs/hosts/${h.name}.md)")
      ];
      rows = hosts;
    };

    contractsTable = graphLib.renderTable {
      headers = ["Contract" "Description" "Implementations" "Docs"];
      columns = [
        (c: "[`${c.name}`](docs/contracts/${c.name}.md)")
        (c: c.properties.description or "")
        (
          c: let
            implList = map (i: "[`${i.name}`](docs/implementations/${i.name}.md)") (c.properties.implementers or []);
          in
            if implList != []
            then lib.concatStringsSep ", " implList
            else "*none*"
        )
        (c: "[More →](docs/contracts/${c.name}.md)")
      ];
      rows = contracts;
    };

    implsTable = graphLib.renderTable {
      headers = ["Implementation" "Description" "Contract" "Docs"];
      columns = [
        (i: "[`${i.name}`](docs/implementations/${i.name}.md)")
        (i: i.properties.description or "")
        (
          i: let
            cName = i.properties.contract or "";
          in
            if cName != ""
            then "[`${cName}`](docs/contracts/${cName}.md)"
            else "*none*"
        )
        (i: "[More →](docs/implementations/${i.name}.md)")
      ];
      rows = impls;
    };

    featuresTable = graphLib.renderTable {
      headers = ["Feature" "Description" "Docs"];
      columns = [
        (f: "[`${f.name}`](docs/features/${f.name}.md)")
        (f: f.properties.description or "")
        (f: "[More →](docs/features/${f.name}.md)")
      ];
      rows = features;
    };

    libsTable = graphLib.renderTable {
      headers = ["Library Namespace" "Description" "Docs"];
      columns = [
        (l: "[`flake.lib.${l.name}`](docs/lib/${l.name}.md)")
        (l: l.properties.description or "")
        (l: "[More →](docs/lib/${l.name}.md)")
      ];
      rows = libs;
    };

    renderPkgBlock = p: ''
      #### [`${p.name}`](docs/PACKAGES.md#${p.name})
      ${p.properties.description}

      ```bash
      ${p.properties.runCommand}
      ```
    '';

    hostTestsMatrix = let
      tierCell = h: tier:
        if (config.flake.legacyPackages.${h.properties.system or "x86_64-linux"}.hostTests.${h.name} or {}) ? ${tier}
        then "✅"
        else "—";
    in
      graphLib.renderTable {
        headers = ["Host" "`eval`" "`inspect`" "`vm`" "`install`" "Checks"];
        columns = [
          (h: "[`${h.name}`](docs/hosts/${h.name}.md#testing)")
          (h: tierCell h "eval")
          (h: tierCell h "inspect")
          (h: tierCell h "vm")
          (h: tierCell h "install")
          (h: "[List →](docs/hosts/${h.name}.md#testing)")
        ];
        rows = hosts;
      };

    renderShellBlock = s: ''
      #### [`${s.name}`](docs/DEVSHELLS.md#${s.name})
      ${s.properties.description}

      ```bash
      ${s.properties.developCommand}
      ```
    '';
  in ''
    <h1 align="center">❄️ nixconf</h1>

    <p align="center">Declarative multi-host infrastructure, contracts, and modular NixOS configuration repository powered by pure-Nix evaluation.</p>

    ## Architecture Overview

    The repository architecture is governed by five first-class, symmetrical primitives:

    - **Hosts (`host`)**: ${options.host.description}
    - **Contracts (`contract`)**: ${options.contract.description}
    - **Implementations (`implementation`)**: ${options.implementation.description}
    - **Features (`feature`)**: ${options.feature.description}
    - **Libraries (`lib`)**: ${options.lib.description}

    ${conceptualDiagram}

    <details>
    <summary>Full Architecture Diagram (Click to expand)</summary>

    ${topologyMermaid}

    </details>

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

    ## Configuration Catalog

    <details>
    <summary><h3>Primitives</h3></summary>

    Foundational abstractions governing components across the repository, declared in [`primitives/`](primitives/). See [Primitives Documentation](docs/PRIMITIVES.md) for full specifications.

    ${primitivesTable}

    </details>

    <details>
    <summary><h3>Hosts</h3></summary>

    Master registry of target hosts declared via `options.host` in [`primitives/host/default.nix`](primitives/host/default.nix). See [Hosts Documentation](docs/HOSTS.md) for full metadata.

    ${hostsTable}

    ### Host Installation & Deployment

    Target hosts in this configuration are partitioned declaratively with Disko, persisted through Impermanence, and configured via Nix flakes. Host-specific copy-paste commands are documented on each host's deep-dive page:
    - [`astrolabe`](docs/hosts/astrolabe.md#installation): Headless public edge and VPS server.
    - [`x240`](docs/hosts/x240.md#installation): Graphical workstation laptop.

    #### Prerequisites & Requirements

    Before installing a host, verify:
    1. **Architecture & Firmware**: 64-bit x86 target system booted in UEFI mode with network connectivity.
    2. **Disko Partitioning**: The disk definition in the host configuration matches the physical disk device path (e.g. `/dev/sda` or `/dev/nvme0n1`).
    3. **SOPS Age Private Key**: The host's age decryption key must be placed at `/persist/sops-nix/key.txt` with permissions `0400` so secrets decrypt on first boot.

    #### Track 1: Remote Automated Deployment via `nixos-anywhere`

    For headless cloud instances or network-accessible hosts booted into a live environment:

    ```bash
    # 1. Obtain and verify SSH root access to target IP
    ssh root@<TARGET-IP>

    # 2. Deploy system, format partitions via Disko, and copy SOPS secret key
    nix run github:nix-community/nixos-anywhere -- \
      --flake .#<HOST> \
      --copy-secret /path/to/host-key.txt /persist/sops-nix/key.txt \
      root@<TARGET-IP>
    ```

    #### Track 2: Local Host Installation (NixOS Live ISO)

    For bare-metal physical hosts booted from a standard NixOS Live ISO USB drive:

    ```bash
    # 1. Elevate to root in the live environment
    sudo -i

    # 2. Clone repository to live memory
    git clone https://github.com/LW-54/nixconf /tmp/nixconf
    cd /tmp/nixconf

    # 3. Format disk and mount partitions declaratively via Disko
    nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
      --mode zap_create_mount \
      --flake .#<HOST>

    # 4. Provision SOPS age secret key on mounted persistence volume
    mkdir -p /mnt/persist/sops-nix
    chmod 0700 /mnt/persist/sops-nix
    cp /path/to/host-key.txt /mnt/persist/sops-nix/key.txt
    chmod 0400 /mnt/persist/sops-nix/key.txt

    # 5. Install the NixOS system configuration to /mnt
    nixos-install --flake .#<HOST> --no-root-passwd

    # 6. Reboot into the installed system
    reboot
    ```

    #### Track 3: Host Configuration Maintenance & Rebuild

    To apply configuration changes on a running system:

    ```bash
    # Local rebuild and activation
    sudo nixos-rebuild switch --flake .#<HOST>

    # Remote rebuild and activation over SSH
    nixos-rebuild switch --flake .#<HOST> --target-host root@<TARGET-IP>
    ```

    </details>

    <details>
    <summary><h3>Contracts</h3></summary>

    Pure contract interfaces declared via `options.contract` in [`primitives/contract/default.nix`](primitives/contract/default.nix). See [Contracts Documentation](docs/CONTRACTS.md) for full contract specifications.

    ${contractsTable}

    </details>

    <details>
    <summary><h3>Implementations</h3></summary>

    Concrete contract providers declared via `options.implementation` in [`primitives/implementation.nix`](primitives/implementation.nix). See [Implementations Documentation](docs/IMPLEMENTATIONS.md) for provider assignments.

    ${implsTable}

    </details>

    <details>
    <summary><h3>Features</h3></summary>

    Reusable system services and applications declared via `options.feature` in [`primitives/feature.nix`](primitives/feature.nix). See [Features Documentation](docs/FEATURES.md) for exported outputs.

    ${featuresTable}

    </details>

    <details>
    <summary><h3>Libraries</h3></summary>

    Pure reusable helper functions, data types, calculations, and presets declared via `options.lib` in [`primitives/lib.nix`](primitives/lib.nix). See [Library Documentation](docs/LIB.md) for full function signatures and docstrings.

    ${libsTable}

    </details>

    <details>
    <summary><h3>Packages</h3></summary>

    Executable packages exported on `flake.packages`. See [Packages Documentation](docs/PACKAGES.md) for the full catalog.

    ${lib.concatMapStringsSep "\n" renderPkgBlock pkgs}

    </details>

    <details>
    <summary><h3>DevShells</h3></summary>

    Interactive shell environments exported on `flake.devShells`. See [DevShells Documentation](docs/DEVSHELLS.md) for administrative environments.

    ${lib.concatMapStringsSep "\n" renderShellBlock shells}

    </details>

    ## Host Testing

    Every host is verified automatically, without access to any real secret. Modules declare what to check through the [`testing`](docs/contracts/testing.md) contract, the [`nixos-test`](docs/implementations/nixos-test.md) implementation adds the built-in essentials, and the harness in [`meta/tests/default.nix`](meta/tests/default.nix) derives the tiers below for every `host.<name>`. New hosts and modules get their tests with no changes to the harness.

    | Tier | Cost | What it proves | Where it runs |
    | --- | --- | --- | --- |
    | `eval` | seconds, builds nothing | The full system evaluates (all NixOS assertions) and essentials hold: boot loader enabled, accounts login-ready, SSH reachable, `system.stateVersion` set, hostname matches flake attribute. | pre-commit (`nix flake check --no-build`), CI |
    | `inspect` | seconds, builds artifacts | Verifies generated `/etc` artifacts (fstab, shells, pam.d/login, pam.d/sshd, sudoers, sshd_config, systemd) in a pure sandbox without needing KVM. | CI, pre-push |
    | `vm` | minutes, needs KVM | The real system closure boots in QEMU, secrets decrypt through sops-nix, password login and `sudo` work, SSH login verifies the provisioned host key, services come up, and 0 failed units. | CI (`nix flake check`) |
    | `install` | slow, needs KVM | The real Disko layout is partitioned, installed, and booted through its real boot loader, and Impermanence keeps `/persist` while wiping root across reboot. | weekly / manual CI job |

    ${hostTestsMatrix}

    ```bash
    nix run .#test                       # eval tier for every host (fast feedback while editing)
    nix run .#test -- inspect            # validate built system artifacts without KVM
    nix run .#test -- vm astrolabe       # boot one host and run its checks
    nix run .#test -- install x240       # partition, install and reboot through the boot loader
    nix run .#test -- run astrolabe      # interactive VM with stand-in secrets (SSH on localhost:2222)
    nix run .#test -- interactive x240   # NixOS test driver REPL
    nix run .#test -- list               # hosts, tiers and their checks
    ```

    **Stand-in secrets.** Test variants set `testing.enable`. The secrets implementation then re-encrypts each secret's `secrets.files.<name>.testValue` with a throwaway age key generated at build time, and decrypts it through the regular sops-nix path. Modules give format-sensitive secrets meaningful stand-ins, for example the password hash of `test` or the nixpkgs snakeoil SSH keys. Production systems are unaffected: their derivations stay identical.

    **Adding checks.** Any module can contribute checks, and every host importing it inherits them:

    ```nix
    testing.checks.my-service = {
      description = "my-service answers on its port";
      script = '''
        machine.wait_for_unit("my-service.service")
        machine.wait_for_open_port(8080)
      ''';
    };
    testing.evalChecks.my-port = {
      assertion = config.services.my-service.port != 22;
      message = "my-service must not take the SSH port.";
    };
    secrets.files.my-token.testValue = "TOKEN=dummy";
    ```

    Hosts tune or opt out with `testing.evalChecks.<name>.enable`, `testing.checks.<name>.enable`, `testing.vm.allowedFailedUnits`, `testing.vm.memorySize`, `testing.vm.enable`, and `testing.install.enable`.

    ## Documentation

    Comprehensive documentation is generated directly from Nix evaluation using the pure-Nix Labeled Property Graph (LPG) pipeline.

    - [Hosts Documentation](docs/HOSTS.md): Target host declarations, architecture specs, and hardware manifests.
    - [Contracts Documentation](docs/CONTRACTS.md): Pure contract interfaces, schema options, and custom types.
    - [Implementations Documentation](docs/IMPLEMENTATIONS.md): Provider implementations satisfying contracts.
    - [Features Documentation](docs/FEATURES.md): Modular system services, applications, and desktop environments.
    - [Modules Documentation](docs/MODULES.md): Directory of all exported NixOS modules.
    - [Packages Documentation](docs/PACKAGES.md): Executable packages exported across platforms.
    - [DevShells Documentation](docs/DEVSHELLS.md): Administrative and development shell environments.
    - [Library Documentation](docs/LIB.md): Flake library functions, type signatures, and RFC 145 docstrings.
    - [Semantic Code Property Graph Architecture](docs/GRAPH.md): Unified pure-Nix CPG merging AST, CFG, and PDG.
    - [Documentation Pipeline Reference](docs/DOCS.md): Pure-Nix LPG graph IR and documentation generator guide.

    To re-generate or verify documentation integrity, use the `docs` CLI package:

    ```bash
    nix run .#docs -- --write
    nix run .#docs -- --check
    ```

    ## License

    This project is licensed under the [MIT License](LICENSE).
  '';

  renderDocsGuide = {graph}: ''
    # Documentation Pipeline Reference

    Pure-Nix documentation generation architecture, Labeled Property Graph (LPG) IR, and CLI toolchain.

    [← Back to Main README](../README.md)

    ## Architecture Overview

    The documentation generator is implemented as a pure-Nix evaluation pipeline structured into modular components:

    - [`primitives/primitive/lib/check.nix`](../primitives/primitive/lib/check.nix): Formal specification checks and verification assertions.
    - [`meta/docs/parser.nix`](../meta/docs/parser.nix): RFC 145 docstring parser extracting summaries, argument inputs, types, and examples.
    - [`meta/docs/graph/`](../meta/docs/graph): LPG property graph builder synthesizing `nixconf.json`.
    - [`meta/docs/mermaid.nix`](../meta/docs/mermaid.nix): Declarative Mermaid diagram visualizer with custom styling.
    - [`meta/docs/markdown/`](../meta/docs/markdown): Markdown synthesizers generating the repository documentation suite.
    - [`meta/docs/cli.nix`](../meta/docs/cli.nix): CLI application wrapper providing `nix run .#docs`.

    ## Command Reference

    ```bash
    # Synchronize all documentation files directly into working tree
    nix run .#docs -- --write

    # Verify that documentation suite is synchronized (non-blocking)
    nix run .#docs -- --check

    # Inspect evaluated LPG property graph in JSON format
    nix run .#docs -- --json
    ```
  '';

  renderGraphDoc = {
    graph,
    cpg,
  }: let
    nodeCount = builtins.length (builtins.attrNames cpg.nodes);
    edgeCount = builtins.length cpg.edges;
    relCounts = builtins.mapAttrs (_: es: builtins.length es) cpg.indices.byRelation;
    relNames = builtins.attrNames relCounts;
    kindCounts = builtins.mapAttrs (_: ns: builtins.length ns) cpg.indices.byKind;
  in ''
    # Semantic Code Property Graph (CPG) Architecture

    This document describes the unified Semantic Code Property Graph (CPG) of `nixconf`, merging Abstract Syntax Tree (AST), Control Flow Graph (CFG), and Program Dependence Graph (PDG) representations directly from evaluated Nix expressions.

    Raw serialized graph dataset: [`docs/cpg.json`](cpg.json).

    [← Back to Main README](../README.md)

    ---

    ## 1. Graph Metrics Overview

    The complete semantic graph extracted from pure Nix evaluation:

    | Dimension | Metric | Description |
    | :--- | :--- | :--- |
    | **Total Nodes** | **${toString nodeCount}** | Deduplicated primitives, hosts, configurations, modules, options, types, packages, devShells, and functions. |
    | **Total Edges** | **${toString edgeCount}** | Directed relationships across Ontological, AST, Eval, and Derivation strata. |
    | **Relations** | **${toString (builtins.length relNames)}** | Canonical Computer Science relation predicates (`${lib.concatStringsSep "`, `" relNames}`). |
    | **Strata** | **4** | Ontological Intent (`onto`), Syntactic AST (`ast`), Operational Fixpoint (`eval`), Derivation Substrate (`drv`). |
    | **Evaluation** | **100% Pure** | Zero `--impure` dependencies, zero regex text-scanning, zero heuristic disk path reads. |

    ---

    ## 2. Relation Predicate Breakdown

    Every edge in the CPG represents an exact computer science relation across the four strata:

    | Relation | Stratum | Count | Description | Nix Implementation Grounding |
    | :--- | :---: | :---: | :--- | :--- |
    | **`outputs`** | AST / Eval / Drv | ${toString (relCounts.outputs or 0)} | Flake artifact or component emission | Primitives outputting standard configurations, modules, packages, devShells, and functions |
    | **`imports`** | Eval | ${toString (relCounts.imports or 0)} | Compilation unit composition | Evaluated NixOS configurations importing concrete NixOS modules |
    | **`contains`** | Onto | ${toString (relCounts.contains or 0)} | Lexical parent-child containment | Primitives containing declared instances |
    | **`writes`** | Eval | ${toString (relCounts.writes or 0)} | Option value definition (Def / Store) | Module fixpoint definition extracted via `definitionsWithLocations` |
    | **`declares`** | AST | ${toString (relCounts.declares or 0)} | Interface specification declaration | Contracts declaring public options and custom types |
    | **`flowsTo`** | Eval | ${toString (relCounts.flowsTo or 0)} | End-to-end data dependence channel | Directed channel connecting option writer to consuming implementation |
    | **`reads`** | Eval | ${toString (relCounts.reads or 0)} | Option value inspection (Use / Load) | Consumer implementation reading contract options |
    | **`typedBy`** | AST | ${toString (relCounts.typedBy or 0)} | Option type-system binding | Contract options bound to custom submodule types |
    | **`implements`** | Onto | ${toString (relCounts.implements or 0)} | Contract fulfillment | Explicit architectural relationship in `primitives/implementation.nix` |
    | **`dependsOn`** | Drv | ${toString (relCounts.dependsOn or 0)} | Software package dependency | Modules and devShells depending on executable packages |

    ---

    ## 3. The Four-Strata Architecture

    ```mermaid
    graph TD
        classDef onto fill:#24292e,stroke:#f1e05a,stroke-width:2px,color:#fff;
        classDef ast fill:#1f2428,stroke:#58a6ff,stroke-width:2px,color:#fff;
        classDef eval fill:#161b22,stroke:#7ee787,stroke-width:2px,color:#fff;
        classDef drv fill:#2a1b3d,stroke:#d2a8ff,stroke-width:2px,color:#fff;

        subgraph S1 ["1. Ontological Intent Stratum (onto)"]
            H["urn:nixconf:onto:host:astrolabe"]:::onto
            F["urn:nixconf:onto:feature:ssh"]:::onto
            I["urn:nixconf:onto:implementation:caddy"]:::onto
            C["urn:nixconf:onto:contract:reverse-proxy"]:::onto
        end

        subgraph S2 ["2. Syntactic AST Stratum (ast)"]
            M_H["urn:nixconf:ast:module:astrolabe-services"]:::ast
            M_F["urn:nixconf:ast:module:ssh"]:::ast
            M_I["urn:nixconf:ast:module:caddy"]:::ast
            OPT["urn:nixconf:ast:option:reverse-proxy.domain"]:::ast
            TYP["urn:nixconf:ast:type:reverse-proxy.fqdn"]:::ast
        end

        subgraph S3 ["3. Operational Fixpoint Stratum (eval)"]
            NC["urn:nixconf:eval:configuration:astrolabe"]:::eval
        end

        subgraph S4 ["4. Derivation Substrate Stratum (drv)"]
            PKG["urn:nixconf:drv:package:caddy"]:::drv
        end

        %% Ontological to AST & Eval
        H -- outputs --> NC
        H -- outputs --> M_H
        F -- outputs --> M_F
        I -- outputs --> M_I
        I -- implements --> C
        C -- declares --> OPT
        C -- declares --> TYP

        %% Eval Composition & Dataflow
        NC -- imports --> M_H
        NC -- imports --> M_F
        NC -- imports --> M_I
        M_H -- writes --> OPT
        M_I -- reads --> OPT
        M_H -- flowsTo --> M_I

        %% Type & Package Grounding
        OPT -- typedBy --> TYP
        M_I -- dependsOn --> PKG
    ```

    ---

    ## 4. Node Classification

    The graph indexes **${toString nodeCount} nodes** partitioned into distinct functional roles:

    | Node Category | Count | Example Canonical URNs | Description |
    | :--- | :---: | :--- | :--- |
    | **NixOS Modules** | ${toString (kindCounts.module or 0)} | `urn:nixconf:ast:module:ssh`, `urn:nixconf:ast:module:caddy` | Composable NixOS system modules exported on `flake.nixosModules`. |
    | **Library Functions** | ${toString (kindCounts.function or 0)} | `urn:nixconf:ast:function:stripLeadingIndentation` | Pure library helper functions with RFC 145 docstring metadata. |
    | **Contract Options** | ${toString (kindCounts.option or 0)} | `urn:nixconf:ast:option:persistence.directories` | Public contract interface options with types and descriptions. |
    | **Features** | ${toString (kindCounts.feature or 0)} | `urn:nixconf:onto:feature:ssh`, `urn:nixconf:onto:feature:git` | High-level system and desktop capability bundles. |
    | **Library Symbols** | ${toString (kindCounts.symbol or 0)} | `urn:nixconf:ast:symbol:defaultLayout` | Exported library values and constants. |
    | **Custom Types** | ${toString (kindCounts.type or 0)} | `urn:nixconf:ast:type:persistence.user` | RFC-typed submodule types defined in contracts. |
    | **Exported Packages** | ${toString (kindCounts.package or 0)} | `urn:nixconf:drv:package:caddy`, `urn:nixconf:drv:package:git` | Executable packages and derivations exported on `flake.packages`. |
    | **Library Submodules** | ${toString (kindCounts.lib or 0)} | `urn:nixconf:onto:lib:core`, `urn:nixconf:onto:lib:parser` | Library namespaces grouping functions and symbols. |
    | **Implementations** | ${toString (kindCounts.implementation or 0)} | `urn:nixconf:onto:implementation:caddy` | Concrete capability provider implementations. |
    | **Contracts** | ${toString (kindCounts.contract or 0)} | `urn:nixconf:onto:contract:reverse-proxy` | Typed contract interfaces. |
    | **Primitives** | ${toString (kindCounts.primitive or 0)} | `urn:nixconf:onto:primitive:host` | Meta-primitives defining schema construction rules. |
    | **Exported DevShells** | ${toString (kindCounts.devShell or 0)} | `urn:nixconf:drv:devShell:master-ssh` | Interactive development and administrative shells. |
    | **Target Hosts** | ${toString (kindCounts.host or 0)} | `urn:nixconf:onto:host:astrolabe`, `urn:nixconf:onto:host:x240` | Root evaluated target machine wrappers. |
    | **Configurations** | ${toString (kindCounts.configuration or 0)} | `urn:nixconf:eval:configuration:astrolabe` | Evaluated NixOS system configurations on `flake.nixosConfigurations`. |

    ---

    ## 5. Inspecting the Graph

    ### A. Raw JSON Dataset
    Inspect the complete dataset using `jq`:
    ```bash
    # General summary
    jq '{nodeCount: (.nodes | length), edgeCount: (.edges | length), relations: (.indices.byRelation | map_values(length))}' docs/cpg.json

    # Find all modules that write to options
    jq '.edges[] | select(.relation == "writes") | {source, target, file: .meta.file}' docs/cpg.json

    # Inspect outgoing edges for a specific configuration
    jq '.indices.outgoing["urn:nixconf:eval:configuration:astrolabe"]' docs/cpg.json
    ```

    ### B. Command-Line Graph Queries (via Nix)
    Query graph metrics and slices on the fly using pure evaluation:
    ```bash
    # Print all edge relations and counts
    nix eval --apply 'f: builtins.mapAttrs (_: es: builtins.length es) (f {}).indices.byRelation' .#lib.graph.buildCPG --json

    # Forward slice from a configuration (trace reachable dependencies)
    nix eval --apply 'f: (f.graph.forwardSlice { cpg = f.graph.buildCPG {}; nodeId = "urn:nixconf:eval:configuration:astrolabe"; maxDepth = 2; }).nodeIds' .#lib --json

    # Backward slice from an option (trace all writers and consumers)
    nix eval --apply 'f: (f.graph.backwardSlice { cpg = f.graph.buildCPG {}; nodeId = "urn:nixconf:ast:option:reverse-proxy.domain"; maxDepth = 2; }).nodeIds' .#lib --json
    ```
  '';

  renderPrimitivesIndex = {graph}: ''
    # Primitives Architecture & Catalog

    Foundational abstractions governing components across the repository, declared in [`primitives/`](../primitives/).

    [← Back to Main README](../README.md)

    ## Overview

    A primitive defines the grammar, options schema, and export lifecycle for a class of system components. The repository defines 6 symmetrical primitives evaluated across a two-pass module pipeline:

    ${graphLib.renderTable {
      headers = ["Primitive" "Description" "Source File" "Documentation"];
      columns = [
        (p: "**`${p.name}`**")
        (p: p.desc)
        (p: "[`${p.file}`](${p.file})")
        (p: "[${p.docTitle}](${p.docLink})")
      ];
      rows = [
        {
          name = "primitive";
          desc = "Meta-primitive defining how primitives are constructed and registered.";
          file = "../primitives/primitive/default.nix";
          docTitle = "Primitives Catalog";
          docLink = "PRIMITIVES.md";
        }
        {
          name = "host";
          desc = "Declarative target host machines binding hardware, platform, and enabled features.";
          file = "../primitives/host/default.nix";
          docTitle = "Hosts Documentation";
          docLink = "HOSTS.md";
        }
        {
          name = "contract";
          desc = "Abstract contract interfaces defining shared option schemas decoupled from backends.";
          file = "../primitives/contract/default.nix";
          docTitle = "Contracts Documentation";
          docLink = "CONTRACTS.md";
        }
        {
          name = "implementation";
          desc = "Concrete capability providers satisfying contract interfaces with services and packages.";
          file = "../primitives/implementation.nix";
          docTitle = "Implementations Documentation";
          docLink = "IMPLEMENTATIONS.md";
        }
        {
          name = "feature";
          desc = "Reusable system configurations and desktop services consuming contracts.";
          file = "../primitives/feature.nix";
          docTitle = "Features Documentation";
          docLink = "FEATURES.md";
        }
        {
          name = "lib";
          desc = "Pure reusable helper functions, data types, calculations, and presets.";
          file = "../primitives/lib.nix";
          docTitle = "Library Documentation";
          docLink = "LIB.md";
        }
      ];
    }}

    ## Two-Pass Evaluation Pipeline

    1. **Pass 1 (`primitives/`)**: Evaluates primitive declarations using `lib.evalModules`. Injects `option` constructors and `export` helpers via `_module.args`. Resolves `options.primitive` and synthesizes Pass 2 options and export hooks.
    2. **Pass 2 (`meta/` + `modules/`)**: Evaluates domain infrastructure instances (`hosts/`, `contracts/`, `implementations/`, `features/`) and meta-tooling (`parts.nix`, `docs/`) with zero cyclic dependencies.
  '';
in {
  internal.docs.markdown.root = {
    inherit
      renderReadme
      renderDocsGuide
      renderGraphDoc
      renderPrimitivesIndex
      ;
  };
}
