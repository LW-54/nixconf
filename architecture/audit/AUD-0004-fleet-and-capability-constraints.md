---
id: AUD-0004
title: Phase 1 Boundary-Constraint Harvest — Heterogeneous Fleet & Future Capabilities
type: audit
status: active
created: 2026-11-23
updated: 2026-11-23
domain: networking-fleet
tags: [audit, constraints, wsl, aarch64, raspberry-pi, live-iso, hybrid-gpu, tablet, standalone, graceful-degradation]
assumptions: [A-006, A-007, A-008, A-009, A-010, A-013]
summary: Harvests non-negotiable technical boundary constraints from every planned host form factor and capability so Phase 2 core primitives never bake in invalid assumptions.
---

<!-- abstract:start -->
## Executive Abstract

Before designing core primitives in Phase 2, this document harvests the **hard, requirement-level technical boundaries** imposed by `nixconf`'s planned heterogeneous fleet and capabilities (strictly without presupposing tools or layouts). Key architectural constraints discovered: (1) **Host substrate diversity** — `NixOS-WSL` forbids `disko`, bootloaders, and raw block devices; Live USB ISOs are read-only ephemeral squashfs targets; `aarch64` Raspberry Pi introduces cross-arch build/OOM-eval boundaries (`binfmt` vs `pkgsCross` vs remote builders + cache); ZenBook Duo, TUF hybrid-GPU laptop, and Lenovo Chromebook tablet require clean hardware-quirk/power/display/input composition (and possible non-NixOS user-space portability); (2) **Standalone accessibility** — portable apps/CLIs/dev environments must be runnable via `nix run` anywhere without NixOS host coupling; (3) **Graceful degradation** — core local boot/vitality must never block on unreachable mesh peers, remote storage, or builders; and (4) **Resource envelopes** — `astrolabe` VPS (6 vCPU, 11 GiB RAM, 100 GiB root) currently spends ~1.59 GiB RAM on observability vs ~291 MiB on all core edge services combined.
<!-- abstract:end -->

# AUD-0004: Hard Boundary-Constraint Harvest

## 1. Purpose
Prevent Phase 2 (`RFD-0001`–`RFD-0003`) from accidentally baking in hidden single-form-factor assumptions (`x86_64-linux` only, physical GPT disk + `disko` + impermanence always present, bootloader always present, 100% NixOS-only consumption, always-online LAN). Every item below is a **non-negotiable problem constraint**, not a tool choice.

---

## 2. Host Target Boundary Matrix

