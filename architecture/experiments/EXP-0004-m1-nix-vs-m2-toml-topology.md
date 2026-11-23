---
id: EXP-0004
title: Surgical Comparison & Benchmark — M1 (fleet.nix) vs M2 (fleet.toml) for S0 Static Topology
type: experiment
status: completed
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [experiment, topology, toml, nix, m1-vs-m2, toml-edit, onboarding, benchmark]
assumptions: [A-001]
rfd: RFD-0001
git_commit: cc86772
host: astrolabe
summary: Measured real M1 (standalone fleet.nix 66ms vs flake 830ms) vs M2 (builtins.fromTOML 72ms, Rust 4ms, Python tomllib 260ms) ingestion and isolated the five true structural differentiators beyond speed.
---

<!-- abstract:start -->
## Executive Abstract

Directly compared **M1 (`fleet.nix`)** vs **M2 (`fleet.toml`)** for Stratum `S0` (Static Fleet Topology). **Empirical finding**: Speed is NOT the real differentiator — standalone `nix eval --json --file fleet.nix` runs in **66 ms** warm (vs **830 ms** through a flake, **72 ms** for Nix `builtins.fromTOML`, **4 ms** for Rust reading TOML directly, and **260 ms** for Python `tomllib` in pre-Nix CI). Instead, the real decision turns on five structural properties: (1) **Language-enforced `S0` purity** (TOML makes importing `nixpkgs` or `${self}` impossible by construction), (2) **Safe format-preserving programmatic writes** (`toml_edit` in Rust enables trivial `nixconf host enroll` onboarding vs fragile Nix AST surgery), (3) **Zero-Nix consumer portability** (pre-Nix CI matrix jobs, bootstrap rescue shells, subprocess-free Rust/MCP tools), (4) **Live IDE autocomplete** (`schemars` JSON Schema + `taplo`), vs M1's advantages of (5) **Single-language purity**, Nix expressions/interpolation inside `S0`, and zero dual-schema sync.
<!-- abstract:end -->

# EXP-0004: M1 (`fleet.nix`) vs M2 (`fleet.toml`) Benchmark & Structural Analysis

## 1. Raw Measurements (`astrolabe`, Nix 2.34.9)

| Consumer / Method | Wall Time | Notes |
| :--- | ---: | :--- |
| M1 — `nix eval --json --file fleet.nix` (cold / warm) | `212 ms` / **`66 ms`** | Requires `nix` binary, standalone file (no `nixpkgs` import). |
| M1 — `nix eval --json .#<attr>` (via flake, warm) | **`830 ms`** | Pays flake evaluation startup overhead. |
| M2 — `nix eval` via `builtins.fromTOML` (zero IFD) | **`72 ms`** | Virtually identical to reading `fleet.nix` inside Nix. |
| M2 — Prebuilt Rust binary reading `fleet.toml` (`EXP-0003`) | **`4 ms`** | Zero `nix` subprocess required. |
| M2 — Python stdlib `tomllib` reading `fleet.toml` | **`260 ms`** | Works in GitHub Actions `ubuntu-latest` *before* `install-nix-action`. |

## 2. Structural Comparison Beyond Speed

| Structural Property | M1 (`fleet.nix`) | M2 (`fleet.toml`) |
| :--- | :--- | :--- |
| **Enforces `S0` pure-data boundary by construction?** | No (Turing-complete; relies on discipline/lints to prevent `nixpkgs` or `${self}` creep) | **Yes** (non-Turing-complete data format makes code leakage unrepresentable) |
| **Safe programmatic read-write (`nixconf host enroll`)** | **Brittle** (comment-preserving AST edits on arbitrary Nix expressions with `let`/`//`/imports) | **Clean & exact** (`toml_edit` in Rust preserves comments, formatting, and ordering) |
| **Works without `nix` installed (pre-Nix CI, bootstrap, standalone MCP)?** | No (must spawn `nix eval`) | **Yes** (native Rust, Python `tomllib`, `yq`) |
| **IDE autocomplete & hover schema docs** | Limited (`nil`/`nixd` without custom schema plugin) | **First-class** (`schemars` → `fleet.schema.json` + `taplo` in Zed/VS Code) |
| **Single declarative syntax across repo?** | **Yes** (100% Nix) | No (TOML for 1 file `fleet.toml`, Nix everywhere else) |
| **DRY expressions/interpolation inside `S0`?** | **Yes** (`"${name}.${meshDomain}"`, `let`, helpers) | No (stores only irreducible ground facts; derived fields computed in thin loader) |
| **Schema maintenance** | Single Nix `lib.types` definition | Small shared contract: Rust `struct Fleet` + Nix validation (auto-checked together in CI) |
| **Reversibility** | High (~60–150 line pure data file; trivially convertible in either direction) | High (same) |
