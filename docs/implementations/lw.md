# Implementation: `lw`

Primary human user account orchestration and identity provisioning.

[← Back to Implementations Documentation](../IMPLEMENTATIONS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Provider Name**: `lw`
- **Contract Satisfied**: [`default-user`](../contracts/default-user.md)
- **Contract Description**: Default primary user account identification, credentials, and configuration injection.
- **Source File**: [`modules/implementations/lw.nix`](../../modules/implementations/lw.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__astrolabe["astrolabe"]:::hostNode
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__default_user(["default-user"]):::contractNode
        urn__nixconf__onto__contract__home(["home"]):::contractNode
        urn__nixconf__onto__contract__persistence(["persistence"]):::contractNode
        urn__nixconf__onto__contract__reverse_proxy(["reverse-proxy"]):::contractNode
        urn__nixconf__onto__contract__secrets(["secrets"]):::contractNode
        urn__nixconf__onto__contract__wayland(["wayland"]):::contractNode
    end

    subgraph Features["Features"]
        urn__nixconf__onto__feature__antigravity["antigravity"]:::featureNode
        urn__nixconf__onto__feature__audio["audio"]:::featureNode
        urn__nixconf__onto__feature__bitwarden["bitwarden"]:::featureNode
        urn__nixconf__onto__feature__cursor["cursor"]:::featureNode
        urn__nixconf__onto__feature__direnv["direnv"]:::featureNode
        urn__nixconf__onto__feature__disko["disko"]:::featureNode
        urn__nixconf__onto__feature__dolphin["dolphin"]:::featureNode
        urn__nixconf__onto__feature__fonts["fonts"]:::featureNode
        urn__nixconf__onto__feature__foot["foot"]:::featureNode
        urn__nixconf__onto__feature__git["git"]:::featureNode
        urn__nixconf__onto__feature__greetd["greetd"]:::featureNode
        urn__nixconf__onto__feature__labwc["labwc"]:::featureNode
        urn__nixconf__onto__feature__locale["locale"]:::featureNode
        urn__nixconf__onto__feature__nix["nix"]:::featureNode
        urn__nixconf__onto__feature__noctalia["noctalia"]:::featureNode
        urn__nixconf__onto__feature__ssh["ssh"]:::featureNode
        urn__nixconf__onto__feature__tack["tack"]:::featureNode
        urn__nixconf__onto__feature__ttyd["ttyd"]:::featureNode
        urn__nixconf__onto__feature__vaultwarden["vaultwarden"]:::featureNode
        urn__nixconf__onto__feature__vivaldi["vivaldi"]:::featureNode
        urn__nixconf__onto__feature__vscode["vscode"]:::featureNode
        urn__nixconf__onto__feature__wifi_eduroam["wifi-eduroam"]:::featureNode
    end

    subgraph ContractTypes["Contract Types"]
        urn__nixconf__ast__type__home_file{{"home.file"}}:::typeNode
        urn__nixconf__ast__type__home_files{{"home.files"}}:::typeNode
        urn__nixconf__ast__type__home_relativeHomePath{{"home.relativeHomePath"}}:::typeNode
        urn__nixconf__ast__type__home_userHome{{"home.userHome"}}:::typeNode
        urn__nixconf__ast__type__home_xdg{{"home.xdg"}}:::typeNode
        urn__nixconf__ast__type__persistence_entries{{"persistence.entries"}}:::typeNode
        urn__nixconf__ast__type__persistence_user{{"persistence.user"}}:::typeNode
        urn__nixconf__ast__type__secrets_secret{{"secrets.secret"}}:::typeNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__ast__module__astrolabe["astrolabe"]
        urn__nixconf__ast__module__astrolabe_disk["astrolabe-disk"]
        urn__nixconf__ast__module__astrolabe_hardware["astrolabe-hardware"]
        urn__nixconf__ast__module__astrolabe_packages["astrolabe-packages"]
        urn__nixconf__ast__module__astrolabe_services["astrolabe-services"]
        urn__nixconf__ast__module__astrolabe_system["astrolabe-system"]
        urn__nixconf__ast__module__hjem["hjem"]
        urn__nixconf__ast__module__impermanence["impermanence"]
        urn__nixconf__ast__module__lw["lw"]
        urn__nixconf__ast__module__sops["sops"]
        urn__nixconf__ast__module__x240["x240"]
        urn__nixconf__ast__module__x240_desktop["x240-desktop"]
        urn__nixconf__ast__module__x240_desktop_features["x240-desktop-features"]
        urn__nixconf__ast__module__x240_disk["x240-disk"]
        urn__nixconf__ast__module__x240_hardware["x240-hardware"]
        urn__nixconf__ast__module__x240_packages["x240-packages"]
        urn__nixconf__ast__module__x240_system["x240-system"]
        urn__nixconf__ast__module__x240_system_features["x240-system-features"]
        urn__nixconf__ast__option__default_user_email[/"default-user.email: string"/]:::optNode
        urn__nixconf__ast__option__default_user_enable[/"default-user.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__default_user_fullName[/"default-user.fullName: null or string"/]:::optNode
        urn__nixconf__ast__option__default_user_githubUsername[/"default-user.githubUsername: string"/]:::optNode
        urn__nixconf__ast__option__default_user_modules[/"default-user.modules: list of module"/]:::optNode
        urn__nixconf__ast__option__default_user_username[/"default-user.username: string"/]:::optNode
        urn__nixconf__ast__option__home_enable[/"home.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__home_shared[/"home.shared: submodule"/]:::optNode
        urn__nixconf__ast__option__home_users[/"home.users: attribute set of (submodule)"/]:::optNode
        urn__nixconf__ast__option__persistence_directories[/"persistence.directories: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_enable[/"persistence.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__persistence_files[/"persistence.files: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_users[/"persistence.users: attribute set of (submodule)"/]:::optNode
        urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile: null or absolute path"/]:::optNode
        urn__nixconf__ast__option__secrets_enable[/"secrets.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__secrets_files[/"secrets.files: attribute set of (submodule)"/]:::optNode
        urn__nixconf__eval__configuration__astrolabe["astrolabe"]
        urn__nixconf__eval__configuration__x240["x240"]
        urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
        urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
        urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__implementation__restic["restic"]:::implNode
        urn__nixconf__onto__implementation__sops["sops"]:::implNode
        urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
        urn__nixconf__onto__primitive__contract["contract"]
        urn__nixconf__onto__primitive__host["host"]
        urn__nixconf__onto__primitive__implementation["implementation"]
    end


    urn__nixconf__ast__module__hjem -.->|"reads"| urn__nixconf__ast__option__home_enable
    urn__nixconf__ast__module__hjem -.->|"reads"| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__hjem -.->|"reads"| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__hjem -->|"writes"| urn__nixconf__ast__option__home_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_enable
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_enable
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_modules
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_modules
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -.->|"reads"| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|"reads"| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__option__home_shared -.->|"typedBy"| urn__nixconf__ast__type__home_userHome
    urn__nixconf__ast__option__home_shared -.->|"typedBy"| urn__nixconf__ast__type__home_xdg
    urn__nixconf__ast__option__home_users -.->|"typedBy"| urn__nixconf__ast__type__home_userHome
    urn__nixconf__ast__option__home_users -.->|"typedBy"| urn__nixconf__ast__type__home_xdg
    urn__nixconf__ast__option__persistence_directories -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|"typedBy"| urn__nixconf__ast__type__persistence_user
    urn__nixconf__ast__option__secrets_files -.->|"typedBy"| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__hjem
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_email
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_enable
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_modules
    urn__nixconf__onto__contract__default_user --- urn__nixconf__ast__option__default_user_username
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__option__home_enable
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__option__home_shared
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__option__home_users
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__type__home_file
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__type__home_files
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__type__home_relativeHomePath
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__type__home_userHome
    urn__nixconf__onto__contract__home --- urn__nixconf__ast__type__home_xdg
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__contract__secrets --- urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets --- urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets --- urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets --- urn__nixconf__ast__type__secrets_secret
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
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__eval__configuration__astrolabe
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
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__eval__configuration__x240
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
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__hjem -->|"outputs"| urn__nixconf__ast__module__hjem
    urn__nixconf__onto__implementation__hjem -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -->|"outputs"| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__restic -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops -->|"outputs"| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__astrolabe
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__x240
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__uwsm

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


## Outputs

### NixOS Modules

| Module Attribute | Description | Docs |
| :--- | :--- | :--- |
| [`lw`](../modules/lw.md) | Provider module satisfying `default-user` contract | [More →](../modules/lw.md) |

### Executable Packages

*No executable packages exported.*

### Development Shells

*No development shells exported.*

### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.lw.email`](../lib/lw.md#email) | Library helper symbol | [More →](../lib/lw.md#email) |
| [`flake.lib.lw.githubUsername`](../lib/lw.md#githubUsername) | Library helper symbol | [More →](../lib/lw.md#githubUsername) |
| [`flake.lib.lw.username`](../lib/lw.md#username) | Library helper symbol | [More →](../lib/lw.md#username) |


## Importing Hosts

Hosts enabling this provider to fulfill the [`default-user`](../contracts/default-user.md) contract:

- [`astrolabe`](../hosts/astrolabe.md) (`x86_64-linux`): Headless VPS Server (adje.app public edge and core services).
- [`x240`](../hosts/x240.md) (`x86_64-linux`): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Consumed Contracts

Contracts configured by this implementation:

<details>
<summary><code><a href="../contracts/default-user.md">default-user</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../contracts/default-user.md">default-user</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../contracts/default-user.md">default-user</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../contracts/home.md">home</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../contracts/persistence.md">persistence</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../contracts/secrets.md">secrets</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>

