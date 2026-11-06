# Feature: `vaultwarden`

Self-hosted Bitwarden compatible password manager server.

[← Back to Features Documentation](README.md) | [← Back to Main README](../../README.md)

- **Feature**: `vaultwarden`
- **Definition File**: [`modules/features/vaultwarden.nix`](../../modules/features/vaultwarden.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__option__backup_enable[/"backup.enable"/]:::optNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__backup_pruneOpts[/"backup.pruneOpts"/]:::optNode
    urn__nixconf__ast__option__backup_timerConfig[/"backup.timerConfig"/]:::optNode
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_enable[/"persistence.enable"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_enable[/"reverse-proxy.enable"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__type__persistence_entries[["persistence.entries"]]:::typeNode
    urn__nixconf__ast__type__persistence_user[["persistence.user"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_fqdn[["reverse-proxy.fqdn"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_host[["reverse-proxy.host"]]:::typeNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__docker("docker"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode

    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__option__persistence_directories -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|typedBy| urn__nixconf__ast__type__persistence_user
    urn__nixconf__ast__option__reverse_proxy_domain -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_enable
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_paths
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_pruneOpts
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_timerConfig
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__option__backup_enable href "../contracts/backup.md" "backup.enable"
    click urn__nixconf__ast__option__backup_exclude href "../contracts/backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "../contracts/backup.md" "backup.paths"
    click urn__nixconf__ast__option__backup_pruneOpts href "../contracts/backup.md" "backup.pruneOpts"
    click urn__nixconf__ast__option__backup_timerConfig href "../contracts/backup.md" "backup.timerConfig"
    click urn__nixconf__ast__option__persistence_directories href "../contracts/persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_enable href "../contracts/persistence.md" "persistence.enable"
    click urn__nixconf__ast__option__persistence_files href "../contracts/persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "../contracts/persistence.md" "persistence.users"
    click urn__nixconf__ast__option__reverse_proxy_domain href "../contracts/reverse-proxy.md" "reverse-proxy.domain"
    click urn__nixconf__ast__option__reverse_proxy_enable href "../contracts/reverse-proxy.md" "reverse-proxy.enable"
    click urn__nixconf__ast__option__reverse_proxy_hosts href "../contracts/reverse-proxy.md" "reverse-proxy.hosts"
    click urn__nixconf__ast__type__persistence_entries href "../contracts/persistence.md" "persistence.entries"
    click urn__nixconf__ast__type__persistence_user href "../contracts/persistence.md" "persistence.user"
    click urn__nixconf__ast__type__reverse_proxy_fqdn href "../contracts/reverse-proxy.md" "reverse-proxy.fqdn"
    click urn__nixconf__ast__type__reverse_proxy_host href "../contracts/reverse-proxy.md" "reverse-proxy.host"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__feature__antigravity href "antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__bitwarden href "bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__direnv href "direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "disko.md" "disko"
    click urn__nixconf__onto__feature__docker href "docker.md" "docker"
    click urn__nixconf__onto__feature__dolphin href "dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__foot href "foot.md" "foot"
    click urn__nixconf__onto__feature__git href "git.md" "git"
    click urn__nixconf__onto__feature__labwc href "labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ssh href "ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "vscode.md" "vscode"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"

  %% Semantic Visual Classes
  classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
  classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
  classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
  classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
  classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
  classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
  classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
  classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
  classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
  classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
```

</details>

## Outputs

### NixOS Modules

| Module | Description | Docs |
| :--- | :--- | :--- |
| [`vaultwarden`](../modules/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [More →](../modules/vaultwarden.md) |

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

## Consumed Contracts

Capability contracts configured by this feature:

<details>
<summary><code><a href="../contracts/backup.md">backup</a></code></summary>

**Configures options**: `backup.exclude`, `backup.paths`

```nix
# modules/features/vaultwarden.nix
...
44: (self.lib.backup.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../contracts/persistence.md">persistence</a></code></summary>

**Configures options**: `persistence.directories`, `persistence.files`

```nix
# modules/features/vaultwarden.nix
...
43: (self.lib.persistence.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../contracts/reverse-proxy.md">reverse-proxy</a></code></summary>

**Configures options**: `reverse-proxy.hosts`

```nix
# modules/features/vaultwarden.nix
...
33: domain = config.reverse-proxy.domain or null;
...
42: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>
