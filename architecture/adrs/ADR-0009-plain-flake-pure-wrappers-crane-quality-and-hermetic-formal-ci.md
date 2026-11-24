---
id: ADR-0009
title: Stage 3A.2 — Plain Flake Entrypoints (P1), Pure Nixpkgs Wrappers (W-Std), Crane Rust Workspace + All-Layer Quality Policy & Hermetic Formal CI (F-Hermetic)
type: adr
status: accepted
created: 2026-11-24
updated: 2026-11-24
domain: tooling
tags: [adr, phase-3, stage-3a, flakes, nixpkgs, wrappers, crane, rust, clippy, cargo-deny, lean4, quint, ci, quality-gates]
assumptions: [A-003, A-004, A-005, A-013]
supersedes: []
summary: Ratifies Stage 3A.2 packaging, pinning, standalone wrapping, Rust workspace, and formal CI: standard flake.nix + flake.lock (~45 LOC, dropping .tack/flake-parts/import-tree/flake-schemas), pure nixpkgs standalone wrappers (W-Std, zero nix-wrapper-modules dep), single Cargo workspace built via crane with strict LW-54/rust-env zero-panic lints + cargo-deny, and 100% offline hermetic Nix sandbox builds for Lean 4 & Quint (F-Hermetic).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies the **Stage `3A.2`** packaging, build, and all-layer quality architecture of **Antikythera (`aky`)**, backed by [`AUD-0002`](../audit/AUD-0002-meta-tooling-rust-deps.md), direct source inspection of `.tack/pins.toml` and `nix-wrapper-modules`, [`LW-54/rust-env`](https://github.com/LW-54/rust-env), and [`EXP-0007`](../experiments/EXP-0007-entrypoints-wrappers-and-hermetic-formal-sandbox.md):
1. **Entrypoints & Pinning (`P1`):** Standard `flake.nix` + `flake.lock` with ~45 LOC plain `forAllSystems` outputs — eliminating `.tack/` (1,082 LOC, verified zero active `[signers]`/`patches`/`tag` usage), `flake-parts`, `denful/import-tree`, and `flake-schemas`.
2. **Standalone `nix run` App Wrapping (`W-Std`):** Pure `nixpkgs` primitives (`writeShellApplication`, `symlinkJoin` + `makeBinaryWrapper`, `lib.generators.*` / `pkgs.formats.*`) with **zero** `nix-wrapper-modules` dependency. Each standalone agent exports `{ package = wrapped; nixos.environment.systemPackages = [ wrapped ]; }` (strict Two-Way Door per `interior.nix`).
3. **Unified Rust Workspace (`R-Crane`) & 4-Language Quality Policy (`QA-04`):** One Cargo workspace (`crates/{aky-core, aky-cli, ...}`) built via `ipetkov/crane` + stock `nixpkgs` `rustc` + `lib.fileset.toSource` (Attic-caching `buildDepsOnly` separately from source/clippy/test/deny checks), governed by strict zero-panic / zero-`unsafe` / zero-`as`-cast Rust lints (extending `LW-54/rust-env`), `cargo-deny`, Nix `alejandra`/`statix`/`deadnix`/cache-isolation, TOML `aky check`, and Lean/Quint checks.
4. **Hermetic Formal CI (`F-Hermetic`):** Offline hermetic Nix sandbox derivations for `aky-oracle` (Lean 4.35 `lake build` + `Audit.lean` `0 sorryAx`, `46.25 s`) and `aky-quint-check` (`quint test` + exhaustive TLC, `28.68 s`) using stock `pkgs.lean4` + `pkgs.stdenv` + `pkgs.quint` (**0 extra flake inputs**), kept under lazy `packages`/`checks` + `devShells.formal` so hosts and daily devs never fetch Lean or Quint.
<!-- abstract:end -->

# ADR-0009: Stage `3A.2` — Entrypoints (`P1`), Wrappers (`W-Std`), Rust/Quality (`R-Crane`) & Formal CI (`F-Hermetic`)

## Status
**Accepted** (2026-11-24 — Stage `3A.2`, backed by [`EXP-0007`](../experiments/EXP-0007-entrypoints-wrappers-and-hermetic-formal-sandbox.md) & direct source audits).

## Context
With `ADR-0008` (`A2` Split TOML + Nix, `S1` Zero-Artifact Seam) ratified, Stage `3A.2` resolves how Antikythera pins external dependencies, exposes universal `nix run` packages (`X4`), builds its unified Rust workspace (`A-005`), enforces code quality uniformly across all repo layers (`QA-04`), and packages its Lean 4 + Quint verification suite (`ADR-0007`, `A-004`).

## Decisions

### 1. Entrypoint & Dependency Pinning — `P1` (Standard Plain Flake)
- Adopt standard `flake.nix` + `flake.lock` with ~45 LOC plain `forAllSystems` outputs (`[ "x86_64-linux" "aarch64-linux" ]`).
- Eliminate `.tack/` (1,082 LOC custom resolver; direct inspection of `.tack/pins.toml` confirmed `[signers]`, `[omit_inputs]`, `patches`, and `tag` were unused), `flake-parts`, `denful/import-tree`, and `flake-schemas`.
- Restores universal `nix run github:LW-54/antikythera#<tool>`, native `nix flake update` / Renovate / GitOps compatibility, and minimal dependency risk (`D`), while `aky check` (`5.8 ms` zero-Nix) completely bypasses flake copy overhead in the inner dev loop.

### 2. Standalone App Wrapping — `W-Std` (Pure `nixpkgs` Primitives)
- Direct source audit of `nix-wrapper-modules` showed ~5,700 LOC of active framework code (`lib/` + `modules/`) maintained primarily by one author, whereas wrapping typical apps (`git`, `foot`, `tmux`, CLI tools) takes ~10–15 LOC in pure, decade-stable `nixpkgs` (`symlinkJoin` + `makeBinaryWrapper` + `lib.generators.*` / `pkgs.formats.*`).
- Adopt pure `nixpkgs` wrappers with **zero** external wrapper framework dependency. Every standalone agent returns `{ package = wrapped; nixos.environment.systemPackages = [ wrapped ]; }`, serving both `nix run` anywhere (`X4`) and NixOS hosts with zero Home Manager / `hjem` duplication.
- Because `ADR-0008` seals each agent's `interior.nix` behind `agent.toml`, adopting an external wrapper library for a specific complex app later remains a localized Two-Way Door.

### 3. Unified Rust Workspace (`R-Crane`) & All-Layer Quality Policy (`QA-04`)
- Replace v1's 3 fragmented Rust setups (`AUD-0002`) with **one Cargo workspace** (`crates/{aky-core, aky-cli, ...}`) built via `ipetkov/crane` + stock `nixpkgs` `rustc` + `lib.fileset.toSource`, splitting `buildDepsOnly` (cached in Attic purely by `Cargo.lock`) from `buildPackage`, `cargoClippy`, `cargoTest`, and `cargoDeny`.
- Enforce one **Unified 4-Language Quality Standard** in CI & pre-commit:
  - **Rust (`Cargo.toml` `[workspace.lints]` + `.clippy.toml` + `deny.toml`):**
    - `[workspace.lints.rust]`: `unsafe_code = "forbid"`, `unused_crate_dependencies = "deny"`, `missing_debug_implementations = "warn"`, `missing_docs = "warn"`.
    - `[workspace.lints.clippy]`: `pedantic = { level = "deny", priority = -1 }`, `nursery = { level = "warn", priority = -1 }` (avoids false-positive CI breaks across `nixpkgs` `rustc` upgrades; use `#[expect(..., reason = "...")]` for justified suppressions), plus strict zero-panic/zero-lossy-cast bans from `LW-54/rust-env`: `unwrap_used`, `expect_used`, `indexing_slicing`, `string_slice`, `arithmetic_side_effects`, `unchecked_time_subtraction`, `panic`, `panic_in_result_fn`, `unreachable`, `unimplemented`, `todo`, `exit`, `as_conversions` all `"deny"`.
    - `.clippy.toml`: `allow-unwrap-in-tests = true`, `allow-expect-in-tests = true`, `allow-panic-in-tests = true`, `allow-indexing-slicing-in-tests = true`.
    - Supply chain & testing: `cargo-deny` (`deny.toml`), `rustfmt --check`, `cargo test`, and **Lean 4 DRT**.
  - **Nix:** `alejandra --check`, `statix check`, `deadnix --fail`, zero-`${self}` cache-isolation check, and `S1` binding-equivalence check.
  - **TOML Boundaries:** `aky check` (all 35 Lean-verified invariants) + JSON Schema / `taplo` check.
  - **Formal (`Lean 4` + `Quint`):** `lake build` (0 warnings), `Audit.lean` (0 `sorryAx`), `quint test`, and exhaustive TLC.

### 4. Hermetic Formal Verification Packaging — `F-Hermetic`
- Package `aky-oracle` (Lean 4.35 `lake build` + `Audit.lean`) and `aky-quint-check` (`quint test` + exhaustive TLC) as pure, offline, `lib.fileset`-isolated Nix derivations using stock `pkgs.lean4` + `pkgs.stdenv` + `pkgs.quint` (`HOME=$TMPDIR`, **0 extra flake inputs**), empirically verified in `EXP-0007`.
- Expose strictly under lazy `packages.aky-oracle`, `checks.{lean-audit, quint-check, drt}`, and `devShells.formal` so hosts and daily `devShells.default` never download Lean 4 or Quint.
- Run on the 3-cadence production schedule: local/pre-commit (`aky check` `< 6 ms`), normal PRs (Attic-cached `aky-oracle` DRT against real fleet `~2 s`), engine/spec PRs (full hermetic Lean + Quint + fuzzed DRT).

## Consequences
- **Positive:** Cuts v1's core framework footprint from 15 pins + 1,082 LOC `.tack` down to minimal standard inputs (`nixpkgs` + `crane` + domain-earned Stage 3A.3/3B pins); enforces zero-panic / zero-`unsafe` Rust + uniform 4-language quality gates across every repo layer; caches Rust deps and Lean oracle cleanly in Attic with zero unrelated cache busts.
- **Deferred Two-Way Door:** Project scaffolding templates (`templates.rust` / `aky init` vs. separate `LW-54/rust-env` repo) deferred to Stage `3C.3` (CLI UX) with zero coupling to the Structural Kernel.
