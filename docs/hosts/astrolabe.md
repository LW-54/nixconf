# Host: `astrolabe`

Headless VPS Server (adje.app public edge and core services).

[← Back to Hosts Documentation](../HOSTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Target Host**: `astrolabe`
- **Description**: Headless VPS Server (adje.app public edge and core services).
- **Architecture**: `x86_64-linux`
- **State Version**: `25.11`
- **Definition File**: [`modules/hosts/astrolabe.nix`](../../modules/hosts/astrolabe.nix)

## Host Architecture Diagram

flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__backup["nixosModule/backup"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__contracts["nixosModule/contracts"]:::defaultNode
    urn__nixconf__ast__module__default_user["nixosModule/default-user"]:::defaultNode
    urn__nixconf__ast__module__disko["nixosModule/disko"]:::defaultNode
    urn__nixconf__ast__module__git["nixosModule/git"]:::defaultNode
    urn__nixconf__ast__module__home["nixosModule/home"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__locale["nixosModule/locale"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__persistence["nixosModule/persistence"]:::defaultNode
    urn__nixconf__ast__module__resources["nixosModule/resources"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__reverse_proxy["nixosModule/reverse-proxy"]:::defaultNode
    urn__nixconf__ast__module__secrets["nixosModule/secrets"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__wayland["nixosModule/wayland"]:::defaultNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_enable[/"reverse-proxy.enable"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__type__reverse_proxy_fqdn[["reverse-proxy.fqdn"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_host[["reverse-proxy.host"]]:::typeNode
    urn__nixconf__drv__devShell__github_ssh>"devShell/github-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__master_ssh>"devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin>"devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__sops_host>"devShell/sops-host"]:::devShellNode
    urn__nixconf__drv__package__git[("package/git")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__host["host"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__astrolabe_services -. "flowsTo = "adje.app"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -. "writes = "adje.app"" .-> urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -. "flowsTo = ["/var/lib/caddy"]" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -. "writes = true" .-> urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__ast__module__git -->|"dependsOn"| urn__nixconf__drv__package__git
    urn__nixconf__ast__module__lw -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -. "flowsTo = ["/etc/ssh/ssh_host_" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -. "flowsTo = ["/etc/ssh/ssh_host_" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ttyd -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -. "writes = "<set>"" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = ["/var/lib/caddy"]" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = ["/etc/ssh/ssh_host_" .-> urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = []" .-> urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = []" .-> urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -. "writes = "<set>"" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__option__reverse_proxy_domain -->|"typedBy"| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__ast__option__reverse_proxy_hosts -->|"typedBy"| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__eval__configuration__astrolabe -->|"dependsOn"| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__backup
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__contracts
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__default_user
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__home
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__persistence
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__resources
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__reverse_proxy
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__secrets
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__wayland
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__onto__feature__disko -->|"outputs"| urn__nixconf__ast__module__disko
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__ast__module__git
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__drv__devShell__github_ssh
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__drv__package__git
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__locale -->|"outputs"| urn__nixconf__ast__module__locale
    urn__nixconf__onto__feature__locale -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -->|"outputs"| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -->|"outputs"| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|"outputs"| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -->|"outputs"| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"outputs"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
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
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__caddy -->|"outputs"| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -->|"outputs"| urn__nixconf__ast__module__cgroups
    urn__nixconf__onto__implementation__cgroups == "implements" ==> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups == "implements" ==> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__impermanence -->|"outputs"| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence == "implements" ==> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence == "implements" ==> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__restic -->|"outputs"| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic == "implements" ==> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic == "implements" ==> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -->|"outputs"| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|"outputs"| urn__nixconf__drv__devShell__sops_admin
    urn__nixconf__onto__implementation__sops -->|"outputs"| urn__nixconf__drv__devShell__sops_host
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__host -->|"contains"| urn__nixconf__onto__host__astrolabe
    urn__nixconf__onto__primitive__host -->|"contains"| urn__nixconf__onto__host__x240
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__sops


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__backup href "../modules/backup.md" "backup"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__contracts href "../modules/contracts.md" "contracts"
    click urn__nixconf__ast__module__default_user href "../modules/default-user.md" "default-user"
    click urn__nixconf__ast__module__disko href "../modules/disko.md" "disko"
    click urn__nixconf__ast__module__git href "../modules/git.md" "git"
    click urn__nixconf__ast__module__home href "../modules/home.md" "home"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__locale href "../modules/locale.md" "locale"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__persistence href "../modules/persistence.md" "persistence"
    click urn__nixconf__ast__module__resources href "../modules/resources.md" "resources"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__reverse_proxy href "../modules/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__ast__module__secrets href "../modules/secrets.md" "secrets"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__wayland href "../modules/wayland.md" "wayland"
    click urn__nixconf__drv__devShell__github_ssh href "../DEVSHELLS.md#github-ssh" "github-ssh"
    click urn__nixconf__drv__devShell__master_ssh href "../DEVSHELLS.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../DEVSHELLS.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__sops_host href "../DEVSHELLS.md#sops-host" "sops-host"
    click urn__nixconf__drv__package__git href "../PACKAGES.md#git" "git"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
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


## Active Contracts

The following contracts are materialized on `astrolabe` through its active implementation providers:

| Contract | Description | Implementation | Description |
| :--- | :--- | :--- | :--- |
| [`reverse-proxy`](../contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. |
| [`resources`](../contracts/resources.md) | System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling. | [`cgroups`](../implementations/cgroups.md) | Systemd control groups slice hierarchy and resource quotas implementation. |
| [`persistence`](../contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. |
| [`default-user`](../contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. |
| [`backup`](../contracts/backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [`restic`](../implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. |
| [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. |

## Enabled Features

The following system and desktop features are imported by `astrolabe`:

| Feature | Description | Outputs |
| :--- | :--- | :--- |
| [`disko`](../features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | disko |
| [`git`](../features/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | git, git |
| [`locale`](../features/locale.md) | System internationalization, time zone, and language locale configuration. | locale |
| [`nix`](../features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | nix |
| [`ssh`](../features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | ssh |
| [`ttyd`](../features/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | ttyd |
| [`vaultwarden`](../features/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | vaultwarden |

## Storage & Filesystem Layout

Evaluated partition table and Btrfs subvolumes generated by Disko:

```text
/dev/sda (GPT)
├── bios (1M)
├── esp (512M, vfat) -> /boot
├── root (100%, lvm_pv)

```

Evaluated persisted directories and state preserved across boots by Impermanence:

```text
/persist
├── system/
  ├── /var/lib/caddy/
  ├── /etc/ssh/ssh_host_ed25519_key
  ├── /etc/ssh/ssh_host_ed25519_key.pub
  ├── /etc/ssh/ssh_host_rsa_key
  ├── /etc/ssh/ssh_host_rsa_key.pub
  └── users/
      └── lw/
      ├── data/
        ├── .gnupg
        ├── .ssh
        ├── Documents
        ├── Downloads
        ├── Projects
        ├── nixconf
```

## Host Submodules

Host-specific configuration submodules partitioning hardware, disks, and local system services:

| Submodule Attribute | Description | Docs |
| :--- | :--- | :--- |
| [`astrolabe-disk`](../modules/astrolabe-disk.md) | Host configuration submodule | [More →](../modules/astrolabe-disk.md) |
| [`astrolabe-hardware`](../modules/astrolabe-hardware.md) | Host configuration submodule | [More →](../modules/astrolabe-hardware.md) |
| [`astrolabe-packages`](../modules/astrolabe-packages.md) | Host configuration submodule | [More →](../modules/astrolabe-packages.md) |
| [`astrolabe-services`](../modules/astrolabe-services.md) | Host configuration submodule | [More →](../modules/astrolabe-services.md) |
| [`astrolabe-system`](../modules/astrolabe-system.md) | Host configuration submodule | [More →](../modules/astrolabe-system.md) |

<details>
<summary><code>astrolabe-disk</code></summary>

```nix
      astrolabe-disk = {...}: {
        imports = [
          self.nixosModules.disko
          self.nixosModules.impermanence
        ];

        config =
          self.lib.disko.mkLayout {
            device = "/dev/sda";
            espSize = "512M";
            biosBootSize = "1M";
          }
          // {
            zramSwap.enable = true;
          };
      };
```

</details>


<details>
<summary><code>astrolabe-hardware</code></summary>

```nix
      astrolabe-hardware = {
        modulesPath,
        lib,
        ...
      }: {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
        ];

        config = {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          boot.loader.grub = {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "/dev/sda";
          };
        };
      };
```

</details>


<details>
<summary><code>astrolabe-packages</code></summary>

```nix
      astrolabe-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          nano
          rsync
          btop
        ];
      };
```

</details>


<details>
<summary><code>astrolabe-services</code></summary>

```nix
      astrolabe-services = {...}: {
        imports = [
          self.nixosModules.caddy
          self.nixosModules.restic
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
        ];

        config = {
          reverse-proxy.domain = "adje.app";
          services.resticBackup.repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
        };
      };
```

</details>


<details>
<summary><code>astrolabe-system</code></summary>

```nix
      astrolabe-system = {
        imports = [
          self.nixosModules.contracts
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.cgroups
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];

        config = {
          networking.hostName = "astrolabe";
          system.stateVersion = "25.11";
        };
      };
```

</details>




## Installation

### Track 1: Remote Automated Provisioning via `nixos-anywhere`

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#astrolabe \
  --copy-secret /path/to/key.txt /persist/var/lib/sops-nix/key.txt \
  root@<TARGET-IP>
```

### Track 2: Local Installation from Live ISO

```bash
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake .#astrolabe

nixos-install --flake .#astrolabe --no-root-passwd
```

### Track 3: Routine Maintenance & Activation

```bash
# Local rebuild
sudo nixos-rebuild switch --flake .#astrolabe

# Remote rebuild over SSH
nixos-rebuild switch --flake .#astrolabe --target-host root@<TARGET-IP>
```