| Target Class | Concrete Planned Hosts | Arch(s) | Kernel / Bootloader | Disk / Storage Layer | Systemd / Network Lifecycle | Critical Failure / Quirk Boundaries |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Public Edge VPS** | `astrolabe` | `x86_64-linux` | Own kernel + GRUB/EFI | Virtual block device (`/dev/sda`), supports partitioning + impermanence | Full systemd, static public IP, 24/7 uptime | Must never break SSH/ingress on update; bounded RAM (11 GiB + zram) & disk (100 GiB). |
| **Standard Laptop** | `x240` | `x86_64-linux` | Own kernel + UEFI | Physical NVMe/SATA, LUKS/Btrfs/impermanence optional | Full systemd, roaming Wi-Fi, suspend/resume, battery | Must boot/work offline; power-aware throttling; intermittent mesh peer. |
| **Dual-Screen Workstation** | Asus ZenBook Duo | `x86_64-linux` | Own kernel + UEFI + panel quirks | Physical NVMe | Full systemd, Wayland multi-monitor + touch | OLED PSR/CABC flicker kernel params (`i915.enable_psr=0`), dual-touch coordinate mapping, detachable keyboard, `asus-wmi` / fan profiles. |
| **Hybrid-GPU Laptop** | Older TUF Gaming Laptop | `x86_64-linux` | Own kernel + UEFI + proprietary/open GPU driver | Physical NVMe/SATA | Full systemd, AC/battery power states | Intel/AMD iGPU + NVIDIA Optimus PRIME (`offload` vs `sync`), `switcheroo-control`, resume stability; strong opportunistic AC-powered remote builder candidate. |
| **Chromebook / Tablet** | Lenovo Chromebook Tablet | `x86_64` or `aarch64` *(verify exact SKU)* | Coreboot/MrChromebox UEFI **or** ChromeOS Linux container (Crostini) | Constrained eMMC / container rootfs | Either bare-metal NixOS (DTB/SOF audio/IIO rotation/OSK) **or** standalone Nix user-space on non-NixOS | Potential ARM DTB/firmware/audio/touch/OSK constraints; strong driver for standalone `nix run`/user-space portability if bare-metal NixOS is impractical. |
| **ARM64 SBC / Home Node** | Raspberry Pi | **`aarch64-linux`** | Board-specific kernel / firmware / U-Boot or RPi firmware | SD card or NVMe (`sdImage` or `disko`) | Full systemd, 24/7 LAN/NAT (behind home router) | **Cross-arch boundary**: evaluating a huge flake *on* a low-RAM Pi can OOM; building natively on x86_64 via `binfmt` is slow for kernels while `pkgsCross` breaks many packages → binary cache + remote/CI builds are essential. |
| **Windows Subsystem for Linux** | WSL (`NixOS-WSL`) | `x86_64-linux` | **Windows-supplied kernel; NO bootloader** | **Windows-managed `.vhdx`; NO `disko`, NO raw block devices, NO `hardware-configuration.nix`** | Systemd works (WSL2 ≥0.67.6), but limited cgroup/hardware hooks; Hyper-V NAT or mirrored networking; Windows VPN/DNS interop | Provisioned via `tarballBuilder` + `wsl --import`; host primitives MUST NOT require disk/bootloader/kernel modules. |
| **Live USB / Rescue & Installer Media** | Live USB / Installer ISO | `x86_64-linux` (+ optional `aarch64`) | ISO / live kernel + squashfs | **Read-only squashfs + tmpfs overlay** (ephemeral!) | Full systemd, dynamic DHCP/Wi-Fi, rescue & provisioning tooling | No persistent host secrets baked into public ISO; must embed or cleanly fetch installer tooling (`disko`, `nixos-anywhere`/local install, recovery tools). |
| **Standalone Non-NixOS Consumers** | Any Linux / macOS / CI / friend's machine | `x86_64-linux`, `aarch64-linux`, *(macOS optional)* | External OS | External | No NixOS module system at runtime | Tools, wrapped applications, devShells, and user utilities MUST be directly runnable via `nix run` / `nix shell` with zero NixOS host coupling. |

### Key Structural Implications for Phase 2 Core Primitives (`RFD-0001`)
1. **Substrate Stratification**: A host is **NOT** a single monolithic NixOS-bare-metal template. Fundamental layers must be cleanly separable:
   - *Layer A — Portable Artifacts*: Packages, wrapped apps, CLIs, devShells, schemas, verification tools (usable anywhere via `nix run`, zero OS coupling).
   - *Layer B — User Environment*: Shells, editors, git, terminal, agent config (usable on NixOS, WSL, Live ISO, and ideally standalone/non-NixOS).
   - *Layer C — OS Capabilities*: Services, networking, mesh, observability, security, auth (systemd-level, independent of disk/boot/arch).
   - *Layer D — Machine Target / Substrate*: Bare-metal UEFI (`disko`/impermanence), VPS, WSL (`NixOS-WSL` tarball), Live ISO (`isoImage`), ARM64 SBC (`sdImage`/RPi firmware), hardware quirks (hybrid GPU, dual OLED, tablet sensors).
2. **Multi-Architecture Native**: `systems` cannot assume `x86_64-linux`; cross-arch evaluation & build graphs (`x86_64-linux`, `aarch64-linux`) must avoid forcing foreign arch builds on unrelated checks.
3. **Provisioning Duality**: Fleet onboarding naturally splits into two complementary paths:
   - **Remote / VPS / Rescue SSH**: `nixos-anywhere` + declarative disk layout + post-boot secret/mesh enrollment.
   - **Physical / Air-Gapped / Bare Metal**: Custom Live USB Installer ISO (+ SD image builder for RPi + tarball builder for WSL).

---

## 3. Cross-Cutting Capability Boundary Constraints

### 3.1 Mesh Networking (Tailscale & Alternatives — `RFD-0004`)
- Must handle **NAT traversal** cleanly (home Raspberry Pi & roaming laptops behind CGNAT/university Wi-Fi reaching `astrolabe` and each other).
- Must coexist cleanly with **public ingress** (reverse proxy on `astrolabe`), **WSL networking** (Windows host VPN bridge vs in-WSL daemon), **impermanent root** (persisting node identity/state cleanly across reboots without re-authenticating every boot), and **offline boot** (never blocking `multi-user.target` if internet is down).
- Must clearly separate **control-plane trust** (managed SaaS coordination like Tailscale vs self-hosted Headscale/NetBird/Nebula) and **DNS split-horizon** (private mesh hostnames vs public domain).

