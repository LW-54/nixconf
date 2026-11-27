# Contract: `reverse-proxy`

Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `reverse-proxy`
- **Definition File**: [`modules/contracts/reverse-proxy/default.nix`](../../modules/contracts/reverse-proxy/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__agy["nixosModule/agy"]:::defaultNode
    urn__nixconf__ast__module__agy_config["nixosModule/agy-config"]:::defaultNode
    urn__nixconf__ast__module__agy_hub["nixosModule/agy-hub"]:::defaultNode
    urn__nixconf__ast__module__agy_remote_control["nixosModule/agy-remote-control"]:::defaultNode
    urn__nixconf__ast__module__alloy["nixosModule/alloy"]:::defaultNode
    urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_resources["nixosModule/astrolabe-resources"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__attic["nixosModule/attic"]:::defaultNode
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__copyparty["nixosModule/copyparty"]:::defaultNode
    urn__nixconf__ast__module__grafana["nixosModule/grafana"]:::defaultNode
    urn__nixconf__ast__module__ntfy["nixosModule/ntfy"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_enable[/"reverse-proxy.enable"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_forwardAuth[/"reverse-proxy.forwardAuth"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_ports[/"reverse-proxy.ports"/]:::optNode
    urn__nixconf__ast__type__reverse_proxy_forwardAuth[["reverse-proxy.forwardAuth"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_fqdn[["reverse-proxy.fqdn"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_host[["reverse-proxy.host"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_portAllocation[["reverse-proxy.portAllocation"]]:::typeNode
    urn__nixconf__drv__devShell__gemini_api["devShell/gemini-api"]:::devShellNode
    urn__nixconf__drv__package__agent_git_bootstrap[("package/agent-git-bootstrap")]:::pkgNode
    urn__nixconf__drv__package__agy[("package/agy")]:::pkgNode
    urn__nixconf__drv__package__agy_api[("package/agy-api")]:::pkgNode
    urn__nixconf__drv__package__antigravity[("package/antigravity")]:::pkgNode
    urn__nixconf__drv__package__antigravity_ide[("package/antigravity-ide")]:::pkgNode
    urn__nixconf__drv__package__attic_bootstrap[("package/attic-bootstrap")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__onto__contract__auth{{"auth"}}:::contractNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__storage{{"storage"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__attic("attic"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__copyparty("copyparty"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__micro("micro"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ntfy("ntfy"):::featureNode
    urn__nixconf__onto__feature__perf_monitor("perf-monitor"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__alloy["alloy"]:::implNode
    urn__nixconf__onto__implementation__authelia["authelia"]:::implNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__grafana["grafana"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode

    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__astrolabe -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__attic -->|dependsOn| urn__nixconf__drv__package__attic_bootstrap
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__option__reverse_proxy_domain -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__drv__devShell__gemini_api -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy_hub
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__attic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__authelia
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__copyparty
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__grafana
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ntfy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_config
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_hub
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_remote_control
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__devShell__gemini_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__attic -->|outputs| urn__nixconf__ast__module__attic
    urn__nixconf__onto__feature__attic -->|outputs| urn__nixconf__drv__package__attic_bootstrap
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__git -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__locale -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ntfy -->|outputs| urn__nixconf__ast__module__ntfy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__perf_monitor -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__perf_monitor -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -->|outputs| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__attic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__copyparty
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__micro
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ntfy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__perf_monitor
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__snapshot
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__authelia
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__grafana
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__micro
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__alloy
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__alloy -->|outputs| urn__nixconf__ast__module__alloy
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__alloy ==>|implements| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -->|outputs| urn__nixconf__ast__module__authelia
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__authelia ==>|implements| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__cgroups ==>|implements| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -->|outputs| urn__nixconf__ast__module__grafana
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__grafana ==>|implements| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__hjem ==>|implements| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone ==>|implements| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets


    click urn__nixconf__ast__module__agy href "../modules/agy.md" "agy"
    click urn__nixconf__ast__module__agy_config href "../modules/agy-config.md" "agy-config"
    click urn__nixconf__ast__module__agy_hub href "../modules/agy-hub.md" "agy-hub"
    click urn__nixconf__ast__module__agy_remote_control href "../modules/agy-remote-control.md" "agy-remote-control"
    click urn__nixconf__ast__module__alloy href "../modules/alloy.md" "alloy"
    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_resources href "../modules/astrolabe-resources.md" "astrolabe-resources"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__attic href "../modules/attic.md" "attic"
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__copyparty href "../modules/copyparty.md" "copyparty"
    click urn__nixconf__ast__module__grafana href "../modules/grafana.md" "grafana"
    click urn__nixconf__ast__module__ntfy href "../modules/ntfy.md" "ntfy"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__option__reverse_proxy_domain href "reverse-proxy.md" "reverse-proxy.domain"
    click urn__nixconf__ast__option__reverse_proxy_enable href "reverse-proxy.md" "reverse-proxy.enable"
    click urn__nixconf__ast__option__reverse_proxy_forwardAuth href "reverse-proxy.md" "reverse-proxy.forwardAuth"
    click urn__nixconf__ast__option__reverse_proxy_hosts href "reverse-proxy.md" "reverse-proxy.hosts"
    click urn__nixconf__ast__option__reverse_proxy_ports href "reverse-proxy.md" "reverse-proxy.ports"
    click urn__nixconf__ast__type__reverse_proxy_forwardAuth href "reverse-proxy.md" "reverse-proxy.forwardAuth"
    click urn__nixconf__ast__type__reverse_proxy_fqdn href "reverse-proxy.md" "reverse-proxy.fqdn"
    click urn__nixconf__ast__type__reverse_proxy_host href "reverse-proxy.md" "reverse-proxy.host"
    click urn__nixconf__ast__type__reverse_proxy_portAllocation href "reverse-proxy.md" "reverse-proxy.portAllocation"
    click urn__nixconf__drv__devShell__gemini_api href "../devshells.md#gemini-api" "gemini-api"
    click urn__nixconf__drv__package__agent_git_bootstrap href "../packages.md#agent-git-bootstrap" "agent-git-bootstrap"
    click urn__nixconf__drv__package__agy href "../packages.md#agy" "agy"
    click urn__nixconf__drv__package__agy_api href "../packages.md#agy-api" "agy-api"
    click urn__nixconf__drv__package__antigravity href "../packages.md#antigravity" "antigravity"
    click urn__nixconf__drv__package__antigravity_ide href "../packages.md#antigravity-ide" "antigravity-ide"
    click urn__nixconf__drv__package__attic_bootstrap href "../packages.md#attic-bootstrap" "attic-bootstrap"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__contract__auth href "auth.md" "auth"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__home href "home.md" "home"
    click urn__nixconf__onto__contract__monitoring href "monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__contract__storage href "storage.md" "storage"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__attic href "../features/attic.md" "attic"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__copyparty href "../features/copyparty.md" "copyparty"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__micro href "../features/micro.md" "micro"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ntfy href "../features/ntfy.md" "ntfy"
    click urn__nixconf__onto__feature__perf_monitor href "../features/perf-monitor.md" "perf-monitor"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__alloy href "../implementations/alloy.md" "alloy"
    click urn__nixconf__onto__implementation__authelia href "../implementations/authelia.md" "authelia"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__grafana href "../implementations/grafana.md" "grafana"
    click urn__nixconf__onto__implementation__hjem href "../implementations/hjem.md" "hjem"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__rclone href "../implementations/rclone.md" "rclone"
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
| [`reverse-proxy`](../modules/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [More →](../modules/reverse-proxy.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`findPortConflicts`](../lib/reverse-proxy.md#findPortConflicts) | `findPortConflicts :: [PortAllocation] -> [PortConflict]` | Inspect a list of port allocations and return descriptors for any colliding `(protocol, port)` bindings with overlapping addresses. | [More →](../lib/reverse-proxy.md#findPortConflicts) |
| [`mkConfig`](../lib/reverse-proxy.md#mkConfig) | `reverse-proxy.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'reverse-proxy' contract. | [More →](../lib/reverse-proxy.md#mkConfig) |
| [`mkOption`](../lib/reverse-proxy.md#mkOption) | `reverse-proxy.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'reverse-proxy' contract. | [More →](../lib/reverse-proxy.md#mkOption) |
| [`mkPort`](../lib/reverse-proxy.md#mkPort) | `mkPort :: String -> Int` | Deterministically map a service or subdomain identifier to a non-privileged local port in the range `10000..59999`. | [More →](../lib/reverse-proxy.md#mkPort) |

### Custom Types

- `forwardAuth`: submodule
- `fqdn`: Fully qualified domain name
- `host`: submodule
- `portAllocation`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `reverse-proxy.domain` | `null or (Fully qualified domain name)` | *null* | Base root domain name used for virtual host construction. Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`. |
| `reverse-proxy.enable` | `boolean` | `false` | Whether to enable system reverse proxy contract. |
| `reverse-proxy.forwardAuth` | `submodule` | `{ }` | Global forward authentication provider configuration enforced by the reverse proxy for virtual hosts with `forwardAuth = true`. |
| `reverse-proxy.hosts` | `attribute set of (submodule)` | `{ }` | Attribute set of virtual host fully-qualified domain names (FQDN) mapped to upstream backend endpoints and proxy policies. |
| `reverse-proxy.ports` | `list of (submodule)` | `[ ]` | Declarative registry of provisioned service port allocations used to verify non-conflicting local endpoint bindings across the host at evaluation time. |

## Fulfilling Implementations

Providers satisfying the `reverse-proxy` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [`modules/implementations/caddy/default.nix`](../../modules/implementations/caddy/default.nix) | [More →](../implementations/caddy.md) |

## Contract Consumers

Modules and instances configuring options under the `reverse-proxy` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

**Configures options**: `reverse-proxy.domain`

```nix
# modules/hosts/astrolabe/services.nix
...
22: reverse-proxy.domain = "adje.app";
...
```

</details>



### Implementations

<details>
<summary><code><a href="../implementations/alloy.md">alloy</a></code></summary>

**Configures options**: `reverse-proxy.ports`

```nix
config = {
  reverse-proxy.ports = ...;
};
```

</details>


<details>
<summary><code><a href="../implementations/authelia.md">authelia</a></code></summary>

**Configures options**: `reverse-proxy.forwardAuth`, `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/implementations/authelia/default.nix
...
29: metricsPort = self.lib.reverse-proxy.mkPort "authelia-metrics";
...
30: domain = config.reverse-proxy.domain or null;
...
78: (config.reverse-proxy.hosts or {});
...
321: reverse-proxy = {
322: forwardAuth = {
323: enable = true;
324: upstream = "${authConnectHost}:${toString cfg.port}";
...
361: hosts = lib.mkIf ((config.reverse-proxy.enable or false) && domain != null) (
...
496: (config.reverse-proxy.forwardAuth.enable or false)
...
497: && (config.reverse-proxy.forwardAuth.upstream or null) == "${authConnectHost}:${toString cfg.port}";
...
498: message = "`reverse-proxy.forwardAuth` must be enabled and point to Authelia's listener.";
...
503: (authFqdn == null || !(config.reverse-proxy.hosts.${authFqdn}.forwardAuth or false))
...
504: && (lldapFqdn == null || !(config.reverse-proxy.hosts.${lldapFqdn}.forwardAuth or false));
...
540: script = lib.optionalString (config.reverse-proxy.enable or false) (
...
```

</details>


<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

**Configures options**: `reverse-proxy.ports`

```nix
# modules/implementations/caddy/default.nix
...
29: conflicts = self.lib.reverse-proxy.findPortConflicts cfg.ports;
...
80: message = "Reverse proxy forwardAuth is enabled (`reverse-proxy.forwardAuth.enable = true`), but `reverse-proxy.forwardAuth.upstream` is null.";
...
177: reverse-proxy.ports = [
...
```

</details>


<details>
<summary><code><a href="../implementations/grafana.md">grafana</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
config = {
  reverse-proxy.hosts = ...;
  reverse-proxy.ports = ...;
};
```

</details>



### Features

<details>
<summary><code><a href="../features/antigravity.md">antigravity</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
config = {
  reverse-proxy.hosts = ...;
  reverse-proxy.ports = ...;
};
```

</details>


<details>
<summary><code><a href="../features/attic.md">attic</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/attic.nix
...
13: domain = config.reverse-proxy.domain or null;
...
170: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/copyparty.md">copyparty</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/copyparty.nix
...
13: domain = config.reverse-proxy.domain or null;
...
319: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/ntfy.md">ntfy</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/ntfy.nix
...
12: domain = config.reverse-proxy.domain or null;
...
38: default = self.lib.reverse-proxy.mkPort "ntfy-metrics";
...
120: reverse-proxy.ports = [
...
175: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/ttyd.md">ttyd</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/ttyd.nix
...
112: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/uchiyomi.md">uchiyomi</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/uchiyomi.nix
...
24: domain = config.reverse-proxy.domain or null;
...
297: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

**Configures options**: `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/features/vaultwarden.nix
...
46: domain = config.reverse-proxy.domain or null;
...
55: (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
...
```

</details>
