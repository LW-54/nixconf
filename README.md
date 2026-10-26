<h1 align="center">❄️ nixconf</h1>

<p align="center">Declarative multi-host infrastructure, contracts, and modular NixOS configuration repository powered by pure-Nix evaluation.</p>

## Architecture Overview

The repository architecture is governed by five first-class, symmetrical primitives:

- **Hosts (`host`)**: Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.
- **Contracts (`contract`)**: Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.
- **Implementations (`implementation`)**: Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.
- **Features (`feature`)**: Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.
- **Libraries (`lib`)**: Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.

```mermaid
flowchart TD
    Host["Host"]
    Implementation["Implementation"]
    Feature["Feature"]
    Contract["Contract"]
    Library["Library"]

    Host -->|"imports"| Implementation
    Host -->|"imports"| Feature
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


<details>
<summary>Full Architecture Diagram (Click to expand)</summary>

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__astrolabe["astrolabe"]:::hostNode
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__backup(["backup"]):::contractNode
        urn__nixconf__onto__contract__default_user(["default-user"]):::contractNode
        urn__nixconf__onto__contract__home(["home"]):::contractNode
        urn__nixconf__onto__contract__persistence(["persistence"]):::contractNode
        urn__nixconf__onto__contract__resources(["resources"]):::contractNode
        urn__nixconf__onto__contract__reverse_proxy(["reverse-proxy"]):::contractNode
        urn__nixconf__onto__contract__secrets(["secrets"]):::contractNode
        urn__nixconf__onto__contract__wayland(["wayland"]):::contractNode
    end

    subgraph Features["Features"]
        urn__nixconf__onto__feature__antigravity["antigravity"]:::featureNode
        urn__nixconf__onto__feature__audio["audio"]:::featureNode
        urn__nixconf__onto__feature__bitwarden["bitwarden"]:::featureNode
        urn__nixconf__onto__feature__cosmic["cosmic"]:::featureNode
        urn__nixconf__onto__feature__cursor["cursor"]:::featureNode
        urn__nixconf__onto__feature__direnv["direnv"]:::featureNode
        urn__nixconf__onto__feature__disko["disko"]:::featureNode
        urn__nixconf__onto__feature__dolphin["dolphin"]:::featureNode
        urn__nixconf__onto__feature__fonts["fonts"]:::featureNode
        urn__nixconf__onto__feature__foot["foot"]:::featureNode
        urn__nixconf__onto__feature__git["git"]:::featureNode
        urn__nixconf__onto__feature__greetd["greetd"]:::featureNode
        urn__nixconf__onto__feature__helium["helium"]:::featureNode
        urn__nixconf__onto__feature__labwc["labwc"]:::featureNode
        urn__nixconf__onto__feature__locale["locale"]:::featureNode
        urn__nixconf__onto__feature__nix["nix"]:::featureNode
        urn__nixconf__onto__feature__noctalia["noctalia"]:::featureNode
        urn__nixconf__onto__feature__ssh["ssh"]:::featureNode
        urn__nixconf__onto__feature__tack["tack"]:::featureNode
        urn__nixconf__onto__feature__ttyd["ttyd"]:::featureNode
        urn__nixconf__onto__feature__user["user"]:::featureNode
        urn__nixconf__onto__feature__vaultwarden["vaultwarden"]:::featureNode
        urn__nixconf__onto__feature__vivaldi["vivaldi"]:::featureNode
        urn__nixconf__onto__feature__vscode["vscode"]:::featureNode
        urn__nixconf__onto__feature__wifi_eduroam["wifi-eduroam"]:::featureNode
    end

    subgraph Libraries["Libraries"]
        urn__nixconf__onto__lib__backup(["lib: backup"]):::libNode
        urn__nixconf__onto__lib__bitwarden(["lib: bitwarden"]):::libNode
        urn__nixconf__onto__lib__default_user(["lib: default-user"]):::libNode
        urn__nixconf__onto__lib__disko(["lib: disko"]):::libNode
        urn__nixconf__onto__lib__docsMarkdown(["lib: docsMarkdown"]):::libNode
        urn__nixconf__onto__lib__docsMermaid(["lib: docsMermaid"]):::libNode
        urn__nixconf__onto__lib__docsParser(["lib: docsParser"]):::libNode
        urn__nixconf__onto__lib__graph(["lib: graph"]):::libNode
        urn__nixconf__onto__lib__home(["lib: home"]):::libNode
        urn__nixconf__onto__lib__lw(["lib: lw"]):::libNode
        urn__nixconf__onto__lib__persistence(["lib: persistence"]):::libNode
        urn__nixconf__onto__lib__primitive(["lib: primitive"]):::libNode
        urn__nixconf__onto__lib__resources(["lib: resources"]):::libNode
        urn__nixconf__onto__lib__reverse_proxy(["lib: reverse-proxy"]):::libNode
        urn__nixconf__onto__lib__secrets(["lib: secrets"]):::libNode
        urn__nixconf__onto__lib__sops(["lib: sops"]):::libNode
        urn__nixconf__onto__lib__user(["lib: user"]):::libNode
        urn__nixconf__onto__lib__wayland(["lib: wayland"]):::libNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
        urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
        urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__implementation__restic["restic"]:::implNode
        urn__nixconf__onto__implementation__sops["sops"]:::implNode
        urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
    end


    urn__nixconf__onto__feature__antigravity -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__git -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__git -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__locale -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__audio
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__uwsm
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__hjem -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__restic -->|"consumes"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -.->|"implements"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -.->|"implements"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland

classDef hostNode fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
classDef contractNode fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
classDef implNode fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
classDef featureNode fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
classDef libNode fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;
classDef optNode fill:#11111b,stroke:#fab387,stroke-width:1px,color:#cdd6f4;
classDef typeNode fill:#11111b,stroke:#f9e2af,stroke-width:1px,color:#cdd6f4;
classDef fnNode fill:#181825,stroke:#94e2d5,stroke-width:1px,color:#cdd6f4;
classDef pkgNode fill:#181825,stroke:#b4befe,stroke-width:1px,color:#cdd6f4;
classDef shellNode fill:#181825,stroke:#f5c2e7,stroke-width:1px,color:#cdd6f4;

```


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

