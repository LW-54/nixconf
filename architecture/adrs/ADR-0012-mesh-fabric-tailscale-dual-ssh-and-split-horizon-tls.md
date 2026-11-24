---
id: ADR-0012
title: Stage 3B.2 — Mesh Network Fabric (Sealed Tailscale, Dual SSH, Split-Horizon Caddy & Tailnet TLS)
type: adr
status: accepted
created: 2026-11-25
updated: 2026-11-25
domain: networking-fleet
tags: [adr, stage-3b, mesh, tailscale, tailscale-ssh, split-horizon, caddy, magicdns, tailnet-tls, nftables, eduroam, impermanence, a-006]
rfd: null
assumptions: [A-006]
supersedes: null
superseded_by: null
summary: Ratifies Stage 3B.2 (A-006): Sealed `mesh-tailscale` atomic Substrate Agent (Tailscale Personal Free $0, v1.104.4+, nftables, persisted `/var/lib/tailscale`, `--ephemeral` on Live-ISO, GitOps `policy.hujson`, optional `config:mesh-control-url` preserving zero-rewrite Headscale swappability without carrying dormant Headscale code), Dual SSH (Tailscale SSH day-to-day + key-only `sshd` with daily & offline break-glass keys), and `H-TailnetTLS` split-horizon ingress (`zone:public` WAN `:443` vs `zone:mesh` `*.ts.net` Caddy auto-certs + WireGuard-encrypted internal endpoints, zero static peer IP baking).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3B.2`** (Mesh Network Fabric, addressing **`A-006`**) based on the 7-contender 2025–2026 survey in [`RES-0016`](../research/RES-0016-mesh-network-fabric-and-split-horizon.md):
1. **Mesh Fabric (`M-Tailscale`)**: Sealed atomic Substrate Agent (`mesh-tailscale`, `tailscale 1.104.4+`, Personal Free \$0 — 6 users, unlimited devices, 50 tagged resources, 0 server RAM on `astrolabe`, global TCP/443 DERP surviving Eduroam UDP blocking, survives `astrolabe` outage, GitOps `policy.hujson` synced by CI). Leaves Headscale completely out (zero unused code / zero sequential DB-upgrade maintenance), while exposing an optional `config:mesh-control-url` promise so migrating to Headscale or another mesh later requires zero consumer edits (`QA-02`).
2. **Exotic Targets, Impermanence & Offline Safety (`QA-03`, `QA-07`, `C2`)**: Persists `/var/lib/tailscale` via declared `state:persist` on impermanent hosts; uses `--ephemeral` runtime join on `Live-ISO`; supports `NixOS-WSL` (Windows host tailnet or userspace-networking) and Chromebook (ChromeOS/Android + Crostini); enforces `TS_DEBUG_FIREWALL_MODE=nftables` and `systemd.network.wait-online.enable = false` (never blocking offline boot); discovers peers purely via MagicDNS hostnames (zero static peer IPs baked into `/etc`).
3. **Dual SSH & Split-Horizon Ingress (`H-TailnetTLS`)**: **Tailscale SSH** (`v1.104.4+` privilege-separated, `TS_SSH_DISABLE_FORWARDING=1` where forwarding isn't needed) for frictionless daily access **plus** key-only **`sshd`** (daily `ed25519` key for LAN/remote builders + offline emergency break-glass key from `ADR-0011`). Caddy consumes `Partitioned` routes split by `zone:public` (WAN `:443` HTTP-01) vs. `zone:mesh` (`tailscale0`-restricted, `permitCertUid = "caddy"` `*.ts.net` auto-HTTPS for browser UIs + direct WireGuard-encrypted transport for machine-to-machine endpoints — 0 DNS API tokens).
<!-- abstract:end -->

# ADR-0012: Mesh Network Fabric, Dual SSH & Split-Horizon Private TLS

## 1. Context & Problem Statement
The Antikythera fleet spans a 24/7 impermanent VPS (`astrolabe`), roaming laptops frequently behind restrictive university **Eduroam** Wi-Fi, an `aarch64` Raspberry Pi, `NixOS-WSL`, a Chromebook tablet, and ephemeral `Live-ISO` onboarding media. [`RES-0016`](../research/RES-0016-mesh-network-fabric-and-split-horizon.md) evaluated 7 mesh contenders (`Tailscale`, `Headscale 0.29`, `NetBird 0.82`, `Nebula 1.12`, raw `WireGuard`, `ZeroTier`, `Innernet`/`Yggdrasil`) on NAT traversal, RAM footprint, SPOF risk, exotic target support, manual labor, and AI-agent GitOps (`QA-10`).

## 2. Decision Outcome

### 2.1 Fork `3B.2a` — Mesh Fabric (`M-Tailscale`, Zero Dormant Headscale Bloat)
- **Tailscale Personal Free (\$0, Pricing v4)**: Covers 6 users, unlimited user-owned devices, 50 tagged resources, 3 user ACL groups (unlimited host tags), 1,000 ephemeral minutes/month, MagicDNS, Tailscale SSH, Tailnet Lock, and GitOps ACLs (`tailscale/gitops-acl-action` over `policy.hujson` in Git).
- **Zero Server RAM & Zero `astrolabe` SPOF**: Uses only ~30–60 MB client RAM on `astrolabe`; if `astrolabe` goes offline, the rest of the fleet (`x240`, `rpi`, `tuf`, `zenbook`, `wsl`, `chromebook`) remains connected; active WireGuard P2P tunnels also survive temporary Tailscale control-plane outages.
- **Eduroam Proof**: Automatic WireGuard STUN P2P + global TCP/443 HTTPS DERP relay fallback handles strict academic/corporate UDP-blocking firewalls cleanly.
- **No Headscale Carried (Clean Swappability Instead)**: Following YAGNI & Priority `D` (Low Maintenance), Headscale is omitted completely (avoiding unused services and sequential minor-version SQLite upgrade tax). `mesh-tailscale` is sealed behind one atomic Substrate Agent taking optional `config:mesh-control-url`, preserving a zero-rewrite path to Headscale or another mesh if ever desired later (`QA-02`).
- **Impermanence, Offline Boot & Exotic Targets**:
  - Impermanent hosts (`astrolabe`) emit `+b state:persist` for `/var/lib/tailscale` (`survives-reboot`, `single-auth-writer`) so node identity survives reboots without duplicate phantom nodes.
  - `Live-ISO` never bakes mesh keys; onboarding uses runtime `--ephemeral` enrollment so finished sessions auto-clean.
  - All NixOS hosts set `systemd.network.wait-online.enable = false` (zero offline boot hangs, `QA-07`) and `TS_DEBUG_FIREWALL_MODE=nftables`.
  - `NixOS-WSL` inherits the Windows Tailnet or runs `interfaceName = "userspace-networking"`; Chromebook runs ChromeOS/Android Tailscale or Crostini userspace-networking; `aarch64` RPi uses native `tailscale`.
  - Peer discovery relies strictly on MagicDNS hostnames — **never** baking volatile `100.64.x.y` IPs into `/etc` closures (`C2` Boundary-First Stratification).

### 2.2 Fork `3B.2b` — Dual SSH & Split-Horizon Ingress (`H-TailnetTLS`)
- **Dual SSH (Zero-Friction Daily + Lockout-Free Break-Glass)**:
  - **Daily**: **Tailscale SSH** (`v1.104.4+` containing the late-2026 privilege-separation fix, with `TS_SSH_DISABLE_FORWARDING=1` unless explicitly needed) governed declaratively in GitOps `policy.hujson`.
  - **Fallback, Automation & Break-Glass**: Key-only **`sshd`** (`PasswordAuthentication = false`, `PermitRootLogin = "no"`) stays active with the daily `ed25519` key (for LAN, remote Nix builders `ssh-ng://`, non-Tailscale tooling) **plus** the offline emergency break-glass SSH key (`ADR-0011`).
