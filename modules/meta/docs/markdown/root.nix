{
  lib,
  config,
  options,
  ...
}: let
  graphLib = config.flake.lib.docsGraph;
  mermaidLib = config.flake.lib.docsMermaid;

  renderReadme = {graph}: let
    hosts = builtins.filter (n: n.kind == "host") (builtins.attrValues graph.nodes);
    contracts = builtins.filter (n: n.kind == "contract") (builtins.attrValues graph.nodes);
    impls = builtins.filter (n: n.kind == "impl") (builtins.attrValues graph.nodes);
    features = builtins.filter (n: n.kind == "feature") (builtins.attrValues graph.nodes);
    libs = builtins.filter (n: n.kind == "lib") (builtins.attrValues graph.nodes);
    pkgs = builtins.filter (n: n.kind == "pkg") (builtins.attrValues graph.nodes);
    shells = builtins.filter (n: n.kind == "shell") (builtins.attrValues graph.nodes);

    topologyMermaid = mermaidLib.renderMermaid (graphLib.filterGraph {
        nodeFilter = n: builtins.elem n.kind ["host" "contract" "impl" "feature" "lib"];
        edgeFilter = e: builtins.elem e.kind ["IMPORTS" "IMPLEMENTS" "CONSUMES" "EXPORTS"];
      }
      graph);

    hostRow = h: let
      desc = h.properties.description or "";
      sys = h.properties.system or "x86_64-linux";
    in "| [`${h.name}`](docs/hosts/${h.name}.md) | ${desc} | `${sys}` | [More →](docs/hosts/${h.name}.md) |";

    contractRow = c: let
      desc = c.properties.description or "";
      implList = map (i: "[`${i.name}`](docs/implementations/${i.name}.md)") (c.properties.implementers or []);
      implStr =
        if implList != []
        then lib.concatStringsSep ", " implList
        else "*none*";
    in "| [`${c.name}`](docs/contracts/${c.name}.md) | ${desc} | ${implStr} | [More →](docs/contracts/${c.name}.md) |";

    implRow = i: let
      desc = i.properties.description or "";
      cName = i.properties.contract or "";
      cLink =
        if cName != ""
        then "[`${cName}`](docs/contracts/${cName}.md)"
        else "*none*";
    in "| [`${i.name}`](docs/implementations/${i.name}.md) | ${desc} | ${cLink} | [More →](docs/implementations/${i.name}.md) |";

    featureRow = f: let
      desc = f.properties.description or "";
    in "| [`${f.name}`](docs/features/${f.name}.md) | ${desc} | [More →](docs/features/${f.name}.md) |";

    libRow = l: let
      desc = l.properties.description or "";
    in "| [`flake.lib.${l.name}`](docs/lib/${l.name}.md) | ${desc} | [More →](docs/lib/${l.name}.md) |";

    renderPkgBlock = p: ''
      #### [`${p.name}`](docs/PACKAGES.md#${p.name})
      ${p.properties.description}

      ```bash
      ${p.properties.runCommand}
      ```
    '';

    renderShellBlock = s: ''
      #### [`${s.name}`](docs/DEVSHELLS.md#${s.name})
      ${s.properties.description}

      ```bash
      ${s.properties.developCommand}
      ```
    '';
  in ''
    <h1 align="center">❄️ nixconf</h1>

    <p align="center">Declarative multi-host infrastructure, capability contracts, and modular NixOS configuration repository powered by pure-Nix evaluation.</p>

    ## Architecture Overview

    The repository architecture is governed by five first-class, symmetrical primitives:

    - **Hosts (`host`)**: ${options.host.description}
    - **Contracts (`contract`)**: ${options.contract.description}
    - **Implementations (`implementation`)**: ${options.implementation.description}
    - **Features (`feature`)**: ${options.feature.description}
    - **Libraries (`lib`)**: ${options.lib.description}

    ${mermaidLib.renderConceptualDiagram}

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

    - **`import-tree`**: Automated dendritic module discovery that recursively scans and imports all `.nix` files under `modules/` as top-level flake-parts modules.

    ## Configuration Catalog

    <details>
    <summary><h3>Hosts</h3></summary>

    Master registry of target hosts declared via `options.host` in [`modules/meta/primitives/host.nix`](modules/meta/primitives/host.nix). See [Hosts Documentation](docs/HOSTS.md) for full metadata.

    | Host | Description | System | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" hostRow hosts}

    ### Host Installation & Deployment

    Target hosts in this configuration are partitioned declaratively with Disko, persisted through Impermanence, and configured via Nix flakes. Host-specific copy-paste commands are documented on each host's deep-dive page:
    - [`astrolabe`](docs/hosts/astrolabe.md#installation): Headless public edge and VPS server.
    - [`x240`](docs/hosts/x240.md#installation): Graphical workstation laptop.

    #### Prerequisites & Requirements

    Before installing a host, verify:
    1. **Architecture & Firmware**: 64-bit x86 target system booted in UEFI mode with network connectivity.
    2. **Disko Partitioning**: The disk definition in the host configuration matches the physical disk device path (e.g. `/dev/sda` or `/dev/nvme0n1`).
    3. **SOPS Age Private Key**: The host's age decryption key must be placed at `/persist/var/lib/sops-nix/key.txt` with permissions `0400` so secrets decrypt on first boot.

    #### Track 1: Remote Automated Deployment via `nixos-anywhere`

    For headless cloud instances or network-accessible hosts booted into a live environment:

    ```bash
    # 1. Obtain and verify SSH root access to target IP
    ssh root@<TARGET-IP>

    # 2. Deploy system, format partitions via Disko, and copy SOPS secret key
    nix run github:nix-community/nixos-anywhere -- \
      --flake .#<HOST> \
      --copy-secret /path/to/host-key.txt /persist/var/lib/sops-nix/key.txt \
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
    mkdir -p /mnt/persist/var/lib/sops-nix
    chmod 0700 /mnt/persist/var/lib/sops-nix
    cp /path/to/host-key.txt /mnt/persist/var/lib/sops-nix/key.txt
    chmod 0400 /mnt/persist/var/lib/sops-nix/key.txt

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

    Pure capability interfaces declared via `options.contract` in [`modules/meta/primitives/contract.nix`](modules/meta/primitives/contract.nix). See [Contracts Documentation](docs/CONTRACTS.md) for full capability specifications.

    | Contract | Description | Implementations | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" contractRow contracts}

    </details>

    <details>
    <summary><h3>Implementations</h3></summary>

    Concrete contract providers declared via `options.implementation` in [`modules/meta/primitives/implementation.nix`](modules/meta/primitives/implementation.nix). See [Implementations Documentation](docs/IMPLEMENTATIONS.md) for provider assignments.

    | Implementation | Description | Contract | Docs |
    | :--- | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" implRow impls}

    </details>

    <details>
    <summary><h3>Features</h3></summary>

    Reusable system services and applications declared via `options.feature` in [`modules/meta/primitives/feature.nix`](modules/meta/primitives/feature.nix). See [Features Documentation](docs/FEATURES.md) for exported outputs.

    | Feature | Description | Docs |
    | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" featureRow features}

    </details>

    <details>
    <summary><h3>Libraries</h3></summary>

    Pure reusable helper functions, data types, calculations, and presets declared via `options.lib` in [`modules/meta/primitives/lib.nix`](modules/meta/primitives/lib.nix). See [Library Documentation](docs/LIB.md) for full function signatures and docstrings.

    | Library Namespace | Description | Docs |
    | :--- | :--- | :--- |
    ${lib.concatMapStringsSep "\n" libRow libs}

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

    ## Documentation

    Comprehensive documentation is generated directly from Nix evaluation using the pure-Nix Labeled Property Graph (LPG) pipeline.

    - [Hosts Documentation](docs/HOSTS.md): Target host declarations, architecture specs, and hardware manifests.
    - [Contracts Documentation](docs/CONTRACTS.md): Pure capability interfaces, schema options, and custom types.
    - [Implementations Documentation](docs/IMPLEMENTATIONS.md): Provider implementations satisfying capability contracts.
    - [Features Documentation](docs/FEATURES.md): Modular system services, applications, and desktop environments.
    - [Modules Documentation](docs/MODULES.md): Directory of all exported NixOS modules.
    - [Packages Documentation](docs/PACKAGES.md): Executable packages exported across platforms.
    - [DevShells Documentation](docs/DEVSHELLS.md): Administrative and development shell environments.
    - [Library Documentation](docs/LIB.md): Flake library functions, type signatures, and RFC 145 docstrings.
    - [Documentation Pipeline Reference](docs/DOCS.md): Pure-Nix LPG graph IR and documentation generator guide.
    - [Documentation Gaps & TODOs](docs/TODO.md): Automated repository-wide register tracking missing docstrings and documentation tasks.

    To re-generate or verify documentation integrity, use the `docs` CLI package:

    ```bash
    nix run .#docs -- --write
    nix run .#docs -- --check
    ```

    ## License

    This project is licensed under the [MIT License](LICENSE).
  '';

  renderTodoIndex = {graph}: let
    todos = graph.diagnostics.todos or [];
    todoTable =
      if todos != []
      then ''
        | Severity | Target | Location | Diagnostic |
        | :--- | :--- | :--- | :--- |
        ${lib.concatMapStringsSep "\n" (t: let
          k = t.kind or "TODO";
          tgt = t.target or (t.id or "unknown");
          loc =
            if t ? file && t.file != null && t.file != "unknown"
            then "`${t.file}:${toString (t.line or 1)}`"
            else "*in-memory*";
          msg = builtins.replaceStrings ["\n" "|"] [" " "\\|"] (t.message or "");
          targetName =
            if lib.hasPrefix "fn:" tgt
            then "flake.lib." + lib.removePrefix "fn:" tgt
            else if lib.hasPrefix "opt:" tgt
            then "options." + lib.removePrefix "opt:" tgt
            else tgt;
        in "| `${k}` | `${targetName}` | ${loc} | ${msg} |")
        todos}
      ''
      else "Zero documentation debt! All library functions, options, and interfaces are fully documented according to the documentation specification.";
  in ''
    # Documentation Gaps & TODOs

    Repository-wide register tracking missing docstrings, undocumented symbols, and documentation tasks.

    [← Back to Main README](../README.md)

    ## Diagnostic Register

    ${todoTable}
  '';

  renderDocsGuide = {graph}: ''
    # Documentation Pipeline Reference

    Pure-Nix documentation generation architecture, Labeled Property Graph (LPG) IR, and CLI toolchain.

    [← Back to Main README](../README.md)

    ## Architecture Overview

    The documentation generator is implemented as a pure-Nix evaluation pipeline structured into modular components:

    - [`modules/meta/docs/spec/`](../modules/meta/docs/spec): Formal schemas, node types, edge kinds, and verification assertions.
    - [`modules/meta/docs/parser.nix`](../modules/meta/docs/parser.nix): RFC 145 docstring parser extracting summaries, argument inputs, types, and examples.
    - [`modules/meta/docs/graph/`](../modules/meta/docs/graph): LPG property graph builder synthesizing `nixconf.json`.
    - [`modules/meta/docs/mermaid.nix`](../modules/meta/docs/mermaid.nix): Declarative Mermaid diagram visualizer with custom styling.
    - [`modules/meta/docs/markdown/`](../modules/meta/docs/markdown): Markdown synthesizers generating the repository documentation suite.
    - [`modules/meta/docs/cli.nix`](../modules/meta/docs/cli.nix): CLI application wrapper providing `nix run .#docs`.

    ## Command Reference

    ```bash
    # Synchronize all documentation files directly into working tree
    nix run .#docs -- --write

    # Verify that documentation suite is synchronized (non-blocking)
    nix run .#docs -- --check

    # Verify documentation with zero-debt enforcement
    nix run .#docs -- --check --strict

    # Inspect evaluated LPG property graph in JSON format
    nix run .#docs -- --json
    ```
  '';
in {
  internal.docs.markdown.root = {
    inherit
      renderReadme
      renderTodoIndex
      renderDocsGuide
      ;
  };
}
