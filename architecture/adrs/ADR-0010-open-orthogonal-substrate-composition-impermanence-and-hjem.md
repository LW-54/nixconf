---
id: ADR-0010
title: Stage 3A.3 — Open Arbitrary-Axis Orthogonal Substrate Composition, Sealed Impermanence (I1) & Hjem (H2)
type: adr
status: accepted
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [adr, phase-3, stage-3a, substrates, orthogonality, impermanence, hjem, standalone, aarch64, wsl, live-iso]
assumptions: [A-007, A-013]
supersedes: []
summary: Ratifies Stage 3A.3 completing Cluster A (Structural Kernel): substrates are open, arbitrary-axis orthogonal Atomic Agents (no fixed axis count, no class inheritance) composed via B3 Exclusive promises and P-Dual Transparent Profiles, with nix-community/impermanence sealed inside storage-ephemeral (I1) and feel-co/hjem sealed inside sub-home-hjem for residual $HOME & standalone user files (H2).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies the **Stage `3A.3`** substrate realization architecture (completing **Stage 3A — Structural Kernel**), backed by [`AUD-0004`](../audit/AUD-0004-fleet-and-capability-constraints.md), direct source inspection of `feel-co/hjem`, and [`EXP-0008`](../experiments/EXP-0008-heterogeneous-substrate-polymorphism.md):
1. **Open Arbitrary-Axis Orthogonal Substrate Composition (Zero Fixed Axis Count, Zero Inheritance):**
   - "Substrate" is NOT a fixed template enum, NOT a hardcoded 4-axis schema, and NOT an OO inheritance hierarchy.
   - Any orthogonal machine/environment concern (OS boot/image target, root storage/persistence, declarative partitioning, `$HOME` file linker, display compositor, audio server, power/GPU posture, machine hardware quirks, or any future axis) is modeled as an ordinary Atomic Agent emitting its real promises (`+b` / `-b` / open `traits`).
   - Mutual exclusion along *any* axis (e.g., `+b target:os`, `+b storage:root`) is enforced mechanically by `aky-core`'s existing Lean-verified `B3` `Exclusive` cardinality and `S2+` trait laws. Machine-group reuse uses flat **`P-Dual` Transparent Profiles** (`profiles/*.toml`).
   - Target build formats (`toplevel`, `isoImage`, `sdImage`, `tarballBuilder`, or future `ociImage`/`darwinSystem`) are declared openly on whichever agent provides `+b target:os` (`target_class`, `output_attr`).
2. **Ephemeral-Root Persistence (`I1`):** `nix-community/impermanence` sealed strictly inside the ephemeral-root storage agent, automatically translating `[state.*]` declarations from `*.toml` via `needsLocalPersistence` — service agents never mention `impermanence`.
3. **Residual `$HOME` Management (`H2`):** `feel-co/hjem` (inspected on disk: 1 flake input `nixpkgs`, 2,360-LOC Rust linker `hjem-core`, standalone non-NixOS CLI + NixOS + `nix-darwin` support, clean stale-symlink pruning, systemd user reload, rollbacks) sealed strictly inside `sub-home-hjem` for the ~10% of user configs that cannot be wrapped via `W-Std`, rejecting `home-manager` bloat and `X6` DIY reinvention.
<!-- abstract:end -->

# ADR-0010: Stage `3A.3` — Open Orthogonal Substrates, Sealed `impermanence` (`I1`) & `hjem` (`H2`)

## Status
**Accepted** (2026-11-24 — Stage `3A.3`, completing **Stage 3A: Structural Kernel**; backed by [`EXP-0008`](../experiments/EXP-0008-heterogeneous-substrate-polymorphism.md)).

