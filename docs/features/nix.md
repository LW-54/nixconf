# Feature: `nix`

Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.

[← Back to Features Documentation](../FEATURES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Feature Name**: `nix`
- **Description**: Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.
- **Definition File**: [`modules/features/nix.nix`](../../modules/features/nix.nix)

## Architecture Diagram

flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop_features["nixosModule/x240-desktop-features"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_packages["nixosModule/x240-packages"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__module__x240_system_features["nixosModule/x240-system-features"]:::defaultNode
    urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile"/]:::optNode
    urn__nixconf__ast__option__secrets_enable[/"secrets.enable"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__type__secrets_secret[["secrets.secret"]]:::typeNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__audio("audio"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__cosmic("cosmic"):::featureNode
    urn__nixconf__onto__feature__cursor("cursor"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__fonts("fonts"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__greetd("greetd"):::featureNode
    urn__nixconf__onto__feature__helium("helium"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__user("user"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__host["host"]:::defaultNode

    urn__nixconf__ast__module__nix -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -. "writes = "<set>"" .-> urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__nix -. "writes = "<set>"" .-> urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_enable
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_enable
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -. "reads" .-> urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__option__secrets_files -->|"typedBy"| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__secrets -->|"declares"| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets -->|"declares"| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets -->|"declares"| urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets -->|"declares"| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__feature__labwc -. "consumes" .-> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__nix -->|"outputs"| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__wifi_eduroam -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
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
    urn__nixconf__onto__host__x240 -. "consumes" .-> urn__nixconf__onto__contract__wayland
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
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops -->|"outputs"| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm == "implements" ==> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm == "implements" ==> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__audio
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__cosmic
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__helium
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__user
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__primitive__host -->|"contains"| urn__nixconf__onto__host__astrolabe
    urn__nixconf__onto__primitive__host -->|"contains"| urn__nixconf__onto__host__x240


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_desktop_features href "../modules/x240-desktop-features.md" "x240-desktop-features"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_packages href "../modules/x240-packages.md" "x240-packages"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__module__x240_system_features href "../modules/x240-system-features.md" "x240-system-features"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__audio href "../features/audio.md" "audio"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__cosmic href "../features/cosmic.md" "cosmic"
    click urn__nixconf__onto__feature__cursor href "../features/cursor.md" "cursor"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__dolphin href "../features/dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__fonts href "../features/fonts.md" "fonts"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__greetd href "../features/greetd.md" "greetd"
    click urn__nixconf__onto__feature__helium href "../features/helium.md" "helium"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__user href "../features/user.md" "user"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__hjem href "../implementations/hjem.md" "hjem"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"
    click urn__nixconf__onto__implementation__uwsm href "../implementations/uwsm.md" "uwsm"

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


## Outputs

### NixOS Modules

| Module | Description | Details |
| :--- | :--- | :--- |
| [`nix`](../modules/nix.md) | System service module exported by `nix` | [More →](../modules/nix.md) |

### Executable Packages

*No packages exported.*

### Development Shells

*No development shells exported.*

### Library Helpers

*No library symbols exported.*

## Consumed Contracts

Contracts configured by this feature:

<details>
<summary><code><a href="../contracts/secrets.md">secrets</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>

