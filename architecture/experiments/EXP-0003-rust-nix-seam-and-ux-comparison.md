---
id: EXP-0003
title: Benchmark & UX Analysis — Four Rust↔Nix Seam Models (M1 Pure Nix, M2 Thin Shared TOML, M3 Wide Shared TOML, M4 Compiled Rust IR)
type: experiment
status: completed
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [experiment, rust-nix-seam, toml, builtins-fromTOML, p5-handlers, commutative-maps, ux, benchmark]
assumptions: [A-001, A-002, A-005]
rfd: RFD-0001
git_commit: db642b8
host: astrolabe
summary: Benchmarked four Rust↔Nix authoring seams (M1–M4) and verified commutative P5 handlers with pure zero-IFD builtins.fromTOML (264ms Nix eval, 4ms Rust static validation vs 556ms Rust recompile).
---

<!-- abstract:start -->
## Executive Abstract

Empirically tested and compared four concrete realizations of the P4/P5 Rust↔Nix boundary: **M1** (Pure Nix P5, Rust reads exported JSON), **M2** (Thin Shared Data Seam: `fleet.toml` for static S0 Topology natively read by both Rust in **4 ms** and Nix via pure zero-IFD `builtins.fromTOML`, while S1–S3 Workloads/Handlers stay in Nix), **M3** (Wide Shared Data Seam: both S0 Topology and S1 Workload Intents in TOML), and **M4** (Compiled Rust IR `.rs` → JSON → Nix). **Measured results**: (1) Commutative keyed maps in P5 completely eliminated `EXP-0002`'s list-order bug (importing `tailscale` before `caddy` still deterministically resolved `urls.public = https://cache.adje.app/` and `urls.mesh = https://cache.astrolabe.tailnet.ts.net/`, plus concurrent `grafana` + `perses` UI sub-components in **264 ms**); (2) Prebuilt Rust validation over shared TOML ran in **4 ms** with zero recompilation on config edits vs **556 ms** even for a tiny zero-dep Rust recompile in M4; (3) UX analysis exposed a sharp **Split-File Tax** in M3/M4 (splitting every service across two languages and blocking dynamic Nix expressions in intents), positioning **M2** (Thin Shared TOML for S0 Fleet Topology + Native Nix P5 for S1–S3) vs **M1** (Pure Nix P5) as the true Pareto front.
<!-- abstract:end -->

# EXP-0003: Rust↔Nix Seam Benchmarks & Commutative P5 Verification

## 1. Hypotheses Tested
1. Does replacing `listOf str` with commutative keyed maps (`attrsOf (attrsOf str)`) in P5 handlers eliminate module-import-order non-determinism across simultaneous providers (`tailscale` imported before `caddy`) and simultaneous sub-components (`grafana` + `perses`)?
2. Can Nix ingest shared pure-data TOML cleanly with **zero IFD** via `builtins.fromTOML` while Rust validates the exact same TOML file via a prebuilt binary in single-digit milliseconds (eliminating M4's recompile + codegen-drift penalty)?
3. What is the real-world editing UX difference between **M1** (all Nix), **M2** (`fleet.toml` for S0 Topology only + Nix P5), **M3** (`fleet.toml` + `workloads.toml` + Nix P5), and **M4** (compiled `.rs` IR → JSON → Nix)?

## 2. Environment & Setup
- **Git Commit**: `db642b8` (`design/v2`)
- **Host**: `astrolabe` (`x86_64-linux`, Classic Nix 2.34.9, `rustc 1.95.0`, `gcc 15.3.0`)
- **Isolation**: `/tmp/exp-0003/` (cleaned up after benchmark).

## 3. Raw Empirical Measurements

| Benchmark | Measured Wall Time | Key Observations |
| :--- | ---: | :--- |
| **Bench 1 — Nix `builtins.fromTOML` + Commutative P5 Handlers** (`astrolabe` dual-ingress + dual-UI `grafana`&`perses` + `wsl-work`) | **0.264s** (`0.095s` user) | 100% pure, zero IFD. Importing `tailscale` BEFORE `caddy` still produced exact deterministic `urls."attic.http".public = "https://cache.adje.app/"` and `.mesh = "https://cache.astrolabe.tailnet.ts.net/"`. Concurrent `grafana` (3000) + `perses` (8081) resolved cleanly. |
| **Bench 2 — M4 Rust Recompile Cost** (minimal 35-LOC zero-dep `.rs`, `opt-level=0`) | **0.556s** (`0.379s` user) | Paid on **every** config edit in M4 (real Cargo crate with `serde` is ~2–8s incremental), PLUS requires either IFD (hurts flake purity/parallelism) or committing generated JSON files. |
| **Bench 3 — M2/M3 Prebuilt Rust Validator over Shared TOML** | **0.004s** (4 ms!) | Zero recompile on config edits; zero IFD; zero generated-file drift; directly supports `schemars` JSON Schema for live IDE autocomplete (`taplo` in Zed/VS Code). |

## 4. Comparative Seam Analysis (M1 vs M2 vs M3 vs M4)

| Dimension | M1: Pure Nix P5 (Rust reads Nix JSON export) | M2: Thin Shared Seam (`fleet.toml` for S0 Topology; Nix P5 for S1–S3) | M3: Wide Shared Seam (`fleet.toml` + `workloads.toml`; Nix for S2–S3) | M4: Compiled Rust IR (`.rs` → JSON → Nix) |
| :--- | :--- | :--- | :--- | :--- |
| **Files edited to add 1 service** | **1** (`workloads/foo.nix`) | **1** (`workloads/foo.nix`) | **2** (`foo.toml` + `foo.nix` — split-file tax!) | **2** (`foo.rs` + `foo.nix` + regen JSON) |
| **Files edited to add 1 host** | 2 (`topology.nix` + `hosts/x.nix`) | 2 (`fleet.toml` + `hosts/x.nix`) | 2 (`fleet.toml` + `hosts/x.nix`) | 3 (`fleet.rs` + regen JSON + `hosts/x.nix`) |
| **Static Fleet Validation (no Nix eval)** | No (needs `nix eval` ~1–3s) | **Yes — 4 ms** (nodes, arch, IPs/CIDRs, roles, SOPS keys, ACLs, CI matrix) | **Yes — 4 ms** (+ static ports/subdomains) | Yes, after recompile (0.6–8s) |
| **IDE Autocomplete / Schema LSP** | Weak (Nix dynamic attrs) | **Strong on `fleet.toml`** (`schemars` + `taplo`) | Strong on TOML, weak on `.nix` half | **Strongest** (`rust-analyzer`) |
| **Dynamic/Computed Intents (`pkgs`, conditionals)** | **Native** | **Native** | **Awkward** (TOML has no functions/expressions) | Awkward across JSON seam |
| **Using Upstream NixOS Modules** | **100% Native** | **100% Native** | Native with split-file friction | High friction (JSON tax + dual-type drift) |
| **Custom DSL / Maintenance Burden** | Minimal | Minimal (standard TOML + serde structs for Topology only) | Medium (maintaining TOML schema for every workload field) | High (custom Rust DSL + codegen pipeline) |

## 5. Verdict
- **Commutative P5 Handlers verified** — import-order bug from `EXP-0002` is completely resolved.
- **M4 (Compiled Rust IR)** incurs high friction (recompile + IFD/codegen drift + split-file tax + custom DSL risk) without beating M2 on practical reliability.
- **M2 (Thin Shared `fleet.toml` for S0 Topology + Native Nix P5 for S1–S3)** vs **M1 (Pure Nix P5)** vs **M3 (Wide TOML)** form the clear, concrete choice set for Step 1A/1B co-design with the user.
