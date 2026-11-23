---
id: EXP-0001
title: Proof-of-Concept Benchmark — Declarative Intent + Multi-Instance Provider Algebra in Pure evalModules
type: experiment
status: completed
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [experiment, evalModules, intent, synchronization, multi-provider, topology, benchmark]
assumptions: [A-001, A-002]
rfd: RFD-0001
git_commit: 0bf8571
host: astrolabe
summary: Prototyped a ~120-LOC pure nixpkgs.lib.evalModules Intent+Synchronization multi-provider core across 3 substrates (VPS, VPS test-mock, WSL) + static topology; evaluated cleanly in 175ms with zero recursion and zero workload glue.
---

<!-- abstract:start -->
## Executive Abstract

Tested assumptions `A-001` and `A-002` via an isolated `/tmp/exp-0001` prototype using `nixpkgs.lib.evalModules` directly (zero `primitives/` 3-pass compiler, zero `flake-parts`, zero `import-tree`). Modeled: (1) pure static fleet `topology` (zero cross-host eval coupling), (2) backend-agnostic `intent.workloads` (`attic`, `vaultwarden`), (3) **simultaneous multi-instance capability providers** (`ingress.public = caddy` + `ingress.mesh = tailscale-serve`; `backup.offsite = restic` + `backup.local = btrfs-snapshot`), (4) **zero-edit mock secret swapping** (`secrets.default.driver = "mock"` replacing `"sops"` without any `isTest` branch in workloads), and (5) **substrate portability** (same `attic` workload evaluated on `nixos-vps` with impermanence AND `nixos-wsl` without impermanence/caddy). **Result**: All 3 nodes + topology evaluated cleanly with **zero fixed-point recursion in 0.175s wall time** — validating `A-002` and supporting `A-001`, while uncovering an even cleaner refinement: using **open first-class provider functors** instead of closed driver enums.
<!-- abstract:end -->

# EXP-0001: Declarative Intent + Multi-Instance Provider Algebra Prototype

## 1. Hypothesis & Falsification Criteria
- **Tests Assumptions**: `A-001`, `A-002`
- **Hypothesis**: A minimal (~120 LOC) pure `nixpkgs.lib.evalModules` core implementing **Static Topology + Pure Workload Intent + Named Multi-Instance Capability Providers + Declarative Synchronizations** can eliminate 1:1 implementation lock-in, $O(N \times M)$ service glue, `isTest` conditionals, and cross-host eval coupling without triggering Nix fixed-point infinite recursion.
- **Falsification Criteria**:
  1. Infinite recursion when providers read `config.intent.workloads` and write resolved outputs back into `config.intent.resolved` (or concrete OS options).
  2. Inability to run two ingress providers (`caddy` + `tailscale-serve`) and two backup providers (`restic` + `btrfs-snapshot`) simultaneously on the same host.
  3. Requiring workload edits when switching from `nixos-vps` (impermanence + SOPS) to `nixos-wsl` (no impermanence) or `test` mode (mock secrets).

## 2. Environment & Reproducibility
- **Git Commit**: `0bf8571` (`design/v2`), pinned `nixpkgs` via repo `.tack`
- **Host**: `astrolabe` (`x86_64-linux`, 6 vCPU, 11 GiB RAM, Classic Nix 2.34.9)
- **Isolation Method**: `/tmp/exp-0001/proto.nix` (deleted after run; zero repo files modified)
- **Command**:
  ```bash
  time nix eval --json --file /tmp/exp-0001/proto.nix | jq .
  ```
- **Prototype Structure (~200 LOC total including 3 full test nodes & 2 workloads)**:
  - `topology`: pure static attrset declaring 4 heterogeneous nodes (`astrolabe`, `x240`, `wsl-work`, `rpi-home` `aarch64-linux`) with `arch`, `substrate`, `roles`, `meshHost`.
  - `intentModule` (~55 LOC): typed `intent.workloads.<name>` (`units`, `stateDirs`, `endpoints`, `secrets`, `resources`) + `intent.resolved`.
  - `capabilityModule` (~65 LOC): `capabilities.{ingress,backup,persistence,secrets}` as `attrsOf (submodule ...)` (0..N named instances) projecting declaratively over `config.intent.workloads`.
  - `workloadAttic`, `workloadVaultwarden`: pure intent declarations with zero provider imports, zero `mkOption`/`mkConfig`, zero `isTest`.
  - `evalNode`: passes `{ inherit topology; nodeMeta = topology.nodes.${name}; }` via `specialArgs` to `lib.evalModules` — evaluating one node NEVER evaluates any other node.

## 3. Raw Measurements & Verified Outputs

- **Wall time**: `real 0m0.175s` (`user 0m0.112s`, `sys 0m0.047s`) for all 3 node evaluations + JSON serialization.
- **`astrolabe` (VPS)**:
  - Emitted **4 routes** across **2 simultaneous ingress providers**: `cache.adje.app` & `vault.adje.app` (`caddy` via `public`) AND `cache.astrolabe.tailnet.ts.net` & `vault.astrolabe.tailnet.ts.net` (`tailscale-serve` via `mesh`).
  - Emitted **4 backup jobs** across **2 simultaneous backup providers**: `restic` (`offsite` → `hetzner-box`) AND `btrfs-snapshot` (`local` → `/.snapshots`).
  - Emitted **2 persisted dirs** (`/persist/var/lib/atticd`, `/persist/var/lib/vaultwarden`) + **2 SOPS secret paths** (`/run/secrets/...`) + **2 watched units**.
- **`astrolabeTest` (Mock Secret Swap)**:
  - Swapped ONLY `capabilities.secrets.default.driver = "mock"` (0 workload edits) → both workloads transparently resolved `/run/mock-secrets/attic.rs256` and `/run/mock-secrets/vaultwarden.admin`.
- **`wslWork` (WSL Substrate)**:
  - Reused the **exact same `workloadAttic`** with NO `persistence` and NO `caddy` → `persistedDirs = []`, `backupJobs = []`, `routes = [ cache.wsl-work.tailnet.ts.net via tailscale-serve ]` — zero errors, zero opt-out hacks.

## 4. Analysis, Refinements & Verdict

- **Verdict**: Hypothesis **strongly validated**!
  - `A-002` → **`validated`** (multi-instance capability providers + $O(N+M)$ synchronizations work cleanly in pure `lib.evalModules` with zero recursion in 175ms).
  - `A-001` → **`experimenting`** (pure `evalModules` core validated; still comparing pure-Nix vs hybrid Nix+Rust control-plane boundary in `RFD-0001`).
- **Critical Design Refinement Discovered**:
  - Using a closed `enum` for `driver` (`"caddy" | "tailscale-serve"`) would force editing the central schema whenever adding a new backend (`nginx`, `borg`, `perses`, `vault`).
  - Replacing closed enums with **open first-class provider functors/modules** (e.g., `capabilities.ingress.public = providers.ingress.caddy { ... };`) satisfies the Open-Closed Principle, gives each provider strongly typed native options without lowest-common-denominator leakage, and allows sub-component swapping (`telemetry.collector`, `telemetry.metrics`, `telemetry.logs`, `telemetry.ui`) cleanly.
- **Note for Full NixOS Integration (Follow-up Spike if Accepted)**:
  - Next validation step when moving to implementation will verify zero fixed-point recursion when a real NixOS service module reads `config.intent.resolved.secretPaths.<id>` inside `systemd.services.<name>.serviceConfig.EnvironmentFile` while simultaneously declaring `intent.workloads.<name>.secrets.<id>` (using `lib.mkMerge` and avoiding dynamic attrnames in `users.users`/`systemd.services` derived from `config`).