- **Split-Horizon Caddy & Firewall (`Partitioned` `AttrExpr` Routes)**:
  - `tags = ["zone:public"]` (e.g., Vaultwarden): served by Caddy on WAN `:443` with standard Let's Encrypt HTTP-01 TLS.
  - `tags = ["zone:mesh"]` (e.g., Grafana, Attic admin/push, VictoriaMetrics): backend services bind strictly to `127.0.0.1`; private Caddy virtual hosts listen strictly on the mesh interface / `tailscale0` trust zone (`networking.firewall.trustedInterfaces = ["tailscale0"]`), completely unreachable from WAN.
- **Private TLS (`H-TailnetTLS`)**:
  - Browser-facing mesh UIs (`grafana`) obtain automatic valid HTTPS certificates via `services.tailscale.permitCertUid = "caddy"` (`*.tailnet.ts.net` — **0 DNS API tokens, 0 GUI clicks**).
  - Machine-to-machine mesh protocols (`attic`, `victoriametrics`, `alloy`, `ssh-ng://` remote builders) run directly over WireGuard encryption with zero extra cert ceremony.

## 3. Requirements Compliance Audit
- **Priority `B > E > D > A > C`**: Survives Eduroam & `astrolabe` outage, zero offline boot hang, 0 server RAM, 0 extra flake inputs, zero Headscale upgrade tax, GitOps `policy.hujson` PR-auditable by `agy` (`QA-10`).
- **Boundary Discipline (`C2`, `QA-02`, `01cf1f3`)**: Zero mesh/Tailscale strings enter `aky-core`; `mesh-tailscale` is one swappable atomic Substrate Agent; MagicDNS preserves zero cross-host static `/etc` rebuild coupling.
- **`A-006` Verification Plan**: Validated on architecture, compatibility, and pinned versions (`RES-0016`); live QEMU VM verification of impermanent `/var/lib/tailscale` persistence + nftables WAN/mesh isolation + `systemd.network.wait-online.enable = false` offline boot scheduled for Phase 4 implementation.

## 4. Links
- Research Dossier: [`RES-0016`](../research/RES-0016-mesh-network-fabric-and-split-horizon.md)
- Companion ADRs: [`ADR-0011`](ADR-0011-trust-plane-sops-cedar-custody-and-pragmatic-capabilities.md), [`ADR-0006`](ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md)
- Next Stage: **Stage `3B.3` — Triadic Autonomous Pull (`C3` + TUF), Multi-Arch Builds, Binary Cache, Security PRs & Git Mirror (`A-008`)**