| Primitive | Description | Source File |
| :--- | :--- | :--- |
| **`primitive`** | Meta-primitive defining how primitives are constructed and registered. | [`primitives/primitive/default.nix`](primitives/primitive/default.nix) |
| **`host`** | Declarative NixOS target machines binding hardware, platform, and enabled features. | [`primitives/host/default.nix`](primitives/host/default.nix) |
| **`contract`** | Abstract contract interfaces defining shared option schemas decoupled from backends. | [`primitives/contract/default.nix`](primitives/contract/default.nix) |
| **`implementation`** | Concrete capability providers satisfying contract interfaces with services and packages. | [`primitives/implementation.nix`](primitives/implementation.nix) |
| **`feature`** | Reusable system configurations and desktop services consuming contracts. | [`primitives/feature.nix`](primitives/feature.nix) |
| **`lib`** | Pure reusable helper functions, data types, calculations, and presets. | [`primitives/lib.nix`](primitives/lib.nix) |

</details>

<details>
<summary><h3>Hosts</h3></summary>

Master registry of target hosts declared via `options.host` in [`primitives/host/default.nix`](primitives/host/default.nix). See [Hosts Documentation](docs/HOSTS.md) for full metadata.

| Host | Description | System | Docs |
| :--- | :--- | :--- | :--- |
| [`astrolabe`](docs/hosts/astrolabe.md) | Headless VPS Server (adje.app public edge and core services). | `x86_64-linux` | [More →](docs/hosts/astrolabe.md) |
| [`x240`](docs/hosts/x240.md) | ThinkPad Laptop Workstation (Desktop graphical workstation). | `x86_64-linux` | [More →](docs/hosts/x240.md) |

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

Pure contract interfaces declared via `options.contract` in [`primitives/contract/default.nix`](primitives/contract/default.nix). See [Contracts Documentation](docs/CONTRACTS.md) for full contract specifications.

