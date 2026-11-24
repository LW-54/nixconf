---
id: EXP-0008
title: Stage 3A.3 Empirical Proof — Heterogeneous Substrate Polymorphism Across VPS, Live-ISO, aarch64 RPi, WSL & Standalone
type: experiment
status: completed
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [experiment, phase-3, stage-3a, substrates, polymorphism, live-iso, aarch64, raspberry-pi, wsl, impermanence, standalone]
assumptions: [A-007, A-013]
summary: Proves ONE 35-line A2+S1 pure-Nix realizer with ZERO platform conditionals (`if wsl` / `if iso` / `if arm`) evaluates 5 radically contrasting substrates on pinned nixpkgs: bare-efi ephemeral-root VPS (auto-wiring [state.*] persistence from agent.toml), real bootable x86_64 Live-ISO, real cross-arch aarch64-linux RPi sdImage, diskless WSL-shaped target, and multi-arch W-Std standalone package.
---

<!-- abstract:start -->
## Executive Abstract

Empirically validates **`A-007`** and **`QA-03`** for **Stage `3A.3`** on `astrolabe` using pinned `nixpkgs`: **one** 35-line `A2+S1` pure-Nix realizer with **zero** platform conditionals inside any service or tool agent cleanly evaluates **5 radically contrasting substrates** sharing the exact same `W-Std` wrapped `git` agent:
1. **`astrolabe` (`bare-efi-ephemeral`, `x86_64-linux`)**: `14.02 s` → `/nix/store/0jwzf8...nixos-system-astrolabe.drv` — **automatically wired** `/var/lib/vaultwarden` → `/persist/var/lib/vaultwarden` strictly from `[state.data]` in `agents/vaultwarden/agent.toml` (`interior.nix` never mentions `impermanence` or `/persist`!).
2. **`live-iso` (`installation-cd-minimal.nix`, `x86_64-linux`)**: `34.89 s` → `/nix/store/y0v3x0...nixos-minimal-26.11pre-git-x86_64-linux.iso.drv`.
3. **`rpi` (`sd-image-aarch64.nix`, `aarch64-linux`)**: `30.87 s` → `/nix/store/20y7fg...nixos-image-sd-card-26.11pre-git-aarch64-linux.img.zst.drv` (native cross-arch evaluation on `x86_64-linux` with zero `binfmt` required!).
4. **`wsl-dev` (diskless/bootloader-less WSL-shaped substrate, `x86_64-linux`)**: `9.78 s` → `/nix/store/j72y6l...nixos-system-wsl-dev.drv` (zero `disko`/`boot.loader`/`impermanence` conflict).
5. **`standalone` (`x86_64-linux` + `aarch64-linux`)**: `2.83 s` → `/nix/store/3kxrlh...aky-git.drv` & `/nix/store/0y4ril...aky-git.drv`.
<!-- abstract:end -->

# EXP-0008: Stage 3A.3 Heterogeneous Substrate Polymorphism Proof

## 1. Test Setup (`astrolabe`, pinned `nixpkgs` `/nix/store/p7yx739q7ips4f9a1a26k509id1kd85i-source`)
- **Zero conditional guards anywhere:** Neither `agents/git/` nor `agents/vaultwarden/` contains any `if wsl`, `if iso`, `if aarch64`, or `impermanence` options.
- **State-As-Promise projection:** The `S1` realizer computes `persistentPaths` directly from `[state.*]` declarations in `*.toml` using the exact Lean-verified `needsLocalPersistence` predicate (`survives-reboot \ (reconstructible ∪ external-owned)`) and passes `persistentPaths` into the chosen Substrate Agent only.

## 2. Empirical Results

| Target Host | Arch | Substrate | Eval Wall Time | Verified Output Derivation |
| :--- | :--- | :--- | ---: | :--- |
| **`astrolabe`** | `x86_64-linux` | `bare-efi-ephemeral` | `14.02 s` | `0jwzf8...nixos-system-astrolabe.drv` (`autoPersisted = true`, `device = "/persist/var/lib/vaultwarden"`) |
| **`live-iso`** | `x86_64-linux` | `live-iso` (`installation-cd-minimal.nix`) | `34.89 s` | `y0v3x0...nixos-minimal-26.11pre-git-x86_64-linux.iso.drv` |
| **`rpi`** | **`aarch64-linux`** | `arm-sbc` (`sd-image-aarch64.nix`) | `30.87 s` | `20y7fg...nixos-image-sd-card-26.11pre-git-aarch64-linux.img.zst.drv` |
| **`wsl-dev`** | `x86_64-linux` | `wsl` (zero bootloader/disko/impermanence) | `9.78 s` | `j72y6l...nixos-system-wsl-dev.drv` |
| **`standalone`** | `x86_64` + `aarch64` | `standalone` (`W-Std` wrapped `git`) | `2.83 s` | `3kxrlh...aky-git.drv` + `0y4ril...aky-git.drv` |

## 3. Structural Takeaways
1. **`A-007` Empirically Validated:** Orthogonal Substrate Agents (`bare-efi`, `arm-sbc`, `wsl`, `live-iso`, `vm-test`, `standalone`) eliminate 100% of cross-target conditional sprawl (`lib.mkIf (!config.wsl.enable)`).
2. **State-As-Promise Decouples Services from `impermanence`:** Service agents declare *what* state they own and its open traits in `agent.toml`; *how* persistence is implemented (`impermanence` vs. native `fileSystems` bind-mounts vs. WSL VHDX) becomes a localized **Two-Way Door** sealed inside the Substrate Agent!
3. **2025–2026 Ecosystem Reality for ARM64 RPi:** `raspberry-pi-nix` / `nixos-raspberrypi` are archived; `NixOS/nixos-hardware` (`raspberry-pi-4` / `raspberry-pi-5`) + upstream `sd-image-aarch64.nix` (U-Boot + `extlinux`) is the actively maintained standard.