## Context
Antikythera must support wildly heterogeneous targets (`astrolabe` impermanent VPS, `x240`, ZenBook Duo dual-OLED, TUF hybrid dGPU, Lenovo Chromebook tablet, `aarch64` Raspberry Pi 4/5 via `nixos-hardware` + `sdImage`, `NixOS-WSL`, bootable `Live-ISO`, QEMU test VMs, and `Standalone` non-NixOS `nix run`) without `lib.mkIf (!config.wsl.enable)` spaghetti, combinatorial template explosion, or fragile class inheritance.

## Decisions

### 1. Open Arbitrary-Axis Orthogonal Substrate Composition
- Zero hardcoded substrate categories or fixed axis count in `aky-core` or `lib/realize.nix`.
- Each orthogonal concern is an ordinary Atomic Agent (examples — open to arbitrary additions):
  - **OS / Image Targets (`+b target:os`, `Exclusive`):** `target-nixos-efi`, `target-nixos-rpi` (`nixos-hardware` + U-Boot/`sdImage`), `target-nixos-wsl` (`NixOS-WSL` + `tarballBuilder`), `target-nixos-iso` (`installation-cd-minimal` + `isoImage`), `target-nixos-vm` (QEMU), or future `target-oci` / `target-microvm` / `target-darwin` (or none for pure `Standalone`).
  - **Storage / Persistence (`+b storage:root`, `Exclusive`):** `storage-ephemeral` (`impermanence`), `storage-persistent`, plus composable `storage-disko` (requiring `-b hw:physical-block`).
  - **Machine-Specific Hardware (`ADR-0006` C3):** Private `hw-<host>` agents (`hw-astrolabe`, `hw-x240`, `hw-zenbook-duo`, `hw-tuf-dgpu`, `hw-chromebook`) keeping hardware quirks out of global contracts.
  - **Any Future Axis:** Compositor, audio, kernel hardening, power posture, virtualization, etc. — enforced automatically by `B3` `Exclusive` / `-b` / `S2+` open traits.
- **Group Reuse (`P-Dual`):** Reusable machine-group bundles (e.g., `profiles/laptop-base.toml`, `profiles/vps-edge.toml`) are flat Transparent Profiles — zero inheritance overrides.

### 2. Ephemeral-Root Persistence — `I1` (Sealed `nix-community/impermanence`)
- Service agents declare *only* `[state.<vol>]` paths and open traits in `agent.toml`.
- `nix-community/impermanence` is imported **only** inside `agents/storage-ephemeral/interior.nix`, automatically mapping volumes matching Lean's `needsLocalPersistence` predicate (`survives-reboot \ (reconstructible ∪ external-owned)`) into `environment.persistence`. Remains a localized Two-Way Door.

### 3. Residual `$HOME` & Standalone User Files — `H2` (Sealed `feel-co/hjem`)
- Direct source audit of `feel-co/hjem` confirmed: only 1 flake input (`nixpkgs`), active standalone non-NixOS CLI (`hjem standalone switch/rollback/generations`, satisfying `X4`), NixOS + `nix-darwin` modules, and a 2,360-LOC Rust linker (`hjem-core`) handling stale-symlink pruning, clobber safety, permissions, and systemd user reloads.
- Adopt `feel-co/hjem` sealed inside `agents/sub-home-hjem/` strictly for residual `$HOME` files (~10% of configs that cannot be wrapped as homeless `W-Std` packages), rejecting both `home-manager` bloat and `X6` DIY reinvention.

## Consequences
- **Positive:** Completes the entire **Stage 3A Structural Kernel** (`ADR-0008` + `ADR-0009` + `ADR-0010`) with zero hardcoded platform conditionals, unbounded extensibility to future targets/axes, minimal flake inputs (`nixpkgs`, `crane`, `impermanence`, `hjem`, plus target-specific `disko`/`nixos-wsl`/`nixos-hardware` only as hosts need them), and verified multi-arch polymorphism (`EXP-0008`).
- **Next Gate:** Proceed immediately to the ratified **`W1` Walking Skeleton Gate** (`RES-0014`) before designing Stage `3B`.