| Contract | Description | Implementations | Docs |
| :--- | :--- | :--- | :--- |
| [`backup`](docs/contracts/backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [`restic`](docs/implementations/restic.md) | [More →](docs/contracts/backup.md) |
| [`default-user`](docs/contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](docs/implementations/lw.md) | [More →](docs/contracts/default-user.md) |
| [`home`](docs/contracts/home.md) | Declarative user home dotfile tree, XDG directory specifications, and session environment. | [`hjem`](docs/implementations/hjem.md) | [More →](docs/contracts/home.md) |
| [`persistence`](docs/contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](docs/implementations/impermanence.md) | [More →](docs/contracts/persistence.md) |
| [`resources`](docs/contracts/resources.md) | System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling. | [`cgroups`](docs/implementations/cgroups.md) | [More →](docs/contracts/resources.md) |
| [`reverse-proxy`](docs/contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](docs/implementations/caddy.md) | [More →](docs/contracts/reverse-proxy.md) |
| [`secrets`](docs/contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](docs/implementations/sops.md) | [More →](docs/contracts/secrets.md) |
| [`wayland`](docs/contracts/wayland.md) | Wayland compositor registration, session targets, and graphical environment management. | [`uwsm`](docs/implementations/uwsm.md) | [More →](docs/contracts/wayland.md) |

</details>

<details>
<summary><h3>Implementations</h3></summary>

Concrete contract providers declared via `options.implementation` in [`primitives/implementation.nix`](primitives/implementation.nix). See [Implementations Documentation](docs/IMPLEMENTATIONS.md) for provider assignments.

| Implementation | Description | Contract | Docs |
| :--- | :--- | :--- | :--- |
| [`caddy`](docs/implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [`reverse-proxy`](docs/contracts/reverse-proxy.md) | [More →](docs/implementations/caddy.md) |
| [`cgroups`](docs/implementations/cgroups.md) | Systemd control groups slice hierarchy and resource quotas implementation. | [`resources`](docs/contracts/resources.md) | [More →](docs/implementations/cgroups.md) |
| [`hjem`](docs/implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [`home`](docs/contracts/home.md) | [More →](docs/implementations/hjem.md) |
| [`impermanence`](docs/implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [`persistence`](docs/contracts/persistence.md) | [More →](docs/implementations/impermanence.md) |
| [`lw`](docs/implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [`default-user`](docs/contracts/default-user.md) | [More →](docs/implementations/lw.md) |
| [`restic`](docs/implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [`backup`](docs/contracts/backup.md) | [More →](docs/implementations/restic.md) |
| [`sops`](docs/implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`secrets`](docs/contracts/secrets.md) | [More →](docs/implementations/sops.md) |
| [`uwsm`](docs/implementations/uwsm.md) | Universal Wayland Session Manager integration for desktop environments. | [`wayland`](docs/contracts/wayland.md) | [More →](docs/implementations/uwsm.md) |

</details>

<details>
<summary><h3>Features</h3></summary>

Reusable system services and applications declared via `options.feature` in [`primitives/feature.nix`](primitives/feature.nix). See [Features Documentation](docs/FEATURES.md) for exported outputs.

| Feature | Description | Docs |
| :--- | :--- | :--- |
| [`antigravity`](docs/features/antigravity.md) | Google Antigravity IDE, agentic workflow tools, and CLI runtime. | [More →](docs/features/antigravity.md) |
| [`audio`](docs/features/audio.md) | PipeWire sound server and real-time audio processing stack. | [More →](docs/features/audio.md) |
| [`bitwarden`](docs/features/bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [More →](docs/features/bitwarden.md) |
| [`cosmic`](docs/features/cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [More →](docs/features/cosmic.md) |
| [`cursor`](docs/features/cursor.md) | XCursor theme configuration and icon assets. | [More →](docs/features/cursor.md) |
| [`direnv`](docs/features/direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [More →](docs/features/direnv.md) |
| [`disko`](docs/features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [More →](docs/features/disko.md) |
| [`dolphin`](docs/features/dolphin.md) | KDE Dolphin file manager with Wayland integration and isolated runtime plugins. | [More →](docs/features/dolphin.md) |
| [`fonts`](docs/features/fonts.md) | System typography and developer monospace font packages. | [More →](docs/features/fonts.md) |
| [`foot`](docs/features/foot.md) | Fast, lightweight Wayland terminal emulator with server-client architecture. | [More →](docs/features/foot.md) |
| [`git`](docs/features/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [More →](docs/features/git.md) |
| [`greetd`](docs/features/greetd.md) | Lightweight console greeter and graphical session launcher via tuigreet. | [More →](docs/features/greetd.md) |
| [`helium`](docs/features/helium.md) | Helium web browser with custom runtime flags and enterprise policy management. | [More →](docs/features/helium.md) |
| [`labwc`](docs/features/labwc.md) | Labwc stacking Wayland compositor with window manager keybindings and XDG autostart. | [More →](docs/features/labwc.md) |
| [`locale`](docs/features/locale.md) | System internationalization, time zone, and language locale configuration. | [More →](docs/features/locale.md) |
| [`nix`](docs/features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [More →](docs/features/nix.md) |
| [`noctalia`](docs/features/noctalia.md) | Noctalia shell environment, status bar, app launcher, and wallpaper manager. | [More →](docs/features/noctalia.md) |
| [`ssh`](docs/features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [More →](docs/features/ssh.md) |
| [`tack`](docs/features/tack.md) | Flake input pinning and lockfile orchestration tool. | [More →](docs/features/tack.md) |
| [`ttyd`](docs/features/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [More →](docs/features/ttyd.md) |
| [`user`](docs/features/user.md) | Normal user account helper functions and querying utilities. | [More →](docs/features/user.md) |
| [`vaultwarden`](docs/features/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [More →](docs/features/vaultwarden.md) |
| [`vivaldi`](docs/features/vivaldi.md) | Vivaldi web browser with Widevine and proprietary media codecs. | [More →](docs/features/vivaldi.md) |
| [`vscode`](docs/features/vscode.md) | Visual Studio Code editor environment and persistence. | [More →](docs/features/vscode.md) |
| [`wifi-eduroam`](docs/features/wifi-eduroam.md) | Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager. | [More →](docs/features/wifi-eduroam.md) |

</details>

<details>
<summary><h3>Libraries</h3></summary>

Pure reusable helper functions, data types, calculations, and presets declared via `options.lib` in [`primitives/lib.nix`](primitives/lib.nix). See [Library Documentation](docs/LIB.md) for full function signatures and docstrings.

| Library Namespace | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.backup`](docs/lib/backup.md) | Library helpers and constructors for the 'backup' contract. | [More →](docs/lib/backup.md) |
| [`flake.lib.bitwarden`](docs/lib/bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [More →](docs/lib/bitwarden.md) |
| [`flake.lib.default-user`](docs/lib/default-user.md) | Library helpers and constructors for the 'default-user' contract. | [More →](docs/lib/default-user.md) |
| [`flake.lib.disko`](docs/lib/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [More →](docs/lib/disko.md) |
| [`flake.lib.docsMarkdown`](docs/lib/docsMarkdown.md) | Markdown documentation rendering engine for Nixconf architecture. | [More →](docs/lib/docsMarkdown.md) |
| [`flake.lib.docsMermaid`](docs/lib/docsMermaid.md) | Declarative Mermaid flowchart diagram visualizer with custom styling. | [More →](docs/lib/docsMermaid.md) |
| [`flake.lib.docsParser`](docs/lib/docsParser.md) | Pure-Nix RFC 145 docstring parser utilities for functions and library symbols. | [More →](docs/lib/docsParser.md) |
| [`flake.lib.graph`](docs/lib/graph.md) | Canonical Semantic Code Property Graph (CPG) framework, algebraic calculus, and architectural projection functors. | [More →](docs/lib/graph.md) |
| [`flake.lib.home`](docs/lib/home.md) | Library helpers and constructors for the 'home' contract. | [More →](docs/lib/home.md) |
| [`flake.lib.lw`](docs/lib/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](docs/lib/lw.md) |
| [`flake.lib.persistence`](docs/lib/persistence.md) | Library helpers and constructors for the 'persistence' contract. | [More →](docs/lib/persistence.md) |
| [`flake.lib.primitive`](docs/lib/primitive.md) | Primitives framework helper functions, option constructors, and utilities. | [More →](docs/lib/primitive.md) |
| [`flake.lib.resources`](docs/lib/resources.md) | Library helpers and constructors for the 'resources' contract. | [More →](docs/lib/resources.md) |
| [`flake.lib.reverse-proxy`](docs/lib/reverse-proxy.md) | Library helpers and constructors for the 'reverse-proxy' contract. | [More →](docs/lib/reverse-proxy.md) |
| [`flake.lib.secrets`](docs/lib/secrets.md) | Library helpers and constructors for the 'secrets' contract. | [More →](docs/lib/secrets.md) |
| [`flake.lib.sops`](docs/lib/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](docs/lib/sops.md) |
| [`flake.lib.user`](docs/lib/user.md) | Normal user account helper functions and querying utilities. | [More →](docs/lib/user.md) |
| [`flake.lib.wayland`](docs/lib/wayland.md) | Library helpers and constructors for the 'wayland' contract. | [More →](docs/lib/wayland.md) |

</details>

<details>
<summary><h3>Packages</h3></summary>

Executable packages exported on `flake.packages`. See [Packages Documentation](docs/PACKAGES.md) for the full catalog.

#### [`antigravity`](docs/PACKAGES.md#antigravity)
Google Antigravity

```bash
nix run .#antigravity
```

#### [`antigravity-cli`](docs/PACKAGES.md#antigravity-cli)
Google Antigravity CLI - Describe what you need, and Antigravity handles the rest

```bash
nix run .#antigravity-cli
```

#### [`antigravity-ide`](docs/PACKAGES.md#antigravity-ide)
Google Antigravity IDE

```bash
nix run .#antigravity-ide
```

#### [`bw`](docs/PACKAGES.md#bw)
Bitwarden CLI wrapper providing automated server configuration and session management.

```bash
nix run .#bw
```

#### [`diagrams`](docs/PACKAGES.md#diagrams)
Unified documentation generator, validation test runner, and synchronization toolchain.

```bash
nix run .#diagrams
```

#### [`docs`](docs/PACKAGES.md#docs)
Unified documentation generator, validation test runner, and synchronization toolchain.

```bash
nix run .#docs
```

#### [`dolphin`](docs/PACKAGES.md#dolphin)
Dolphin file manager wrapper bundled with QtWayland plugins and breeze theme assets.

```bash
nix run .#dolphin
```

#### [`foot`](docs/PACKAGES.md#foot)
Fast, lightweight and minimalistic Wayland terminal emulator

```bash
nix run .#foot
```

#### [`git`](docs/PACKAGES.md#git)
Distributed version control system

```bash
nix run .#git
```

#### [`nixconf-json`](docs/PACKAGES.md#nixconf-json)
Exported Labeled Property Graph (LPG) representation of repository architecture in JSON format.

```bash
nix run .#nixconf-json
```


</details>

<details>
<summary><h3>DevShells</h3></summary>

Interactive shell environments exported on `flake.devShells`. See [DevShells Documentation](docs/DEVSHELLS.md) for administrative environments.

#### [`github-ssh`](docs/DEVSHELLS.md#github-ssh)
Development shell configured with Bitwarden-authenticated GitHub SSH deploy keys.

```bash
nix develop .#github-ssh
```

#### [`master-ssh`](docs/DEVSHELLS.md#master-ssh)
Administrative development shell configured with Bitwarden-managed master SSH private keys.

```bash
nix develop .#master-ssh
```

#### [`sops-admin`](docs/DEVSHELLS.md#sops-admin)
Administrative secret editing shell with Bitwarden-authenticated master SOPS age key.

```bash
nix develop .#sops-admin
```

#### [`sops-host`](docs/DEVSHELLS.md#sops-host)
Host-level development shell configured to decrypt local host SOPS secrets.

```bash
nix develop .#sops-host
```


</details>

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
