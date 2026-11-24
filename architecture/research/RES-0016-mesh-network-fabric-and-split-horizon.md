---
id: RES-0016
title: Stage 3B.2 Wide-Spectrum Research Dossier — Mesh Network Fabric, NAT Traversal (Eduroam), Exotic Targets & Split-Horizon Ingress (A-006)
type: research
status: active
created: 2026-11-24
updated: 2026-11-24
domain: networking-fleet
tags: [research, stage-3b, mesh, tailscale, headscale, netbird, nebula, wireguard, zerotier, innernet, yggdrasil, eduroam, derp, wsl2, chromebook, impermanence, split-horizon, caddy, magicdns, a-006]
assumptions: [A-006]
summary: Wide-spectrum 2025–2026 survey of 7 mesh/overlay contenders (Tailscale, Headscale 0.29.x, NetBird 0.82, Nebula 1.12, raw WireGuard, ZeroTier 1.16, Innernet/Yggdrasil) evaluated against Eduroam UDP-blocking NAT traversal, 11 GiB astrolabe RAM limits, impermanent root state persistence, WSL2/Chromebook/aarch64-RPi/Live-ISO portability, Headscale upgrade hazards, offline survivability (QA-07), and split-horizon Caddy ingress.
---

<!-- abstract:start -->
## Executive Abstract

Wide-spectrum primary research dossier for **Stage `3B.2`** (validating **`A-006`**). Audits pinned `nixpkgs` mesh versions (`tailscale 1.104.4`, `headscale 0.29.7`, `netbird 0.82.0`, `nebula 1.12.0`, `zerotierone 1.16.0`, `innernet 2.0.0`, `yggdrasil 0.5.15` — zero extra flake inputs needed for any contender!) and 2025–2026 operational reality across all **7 contenders** under our real fleet constraints: **Eduroam restrictive WiFi**, **11 GiB impermanent VPS (`astrolabe`)**, **roaming laptops**, **`aarch64` RPi**, **`NixOS-WSL`**, **Chromebook tablet**, **ephemeral `Live-ISO`**, **offline cold boot (`QA-07`)**, **zero cross-host `/etc` peer-IP coupling (`C2`)**, and **minimal manual labor / AI-agent friendliness (`QA-10`)**.
<!-- abstract:end -->

# `RES-0016`: Stage `3B.2` Mesh Network Fabric & Split-Horizon Ingress (`A-006`)

## 1. Empirical Baseline (Pinned `nixpkgs` & Fleet Constraints)
- **Zero extra flake inputs**: All 7 contenders are natively packaged in pinned `nixpkgs` (`1d06008`): `tailscale 1.104.4`, `headscale 0.29.7`, `netbird 0.82.0`, `nebula 1.12.0`, `zerotierone 1.16.0`, `innernet 2.0.0`, `yggdrasil 0.5.15`.
- **v1 baseline**: Zero mesh VPN currently deployed (only public Caddy reverse proxy on `astrolabe`, plus `secrets/wifi/wifi_eduroam.yaml` proving roaming laptops regularly operate behind restrictive university **Eduroam** firewalls!).
- **Hard architectural requirements**:
  1. **Eduroam / CGNAT survival**: Must punch through symmetric NAT and fall back cleanly to encrypted TCP/443 relay when UDP is blocked.
  2. **Impermanent root (`astrolabe`)**: Must persist identity state via declared `state:persist` (e.g. `/var/lib/tailscale`) so reboots never spawn duplicate phantom nodes.
  3. **Offline boot & graceful degradation (`QA-07`)**: Must never block local boot (`systemd.network.wait-online.enable = false`); existing P2P tunnels must survive temporary control-plane loss; emergency public/LAN SSH (`ADR-0011`) remains independent of the mesh.
  4. **Zero cross-host rebuild coupling (`C2`)**: Peer discovery must happen dynamically via mesh DNS (MagicDNS / split DNS), never by baking volatile peer IPs into static `/etc` closures.
  5. **Exotic form-factor parity (`QA-03`)**: Must work seamlessly across `x86_64` VPS/laptops, `aarch64` RPi, `NixOS-WSL` (inheriting Windows host tailnet OR userspace-networking), Chromebook (Android/ChromeOS + Crostini userspace-networking), and ephemeral `Live-ISO` (`--ephemeral` auto-cleanup).