### 3.2 Source of Truth, GitOps & Automated Updates (`RFD-0005`)
- **Trust & Workflow Separation**: AI agents and automated update bots (e.g., daily/weekly input updates for Vaultwarden & security-critical services) should propose changes via **Pull Requests** gated by CI, rather than mutating production hosts directly without verification.
- **Convergence & Rollback**: Hosts tracking `main` must update atomically, verify post-switch health, roll back automatically (or fail safe without losing SSH/mesh) if broken, and tolerate intermittent connectivity (laptops/WSL catch up cleanly when online, never interrupting battery/work abruptly).
- **Resilience / Mirroring**: GitHub as primary collaboration UX, with automated repository backup / optional self-hosted mirror so a GitHub outage or account lockout never locks out fleet recovery.

### 3.3 Distributed Storage & Compute (`RFD-0006`)
- **Asymmetric, Intermittent Topology**: Only `astrolabe` (VPS, limited 100 GiB disk / 11 GiB RAM) and potentially a home Raspberry Pi (low CPU, expandable local storage) are always-on. High-CPU nodes (TUF laptop, ZenBook Duo, `x240`) are **intermittent, mobile, and battery-powered**.
- **Hard Constraint (Graceful Degradation)**: Any distributed storage or compute mechanism MUST tolerate abrupt peer disappearance without blocking local mounts/boots, causing quorum loss (split-brain), or corrupting state.

### 3.4 Deep Observability & Autonomous Analysis (`RFD-0007`)
- **Empirical Live Baseline on `astrolabe` (measured 2026-11-23)**:
  - Host: `6 vCPU`, `11 GiB RAM` (`3.9 GiB` used, `7.5 GiB` available) + `5.7 GiB` zram swap (`920 MiB` used); `/nix` = `45G / 100G` (`/nix/store` = `26G`).
  - Current observability stack RSS: `grafana` (513 MiB) + `alloy` (458 MiB) + `victoriametrics` (436 MiB) + `victorialogs` (83 MiB) + `alertmanager` (48 MiB) + `vmalert-metrics` (32 MiB) + `vmalert-logs` (16 MiB) = **~1.59 GiB RAM** (~14.4% of VPS RAM) vs **~291 MiB** for all core edge/auth/app services combined (`caddy` 87M, `vaultwarden` 52M, `ntfy` 52M, `authelia` 36M, `ttyd` 34M, `copyparty` 12M, `sshd` 11M, `lldap` 7M).
  - Current observability disk: `victoriametrics` `312 MiB` / 25G volume; `victorialogs` `21 MiB` / 15G volume; `alloy` `378 MiB`.
- **Hard Constraint**: Any richer telemetry (traces, continuous profiling/eBPF, higher-resolution events, multi-host ingestion over mesh) MUST stay comfortably within a ~2–3 GiB RAM ceiling on `astrolabe` and bounded disk retention, AND expose clean machine-queryable APIs for a periodic autonomous diagnostic/upgrade agent.

### 3.5 Knowledge, Documentation & AI Ergonomics (`RFD-0008`)
- Must enforce coverage **uniformly across the entire repository** (zero un-enforced blind spots like current tooling/automation layers).
- Must respect the **AI-behind-human-UX** boundary: clean, navigable documentation for humans, plus low-token, deterministic, structured context/query surfaces for AI agents (without bloating every Git commit with churn if avoidable).

---

## 4. Sources Consulted (2026-11-23)
- `nix-community/NixOS-WSL` architecture & flake tarball docs (2025–2026)
- NixOS `aarch64-linux` / Raspberry Pi `binfmt` vs `pkgsCross` vs binary-cache workflows (2025–2026)
- `nixos-anywhere`, `disko`, and NixOS custom installer ISO fleet provisioning practices (2025–2026)
- NixOS hardware quirk documentation: ASUS ZenBook Duo OLED PSR/touch, NVIDIA Optimus PRIME (`offload`/`sync`/`switcheroo-control`), Lenovo Chromebook MrChromebox/ARM DTB/SOF audio/IIO tablet sensors
- Live `astrolabe` runtime telemetry (`systemctl show`, `free -h`, `df -h`, `du -sh`, 2026-11-23)
