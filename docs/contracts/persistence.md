# Contract: `persistence`

Declarative state preservation across ephemeral reboots for system and user directories.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `persistence`
- **Definition File**: [`modules/contracts/persistence.nix`](../../modules/contracts/persistence.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__antigravity["nixosModule/antigravity"]:::defaultNode
    urn__nixconf__ast__module__antigravity_cli["nixosModule/antigravity-cli"]:::defaultNode
    urn__nixconf__ast__module__antigravity_ide["nixosModule/antigravity-ide"]:::defaultNode
    urn__nixconf__ast__module__bitwarden_desktop["nixosModule/bitwarden-desktop"]:::defaultNode
    urn__nixconf__ast__module__bw["nixosModule/bw"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__direnv["nixosModule/direnv"]:::defaultNode
    urn__nixconf__ast__module__docker["nixosModule/docker"]:::defaultNode
    urn__nixconf__ast__module__dolphin["nixosModule/dolphin"]:::defaultNode
    urn__nixconf__ast__module__foot["nixosModule/foot"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__labwc["nixosModule/labwc"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__noctalia["nixosModule/noctalia"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__vivaldi["nixosModule/vivaldi"]:::defaultNode
    urn__nixconf__ast__module__vscode["nixosModule/vscode"]:::defaultNode
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_enable[/"persistence.enable"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__type__persistence_entries[["persistence.entries"]]:::typeNode
    urn__nixconf__ast__type__persistence_user[["persistence.user"]]:::typeNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__package__antigravity[("package/antigravity")]:::pkgNode
    urn__nixconf__drv__package__antigravity_cli[("package/antigravity-cli")]:::pkgNode
    urn__nixconf__drv__package__antigravity_ide[("package/antigravity-ide")]:::pkgNode
    urn__nixconf__drv__package__bw[("package/bw")]:::pkgNode
    urn__nixconf__drv__package__dolphin[("package/dolphin")]:::pkgNode
    urn__nixconf__drv__package__foot[("package/foot")]:::pkgNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__docker("docker"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode

    urn__nixconf__ast__module__antigravity -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity -->|dependsOn| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_cli -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity_cli -->|dependsOn| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity_cli -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_ide -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity_ide -->|dependsOn| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity_ide -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_ide -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__antigravity_ide -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__bitwarden_desktop -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__direnv -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__direnv -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__dolphin -->|dependsOn| urn__nixconf__drv__package__dolphin
    urn__nixconf__ast__module__dolphin -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__dolphin -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__foot -->|dependsOn| urn__nixconf__drv__package__foot
    urn__nixconf__ast__module__foot -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__foot -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__labwc -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__labwc -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__noctalia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__noctalia -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vivaldi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vivaldi -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__vscode -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vscode -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__option__persistence_directories -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|typedBy| urn__nixconf__ast__type__persistence_user
    urn__nixconf__drv__devShell__master_ssh -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__antigravity
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__antigravity_cli
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__ast__module__bitwarden_desktop
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__ast__module__bw
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__drv__package__bw
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|outputs| urn__nixconf__ast__module__direnv
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -->|outputs| urn__nixconf__ast__module__docker
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|outputs| urn__nixconf__ast__module__dolphin
    urn__nixconf__onto__feature__dolphin -->|outputs| urn__nixconf__drv__package__dolphin
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|outputs| urn__nixconf__ast__module__foot
    urn__nixconf__onto__feature__foot -->|outputs| urn__nixconf__drv__package__foot
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|outputs| urn__nixconf__ast__module__labwc
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__noctalia -->|outputs| urn__nixconf__ast__module__noctalia
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -->|outputs| urn__nixconf__ast__module__vivaldi
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|outputs| urn__nixconf__ast__module__vscode
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__docker
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user


    click urn__nixconf__ast__module__antigravity href "../modules/antigravity.md" "antigravity"
    click urn__nixconf__ast__module__antigravity_cli href "../modules/antigravity-cli.md" "antigravity-cli"
    click urn__nixconf__ast__module__antigravity_ide href "../modules/antigravity-ide.md" "antigravity-ide"
    click urn__nixconf__ast__module__bitwarden_desktop href "../modules/bitwarden-desktop.md" "bitwarden-desktop"
    click urn__nixconf__ast__module__bw href "../modules/bw.md" "bw"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__direnv href "../modules/direnv.md" "direnv"
    click urn__nixconf__ast__module__docker href "../modules/docker.md" "docker"
    click urn__nixconf__ast__module__dolphin href "../modules/dolphin.md" "dolphin"
    click urn__nixconf__ast__module__foot href "../modules/foot.md" "foot"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__labwc href "../modules/labwc.md" "labwc"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__noctalia href "../modules/noctalia.md" "noctalia"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__vivaldi href "../modules/vivaldi.md" "vivaldi"
    click urn__nixconf__ast__module__vscode href "../modules/vscode.md" "vscode"
    click urn__nixconf__ast__option__persistence_directories href "persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_enable href "persistence.md" "persistence.enable"
    click urn__nixconf__ast__option__persistence_files href "persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "persistence.md" "persistence.users"
    click urn__nixconf__ast__type__persistence_entries href "persistence.md" "persistence.entries"
    click urn__nixconf__ast__type__persistence_user href "persistence.md" "persistence.user"
    click urn__nixconf__drv__devShell__master_ssh href "../devshells.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__package__antigravity href "../packages.md#antigravity" "antigravity"
    click urn__nixconf__drv__package__antigravity_cli href "../packages.md#antigravity-cli" "antigravity-cli"
    click urn__nixconf__drv__package__antigravity_ide href "../packages.md#antigravity-ide" "antigravity-ide"
    click urn__nixconf__drv__package__bw href "../packages.md#bw" "bw"
    click urn__nixconf__drv__package__dolphin href "../packages.md#dolphin" "dolphin"
    click urn__nixconf__drv__package__foot href "../packages.md#foot" "foot"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "home.md" "home"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "wayland.md" "wayland"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__docker href "../features/docker.md" "docker"
    click urn__nixconf__onto__feature__dolphin href "../features/dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"

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
| [`persistence`](../modules/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [More →](../modules/persistence.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`entries`](../lib/persistence.md#entries) | `entries :: Type` | List of directory or file paths to persist, either strings or custom bind-mount attribute sets. | [More →](../lib/persistence.md#entries) |
| [`mkConfig`](../lib/persistence.md#mkConfig) | `persistence.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'persistence' contract. | [More →](../lib/persistence.md#mkConfig) |
| [`mkOption`](../lib/persistence.md#mkOption) | `persistence.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'persistence' contract. | [More →](../lib/persistence.md#mkOption) |

### Custom Types

- `entries`: list of (string or attribute set of anything)
- `user`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `persistence.directories` | `list of (string or attribute set of anything)` | `[ ]` | List of directory paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `persistence.enable` | `boolean` | `true` | Whether to enable declarative filesystem persistence contract mapped to impermanence. |
| `persistence.files` | `list of (string or attribute set of anything)` | `[ ]` | List of individual file paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `persistence.users` | `attribute set of (submodule)` | `{ }` | Per-user persistence declarations keyed by username. `data` and `cache` root names are repository conventions, not upstream impermanence requirements. |

## Fulfilling Implementations

Providers satisfying the `persistence` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [`modules/implementations/impermanence.nix`](../../modules/implementations/impermanence.nix) | [More →](../implementations/impermanence.md) |

## Contract Consumers

Modules and instances configuring options under the `persistence` contract capability:



### Implementations

<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

**Configures options**: `persistence.directories`

```nix
# modules/implementations/caddy.nix
...
36: persistence.directories = lib.mkIf (config.persistence.enable or false) [
...
```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/implementations/lw.nix
...
75: persistence.users.${cfg.username} = {
76: data.directories = [
77: "nixconf"
78: "Documents"
...
```

</details>



### Features

<details>
<summary><code><a href="../features/antigravity.md">antigravity</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/antigravity.nix
...
32: persistence.users = lib.mapAttrs (_: _: {
33: data.directories = [
34: ".antigravity-ide"
35: ".gemini"
...
```

</details>


<details>
<summary><code><a href="../features/bitwarden.md">bitwarden</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/bitwarden.nix
...
132: persistence.users = lib.mapAttrs (_: _: {
133: data.directories = [".config/Bitwarden CLI"];
134: }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
135: };
...
150: persistence.users = lib.mapAttrs (_: _: {
151: data.directories = [".config/Bitwarden"];
152: cache.directories = [".cache/com.bitwarden.desktop"];
153: }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
...
```

</details>


<details>
<summary><code><a href="../features/direnv.md">direnv</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/direnv.nix
...
19: persistence.users = lib.mapAttrs (_: _: {
20: cache.directories = [".cache/direnv"];
21: }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
22: };
...
```

</details>


<details>
<summary><code><a href="../features/docker.md">docker</a></code></summary>

**Configures options**: `persistence.directories`

```nix
# modules/features/docker.nix
...
3: description = "Docker application container engine, socket activation, and state persistence.";
...
21: persistence.directories = ["/var/lib/docker"];
...
```

</details>


<details>
<summary><code><a href="../features/dolphin.md">dolphin</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/dolphin.nix
...
19: persistence.users = lib.mapAttrs (_: _: {
20: data = {
21: directories = [".local/share/dolphin"];
22: files = [".config/dolphinrc"];
...
```

</details>


<details>
<summary><code><a href="../features/foot.md">foot</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/foot.nix
...
79: persistence.users = self.lib.user.forNormalUsers config (_: _: {
80: data.directories = [".config/foot"];
81: });
82: };
...
```

</details>


<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/labwc.nix
...
125: persistence.users = self.lib.user.forNormalUsers config (_: _: {
126: data.directories = [".config/labwc"];
127: });
128: };
...
```

</details>


<details>
<summary><code><a href="../features/noctalia.md">noctalia</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/noctalia.nix
...
169: persistence.users = lib.mapAttrs (_: _: {
170: data.directories = [
171: ".config/noctalia"
172: ".local/state/noctalia"
...
```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

**Configures options**: `persistence.files`

```nix
# modules/features/ssh.nix
...
127: persistence.files = lib.mkIf (config.persistence ? enable && config.persistence.enable) [
...
```

</details>


<details>
<summary><code><a href="../features/uchiyomi.md">uchiyomi</a></code></summary>

**Configures options**: `persistence.directories`, `persistence.files`

```nix
# modules/features/uchiyomi.nix
...
211: (self.lib.persistence.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

**Configures options**: `persistence.directories`, `persistence.files`

```nix
# modules/features/vaultwarden.nix
...
43: (self.lib.persistence.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/vivaldi.md">vivaldi</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/vivaldi.nix
...
23: persistence.users = lib.mapAttrs (_: _: {
24: data.directories = [".config/vivaldi"];
25: cache.directories = [".cache/vivaldi"];
26: }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
...
```

</details>


<details>
<summary><code><a href="../features/vscode.md">vscode</a></code></summary>

**Configures options**: `persistence.users`

```nix
# modules/features/vcode.nix
...
3: description = "Visual Studio Code editor environment and persistence.";
...
18: persistence.users = lib.mapAttrs (_: _: {
19: data.directories = [".config/Code" ".vscode"];
20: }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
21: };
...
```

</details>