---

## 2. Full 7-Contender Comparison Matrix (2025–2026)

| Contender | Data Plane & NAT / Eduroam Traversal | RAM on `astrolabe` (Server + Client) | Control Plane & SPOF Risk | Exotic Targets (`WSL2`, `Chromebook`, `RPi`, `ISO`) | Maintenance, Upgrades & AI-Agent GitOps (`D`, `QA-10`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`M-Tailscale`** *(Tailscale SaaS + optional Tailnet Lock + GitOps ACL)* | WireGuard (`wireguard-go`); STUN P2P + **global TCP/443 HTTPS DERP relays** (gold standard on Eduroam!). | **~30–60 MB** client only (**0 MB** server RAM). | Managed SaaS (free tier: **6 users, unlimited devices, 50 tagged servers**, 3 ACL groups). **Survives `astrolabe` death!** Active P2P tunnels survive SaaS outage; optional **Tailnet Lock** prevents rogue node injection. | **Best-in-class**: native NixOS, `aarch64` RPi, WSL2 (inherits Windows Tailscale OR userspace-networking), ChromeOS/Android + Crostini, `Live-ISO` (`--ephemeral`). | **Lowest labor**: GitOps `policy.hujson` via CI (`tailscale/gitops-acl-action`); zero server upgrade babysitting; native `permitCertUid = "caddy"` for `*.ts.net` HTTPS with 0 DNS tokens! |
| **`M-Headscale`** *(Self-hosted `headscale 0.29.7` + embedded DERP on `astrolabe`)* | Same WireGuard + **self-hosted TCP/443 DERP** (great on Eduroam while `astrolabe` is up). | **~100–150 MB** total (~50–100 MB SQLite server + ~40 MB client). | **100% self-hosted**, zero SaaS limits. **SPOF warning**: if `astrolabe` dies, new peer discovery & custom DERP stop across the fleet until `astrolabe` returns (unless a 2nd relay/VPS exists). | Same official Tailscale clients (`--login-server` URL); slightly more mobile/Chromebook setup. | **Real maintenance tax (`D`)**: Headscale `0.25 → 0.29` broke configs/DB schemas repeatedly and **forbids skipping minor versions** (`0.26→0.27→0.28→0.29`) — hazardous under unattended `nixos-unstable` updates! Declarative `policy.hujson` in NixOS (`SIGHUP` reload). |
| **`M-NetBird`** *(Self-hosted `netbird 0.82.0`)* | WireGuard + ICE/STUN + self-hosted TCP/443 Relay. | **~1–2 GiB RAM** minimum (Management + Signal + Relay + Dashboard + OIDC/Zitadel). | 100% self-hosted open source, polished web UI & OIDC. | Good Linux/Windows/Android; native NixOS server module lags upstream Compose releases. | **High RAM & ops overhead** (eats 10–18% of `astrolabe`'s 11 GiB RAM + multi-service DB/OIDC maintenance). |
| **`M-Nebula`** *(Slack `nebula 1.12.0`)* | Custom Noise IX over UDP + Lighthouses/Relays. **Weak on Eduroam**: lacks native TCP/443 HTTPS fallback when UDP is blocked! | **~15–25 MB** (lowest footprint!). | Decentralized offline X.509 cert PKI (zero central runtime state machine). | Native NixOS (`services.nebula`); weaker WSL2/Chromebook UX; **no built-in MagicDNS**. | Manual/scripted CA cert signing, expiration rotation & CRLs; extra DNS stack required. |
| **`M-WireGuard`** *(Raw kernel `networking.wireguard`)* | Kernel WireGuard (UDP only). **Fails Eduroam UDP blocking** & symmetric NAT without manual hub-and-spoke. | **0 MB** userspace RAM. | Zero control plane. | Manual config on every OS/mobile; poor ephemeral ISO/WSL ergonomics. | **Violates `C2`**: baking static peer lists/IPs into `/etc` causes cross-host rebuild coupling on every new host; high manual key/IP labor. |
| **`M-ZeroTier`** (`1.16.0`) | Custom L2/L3 overlay + TCP fallback. | ~30–50 MB. | Proprietary/BSL cloud controller (or self-hosted `ztnet`). | Broad OS support, weaker NixOS/GitOps ecosystem. | Unnecessary L2 broadcast overhead; weaker policy/GitOps/Caddy ecosystem than Tailscale/Headscale. |
| **`M-Innernet` / `M-Yggdrasil`** | Innernet: WireGuard (no TCP/443 relay for Eduroam). Yggdrasil: public IPv6 overlay (no private ACLs). | Low. | Innernet: self-hosted hub. Yggdrasil: public decentralized mesh. | Weak mobile/Chromebook/WSL support. | Not suited as a private zero-trust Eduroam-proof fleet fabric. |

---

## 3. Critical Operational & Security Findings (2025–2026)

1. **Late-2026 Tailscale SSH Privilege-Separation Fix ("Tailworm" / `v1.104.4+` & `headscale 0.29.7+`)**:
   - Our pinned `nixpkgs` ALREADY includes **`tailscale 1.104.4`** and **`headscale 0.29.7`** (containing the privilege-separation fix running forwarded dials/binds as the session user instead of root, plus `TS_SSH_DISABLE_FORWARDING=1` hardening option).
   - **Important**: Even if Tailscale SSH is enabled for daily convenience, our offline emergency SSH key on `sshd` (`ADR-0011`) remains mandatory so mesh/control-plane loss never causes lockout!
2. **Swap-Safety Between `M-Tailscale` and `M-Headscale` (`QA-02`)**:
   - Because **both** use the exact same `tailscaled` client daemon (`services.tailscale`), sealing the mesh behind one atomic Substrate Agent (`mesh-tailscale`) consuming `config:mesh-control-url` (optional; absent → Tailscale SaaS, present → self-hosted Headscale) makes switching from Tailscale SaaS to Headscale (or vice versa) a **near-zero-cost reversible switch**, not a lock-in!
3. **Impermanence & Ephemeral Media**:
   - Long-lived impermanent hosts (`astrolabe`) declare `state:persist` for `/var/lib/tailscale` (`survives-reboot`, `single-auth-writer`, NOT `backup-required` since node identity can be re-enrolled if lost, or backed up for zero-re-enrollment continuity).
   - `Live-ISO` joins ONLY with `--ephemeral` (single-use tag auth key passed at runtime, never baked into ISO!) so dead onboarding sessions auto-vanish without database zombies.
   - All NixOS hosts disable `systemd.network.wait-online.enable = false` and set `TS_DEBUG_FIREWALL_MODE=nftables` (clean native nftables coexistence with NixOS firewall & Caddy).
4. **Tailnet Lock (`TKA`) Trade-off**:
   - Tailnet Lock eliminates blind trust in Tailscale SaaS (cryptographically signing every node key with local signing nodes), at the cost of manually signing every new node (`tailscale lock sign`) and maintaining offline signing-key recovery. Best treated as an **optional hardening toggle** once the fleet stabilizes (since `L3+` SSH keys, `sops-nix` `age` keys, and Cedar policies ALREADY provide end-to-end cryptographic defense-in-depth independent of the mesh!).

---

## 4. Split-Horizon Public vs. Mesh-Only Ingress & Private TLS (`Caddy` + `Partitioned` Routes)

Antikythera's pure raw `Partitioned` routing (`v2/agents/caddy`) maps directly onto dual-horizon ingress with zero core changes:
- **Public horizon (`tags = ["zone:public"]`)**: e.g. `vault.example.org` — served by Caddy on WAN `:443` with standard Let's Encrypt HTTP-01 TLS.
- **Mesh-only horizon (`tags = ["zone:mesh"]`)**: e.g. `grafana`, `attic`, `victoriametrics`, admin UIs — backends bind strictly to `127.0.0.1`; Caddy binds private virtual hosts strictly to the mesh interface / `tailscale0` firewall trust zone (`networking.firewall.trustedInterfaces = ["tailscale0"]`, blocking private ports on WAN!).
- **Two Private TLS Strategies**:
  - **`H-TailnetTLS`**: Uses Tailscale's native `permitCertUid = "caddy"` for automatic valid `*.tailnet.ts.net` HTTPS certs on browser UIs (`grafana`) + direct WireGuard-encrypted HTTP/TCP for machine-to-machine endpoints (`attic`, `victoriametrics`, `ssh-ng://` remote builders). **Zero DNS API keys, zero external registrar coupling.** *(Requires `M-Tailscale` for `*.ts.net` ACME; on `M-Headscale` falls back to HTTP-over-WireGuard or internal CA unless paired with `H-CustomDNS01`.)*
  - **`H-CustomDNS01`**: Uses custom split-horizon subdomains (`grafana.mesh.example.org` via MagicDNS/Headscale `extra_records`) with Caddy **DNS-01 ACME** (1 scoped DNS registrar API token stored in `sops-nix`). Works identically on **both** `M-Tailscale` and `M-Headscale` with pretty custom domains.

---

## 5. Tailscale Pricing v4 (2025–2026) & Tailscale + Headscale Redundancy Analysis

### 5.1 Tailscale Pricing v4 (No Need to Pay for Personal Fleet)
- **Personal Plus was retired** and absorbed directly into **Personal Free (\$0 forever, non-commercial)**:
  - Up to **6 users** (previously 3), **unlimited user-owned devices**, **50 tagged server/router resources**, **3 user ACL groups** (tags themselves are unlimited for host segmentation), **1,000 ephemeral minutes/month**, MagicDNS, Tailscale SSH, Tailnet Lock, GitOps ACLs, and `*.ts.net` HTTPS certs.
- **Standard** (formerly Starter) is **\$8/user/month** (adds commercial rights, 10 user ACL groups, SCIM — unnecessary for a personal fleet). **Premium** is **\$18/user/month**.

### 5.2 Live Dual Tailscale + Headscale vs. Dormant Pre-Wired Exit Hatch
- **Simultaneous dual `tailscaled` daemons on one host**: `tailscaled` natively connects to one control server per daemon. Spawning a second `tailscaled` requires `--netfilter-mode=off`, disjoint IP prefixes, separate sockets, and avoiding MagicDNS `100.100.100.100` conflicts — fragile for NAT/exit/routing features.
- **Standby live Headscale on `astrolabe`**: Forces paying Headscale's sequential minor-version SQLite/config upgrade tax (`0.26→0.27→0.28→0.29`) continuously even when idle.
- **Recommended Redundancy + Exit-Hatch Architecture**:
  1. **Outage redundancy without dual daemons**: Active P2P WireGuard tunnels already survive Tailscale SaaS outages, and direct public/LAN `sshd` + the offline emergency SSH key (`ADR-0011`) guarantees lockout-free emergency access even if Tailscale is completely dead.
  2. **Pre-wired zero-rewrite Headscale exit hatch (`QA-02`)**: `mesh-tailscale` accepts optional `config:mesh-control-url` (absent → Tailscale SaaS; present → self-hosted Headscale), paired with a clean, QEMU-tested **dormant `mesh-headscale-server` agent** ready to enable in one config change if you ever switch to 100% self-hosted.
  3. **Dual SSH**: **Tailscale SSH** (`v1.104.4+`, `TS_SSH_DISABLE_FORWARDING=1`) for zero-key daily convenience + standard key-only **`sshd`** (daily `ed25519` key for LAN/automation/builders + offline emergency break-glass SSH key).
