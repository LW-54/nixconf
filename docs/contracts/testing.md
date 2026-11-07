# Contract: `testing`

Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `testing`
- **Definition File**: [`modules/contracts/testing.nix`](../../modules/contracts/testing.nix)

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
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__nixos_test["nixosModule/nixos-test"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop_features["nixosModule/x240-desktop-features"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_packages["nixosModule/x240-packages"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__module__x240_system_features["nixosModule/x240-system-features"]:::defaultNode
    urn__nixconf__ast__option__testing_checks[/"testing.checks"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_hashedPassword[/"testing.credentials.hashedPassword"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_password[/"testing.credentials.password"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshHostPrivateKey[/"testing.credentials.sshHostPrivateKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshHostPublicKey[/"testing.credentials.sshHostPublicKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshPrivateKey[/"testing.credentials.sshPrivateKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshPublicKey[/"testing.credentials.sshPublicKey"/]:::optNode
    urn__nixconf__ast__option__testing_enable[/"testing.enable"/]:::optNode
    urn__nixconf__ast__option__testing_evalChecks[/"testing.evalChecks"/]:::optNode
    urn__nixconf__ast__option__testing_install_enable[/"testing.install.enable"/]:::optNode
    urn__nixconf__ast__option__testing_name[/"testing.name"/]:::optNode
    urn__nixconf__ast__option__testing_vm_allowedFailedUnits[/"testing.vm.allowedFailedUnits"/]:::optNode
    urn__nixconf__ast__option__testing_vm_cores[/"testing.vm.cores"/]:::optNode
    urn__nixconf__ast__option__testing_vm_enable[/"testing.vm.enable"/]:::optNode
    urn__nixconf__ast__option__testing_vm_memorySize[/"testing.vm.memorySize"/]:::optNode
    urn__nixconf__ast__option__testing_vm_sshForwardPort[/"testing.vm.sshForwardPort"/]:::optNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin["devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__sops_host["devShell/sops-host"]:::devShellNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__testing{{"testing"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__audio("audio"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__cursor("cursor"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__docker("docker"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__fonts("fonts"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__greetd("greetd"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__nixos_test["nixos-test"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode

    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__ast__module__impermanence -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__testing_evalChecks
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_checks
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_hashedPassword
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_password
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshHostPrivateKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshHostPublicKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshPrivateKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshPublicKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_evalChecks
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_install_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_name
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_cores
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_memorySize
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_sshForwardPort
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__git -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__locale -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__testing
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
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_disk
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_packages
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__eval__configuration__x240
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__audio
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__docker
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__uwsm
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__hjem ==>|implements| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__nixos_test -->|outputs| urn__nixconf__ast__module__nixos_test
    urn__nixconf__onto__implementation__nixos_test ==>|implements| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_admin
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_host
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm ==>|implements| urn__nixconf__onto__contract__wayland


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__nixos_test href "../modules/nixos-test.md" "nixos-test"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_desktop_features href "../modules/x240-desktop-features.md" "x240-desktop-features"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_packages href "../modules/x240-packages.md" "x240-packages"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__module__x240_system_features href "../modules/x240-system-features.md" "x240-system-features"
    click urn__nixconf__ast__option__testing_checks href "testing.md" "testing.checks"
    click urn__nixconf__ast__option__testing_credentials_hashedPassword href "testing.md" "testing.credentials.hashedPassword"
    click urn__nixconf__ast__option__testing_credentials_password href "testing.md" "testing.credentials.password"
    click urn__nixconf__ast__option__testing_credentials_sshHostPrivateKey href "testing.md" "testing.credentials.sshHostPrivateKey"
    click urn__nixconf__ast__option__testing_credentials_sshHostPublicKey href "testing.md" "testing.credentials.sshHostPublicKey"
    click urn__nixconf__ast__option__testing_credentials_sshPrivateKey href "testing.md" "testing.credentials.sshPrivateKey"
    click urn__nixconf__ast__option__testing_credentials_sshPublicKey href "testing.md" "testing.credentials.sshPublicKey"
    click urn__nixconf__ast__option__testing_enable href "testing.md" "testing.enable"
    click urn__nixconf__ast__option__testing_evalChecks href "testing.md" "testing.evalChecks"
    click urn__nixconf__ast__option__testing_install_enable href "testing.md" "testing.install.enable"
    click urn__nixconf__ast__option__testing_name href "testing.md" "testing.name"
    click urn__nixconf__ast__option__testing_vm_allowedFailedUnits href "testing.md" "testing.vm.allowedFailedUnits"
    click urn__nixconf__ast__option__testing_vm_cores href "testing.md" "testing.vm.cores"
    click urn__nixconf__ast__option__testing_vm_enable href "testing.md" "testing.vm.enable"
    click urn__nixconf__ast__option__testing_vm_memorySize href "testing.md" "testing.vm.memorySize"
    click urn__nixconf__ast__option__testing_vm_sshForwardPort href "testing.md" "testing.vm.sshForwardPort"
    click urn__nixconf__drv__devShell__master_ssh href "../devshells.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../devshells.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__sops_host href "../devshells.md#sops-host" "sops-host"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "home.md" "home"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__contract__testing href "testing.md" "testing"
    click urn__nixconf__onto__contract__wayland href "wayland.md" "wayland"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__audio href "../features/audio.md" "audio"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__cursor href "../features/cursor.md" "cursor"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__docker href "../features/docker.md" "docker"
    click urn__nixconf__onto__feature__dolphin href "../features/dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__fonts href "../features/fonts.md" "fonts"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__greetd href "../features/greetd.md" "greetd"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__hjem href "../implementations/hjem.md" "hjem"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__nixos_test href "../implementations/nixos-test.md" "nixos-test"
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
```

</details>

## Outputs

### NixOS Modules

| Module | Description | Docs |
| :--- | :--- | :--- |
| [`testing`](../modules/testing.md) | Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets. | [More →](../modules/testing.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`failedEvalChecks`](../lib/testing.md#failedEvalChecks) | `failedEvalChecks :: AttrSet -> [{ name, message }]` | Returns the enabled evaluation checks whose assertion does not hold. | [More →](../lib/testing.md#failedEvalChecks) |
| [`mkTestScript`](../lib/testing.md#mkTestScript) | `mkTestScript :: { checks, tier, label ? String } -> String` | Renders selected runtime checks into a NixOS test driver script, one subtest per check. | [More →](../lib/testing.md#mkTestScript) |
| [`mkTtyLogin`](../lib/testing.md#mkTtyLogin) | `mkTtyLogin :: { user, password, tty ? Int } -> String` | Builds a test driver snippet that logs in on a virtual console with a password and verifies the session. | [More →](../lib/testing.md#mkTtyLogin) |
| [`selectChecks`](../lib/testing.md#selectChecks) | `selectChecks :: { checks, tier } -> [AttrSet]` | Selects the enabled runtime checks for a tier, sorted by priority and name. | [More →](../lib/testing.md#selectChecks) |

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `testing.checks` | `attribute set of (submodule)` | `{ }` | Named runtime checks contributed by modules, executed by the NixOS test driver against the booted host. Every host importing a module automatically inherits its checks. |
| `testing.credentials.hashedPassword` | `string` | `"$y$j9T$wLgKY231.8j.ciV2MfEXe1$P0k5j3bCwHgnwW0Ive3w4knrgpiA4TzhCYLAnHvDZ51"` | Crypt(3) hash of `testing.credentials.password`, used as the stand-in for password hash secrets. |
| `testing.credentials.password` | `string` | `"test"` | Plain-text password that test stand-in password hashes resolve to. |
| `testing.credentials.sshHostPrivateKey` | `string` | `"-----BEGIN OPENSSH PRIVATE KEY----- b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW QyNTUxOQAAACAz0F5hFTFS5nhUcmnyjFVoDw5L/P7kQU8JnBA2rWczAwAAAIhWlP99VpT/ fQAAAAtzc2gtZWQyNTUxOQAAACAz0F5hFTFS5nhUcmnyjFVoDw5L/P7kQU8JnBA2rWczAw AAAEDE1rlcMC0s0X3TKVZAOVavZOywwkXw8tO5dLObxaCMEDPQXmEVMVLmeFRyafKMVWgP Dkv8/uRBTwmcEDatZzMDAAAAAAECAwQF -----END OPENSSH PRIVATE KEY-----"` | Private half of the stand-in SSH host key, used as the stand-in for host key secrets. |
| `testing.credentials.sshHostPublicKey` | `string` | `"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPQXmEVMVLmeFRyafKMVWgPDkv8/uRBTwmcEDatZzMD snakeoil"` | Public half of the stand-in SSH host key, used to verify host key provisioning. |
| `testing.credentials.sshPrivateKey` | `string` | `"-----BEGIN EC PRIVATE KEY----- MHcCAQEEIObLW92AqkWunJXowVR2Z5/+yVPBaFHnEedDk5WJxk/BoAoGCCqGSM49 AwEHoUQDQgAEQiVI+I+3gv+17KN0RFLHKh5Vj71vc75eSOkyMsxFxbFsTNEMTLjV uKFxOelIgsiZJXKZNCX0FBmrfpCkKklCcg== -----END EC PRIVATE KEY-----"` | Private half of the test client key, used by remote checks to log in over SSH. |
| `testing.credentials.sshPublicKey` | `string` | `"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEIlSPiPt4L/teyjdERSxyoeVY+9b3O+XkjpMjLMRcWxbEzRDEy41bihcTnpSILImSVymTQl9BQZq36QpCpJQnI= snakeoil"` | Public half of the test client key, used as the stand-in for authorized key secrets. |
| `testing.enable` | `boolean` | `false` | Whether to enable test mode; only set inside generated test variants so modules can swap real secrets and hardware for stand-ins. |
| `testing.evalChecks` | `attribute set of (submodule)` | `{ }` | Named evaluation-time checks over the host configuration. They run in seconds without building anything (`nix flake check --no-build`), and all failures are reported together. |
| `testing.install.enable` | `boolean` | `false` | Whether the `install` tier (partition the real disk layout, install, boot through the real boot loader) is available for this host. Enabled automatically for Disko-managed hosts. |
| `testing.name` | `null or string` | *null* | Flake attribute name of the host under test, injected by the test harness. |
| `testing.vm.allowedFailedUnits` | `list of string` | `[ ]` | Shell-style unit patterns that may legitimately fail inside the isolated test network. |
| `testing.vm.cores` | `positive integer, meaning >0` | `2` | Number of virtual CPU cores given to the host under test. |
| `testing.vm.enable` | `boolean` | `true` | Whether the host can be booted in a virtualised `vm` tier test. |
| `testing.vm.memorySize` | `positive integer, meaning >0` | `2048` | Memory in MiB given to the virtual machine running the host under test. |
| `testing.vm.sshForwardPort` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | `2222` | Host port forwarded to the guest SSH daemon when running the interactive VM. |

## Fulfilling Implementations

Providers satisfying the `testing` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`nixos-test`](../implementations/nixos-test.md) | Host verification through the NixOS test driver: built-in essentials, QEMU VM sizing, and Disko install tests. | [`modules/implementations/nixos-test.nix`](../../modules/implementations/nixos-test.nix) | [More →](../implementations/nixos-test.md) |

## Contract Consumers

Modules and instances configuring options under the `testing` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

**Configures options**: `testing.vm.allowedFailedUnits`

```nix
# modules/hosts/astrolabe.nix
...
38: testing.vm.allowedFailedUnits = [
...
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

**Configures options**: `testing.vm.allowedFailedUnits`

```nix
# modules/hosts/x240.nix
...
58: testing.vm.allowedFailedUnits = [
...
```

</details>



### Implementations

<details>
<summary><code><a href="../implementations/impermanence.md">impermanence</a></code></summary>

**Configures options**: `testing.checks`

```nix
# modules/implementations/impermanence.nix
...
93: testing.checks.persistence = {
94: description = "state under ${systemRoot} survives a reboot${lib.optionalString ephemeralRoot " while the root is wiped"}";
95: tiers = ["install"];
96: # Reboots the machine, so run after the other checks but before `failed-units`.
...
```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

**Configures options**: `testing.checks`

```nix
# modules/implementations/lw.nix
...
69: testing.checks = {
70: default-user-login = {
71: description = "${cfg.username} can log in on a virtual console with a password";
72: script = self.lib.testing.mkTtyLogin {
...
72: script = self.lib.testing.mkTtyLogin {
73: user = cfg.username;
74: inherit (credentials) password;
75: };
...
```

</details>


<details>
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

**Configures options**: `testing.vm.allowedFailedUnits`

```nix
# modules/implementations/restic.nix
...
37: testing.vm.allowedFailedUnits = [
...
```

</details>


<details>
<summary><code><a href="../implementations/sops.md">sops</a></code></summary>

**Configures options**: `testing.evalChecks`

```nix
# modules/implementations/sops.nix
...
169: testMode = config.testing.enable;
...
215: testing.evalChecks.sops-secrets-via-contract = {
216: assertion = lib.all (name: config.secrets.files ? ${name}) (builtins.attrNames cfg.secrets);
217: message = "sops.secrets {${lib.concatStringsSep ", " (lib.filter (n: !(config.secrets.files ? ${n})) (builtins.attrNames cfg.secrets))}} bypass the `secrets` contract, so tests cannot substitute stand-ins for them; declare them via `secrets.files` instead.";
218: };
...
247: testing.checks.secrets-provisioned = {
248: description = "secrets are decrypted with the declared ownership";
249: priority = 100;
250: script = ''
...
```

</details>



### Features

<details>
<summary><code><a href="../features/nix.md">nix</a></code></summary>

**Configures options**: `testing.vm.allowedFailedUnits`

```nix
# modules/features/nix.nix
...
67: testing.vm.allowedFailedUnits = lib.mkIf config.nix.cachixWatchStore ["cachix-watch-store-agent.service"];
...
```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

**Configures options**: `testing.checks`

```nix
# modules/features/ssh.nix
...
96: testing.checks = {
97: ssh-daemon = {
98: description = "sshd listens on port ${port}${lib.optionalString hasHostKeySecret " with the provisioned host key"}";
99: script =
...
```

</details>


<details>
<summary><code><a href="../features/uchiyomi.md">uchiyomi</a></code></summary>

**Configures options**: `testing.vm.allowedFailedUnits`

```nix
# modules/features/uchiyomi.nix
...
104: testing.vm.allowedFailedUnits = [
...
```

</details>
