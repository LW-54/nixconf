---
id: ADR-0008
title: Stage 3A.1 — Antikythera (aky) Authoring Medium (A2 Split TOML + Nix) & Zero-Artifact Nix↔Rust Seam (S1)
type: adr
status: accepted
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [adr, phase-3, stage-3a, antikythera, aky, toml, nix, rust, boundary-first, zero-ifd, least-power]
assumptions: [A-001, A-002, A-013]
supersedes: []
summary: Ratifies project identity Antikythera (CLI aky), Authoring Medium A2 (pure *.toml Boundaries everywhere + pure interior.nix for Nix realizations with keyed multi-instance params), and Nix↔Rust Seam S1 (zero-artifact parallel read via builtins.fromTOML + ~60-LOC non-piercing keyed binder + CI equivalence check), rejecting Nix C++ plugins and experimental builtins.wasm lock-in.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies the **Stage `3A.1` One-Way Door** structural core of **Antikythera (`aky`)** based on primary 2025–2026 ecosystem analysis and empirical head-to-head benchmarking in [`EXP-0006`](../experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md):
1. **Project Identity:** **Antikythera** (`aky` CLI binary, `aky-core` Rust crate, `Aky` Lean 4 namespace).
2. **Authoring Medium (`A2` — Split Data Boundaries + Pure Nix Interiors):**
   - Every entity (Atomic Agent, Dressed Superagent, Transparent Profile, Substrate, Host, Cedar Policy, Human, AI Agent, External Platform) expresses its exterior boundary ($\Pi_{\text{ext}}$) in pure, static, schema-validated **`*.toml`**.
   - Atomic Nix agents pair `agent.toml` with a sibling **`interior.nix`** receiving `{ self, params, bound, pkgs, ... }` (non-Nix entities need *only* `.toml`).
   - Multi-instance parameterization (`QA-02`) uses declarative named `[instances.<name>]` + `params` (mirroring `clan-core` instances while remaining 100% pure data).
3. **Nix↔Rust Seam (`S1` — Zero-Artifact Parallel Read):**
   - `aky-core` (Rust, DRT-locked to Lean 4) reads `*.toml` directly in **`2–6 ms`** with zero Nix dependency.
   - Nix reads the *exact same* `*.toml` natively via pure Zero-IFD `builtins.fromTOML` + a minimal (~60 LOC) keyed binder enforcing Non-Piercing (`bound` contains *only* declared `-b`), verified by a CI binding-equivalence check. Zero generated lockfiles committed to Git; zero C++ plugins or experimental `builtins.wasm` evaluator lock-in (preserving universal `X4` portability while keeping pure Rust Wasm-ready if `builtins.wasm` ever stabilizes upstream).
4. **Three-Tier Power Stratification (W3C Rule of Least Power):** Non-Turing-complete `*.toml` boundaries (`Π_ext`) × 100% Turing-complete Nix inside `interior.nix` × compiled typed Rust in `aky`/`aky-core`.
<!-- abstract:end -->

# ADR-0008: Antikythera (`aky`) Authoring Medium (`A2`) & Nix↔Rust Seam (`S1`)

## Status
**Accepted** (2026-11-24 — Stage `3A.1`, ratified after [`EXP-0006`](../experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md)).

## Context
Phase 2 (`SPEC-FOUNDATION`, `ADR-0002`..`ADR-0007`, `PAPER-FOUNDATION`) locked our mathematically verified laws: Fractal Uniform Agency, Boundary-First Stratification ($\Pi_{\text{ext}} \perp \text{Interior}$), `B3` Cardinality-Checked Scoped Binding, `P-Dual`, Cedar/Biscuit `L3+`, `S2+` Open State Traits + CALM, and AWS Cedar VGD (`aky-core` Rust DRT-locked to Lean 4). Stage `3A.1` resolves our #1 **One-Way Door × Fleet-Wide** realization choice: the concrete authoring medium and the exact Nix↔Rust interchange seam.

## Options Evaluated (SBCE + [`EXP-0006`](../experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md))
- **Authoring Medium:**
  - `A1` — Pure Single-File Nix (`{ boundary; interior; }`) + `nix eval --json --file` → Rust (`79.2 ms` at 48 agents / 8 hosts; requires `nix` binary; boundary purity lint-enforced; fragile AST mutation for onboarding).
  - **`A2` (Selected)** — Split `*.toml` Boundaries Everywhere + Pure `interior.nix` (`5.79 ms` zero-Nix at 48 agents / 8 hosts; syntactically enforced $\Pi_{\text{ext}} \perp \text{Interior}$; lossless `toml_edit` onboarding/revocation; JSON Schema LSP; 100% Fractal Uniformity; bit-for-bit identical `.drv` hashes & 0 cache busts).
  - `A3` — Hybrid (`*.toml` fleet/hosts/policies + `*.nix` atomic agents) — breaks Fractal Uniformity with dual boundary syntaxes and still requires `nix` (`59.3 ms`) for full verification.
  - `A4` — Nickel (`organist`) / CUE — pruned via 2025–2026 primary survey (dev-shell scoped, stalled native NixOS interop, adds a 4th language + dependency risk `D`).
- **Nix↔Rust Seam:**
  - **`S1` (Selected)** — Zero-Artifact Parallel Read (`aky-core` reads TOML directly; Nix reads via Zero-IFD `builtins.fromTOML` + tiny non-piercing keyed binder + CI equivalence check).
  - `S2` — Codegen lockfile (`resolved.json` committed to Git) — rejected due to stale-artifact drift and commit churn.
  - `S3` — Rust subprocess driving `nix build --arg` — rejected because it breaks standalone `nix run` (`X4`).
- **Custom Nix Builtins (`builtins.fromRust` / `builtins.wasm`):**
  - Nix C++ plugins (`plugin-files`) rejected due to severe C++ ABI fragility (`D`) and mandatory host-level `nix.conf` setup breaking `X4`.
  - Determinate Nix's `builtins.wasm` (`nix-wasm-rust`) noted as promising in 2026, but rejected as a hard requirement because it remains an experimental non-upstream feature (`wasm-builtin`) breaking standard `nix run` portability (`X4`). Keeping `aky-core` pure Rust preserves effortless future Wasm compilation if `builtins.wasm` ever stabilizes upstream.

## Decision
1. Adopt **Antikythera (`aky`)** as the permanent project and CLI/crate identity.
2. Adopt **`A2` (Split `*.toml` Boundaries + Pure `interior.nix`)** with named `[instances.<name>]` + `params` for multi-instance instantiation.
3. Adopt **`S1` (Zero-Artifact Parallel Read + CI Binding-Equivalence Check)** with strict zero-IFD and relative-path cache isolation (zero `${self}`).
4. Preserve **Three-Tier Power Stratification**:
   - **Exterior Boundaries ($\Pi_{\text{ext}}$, `*.toml`)**: W3C Rule of Least Power (pure static data, `AttrExpr` predicates, profiles, keyed instances) — decidable, Lean-verifiable, losslessly editable, `5.8 ms` zero-Nix.
   - **Interiors (`interior.nix`)**: 100% full Turing-complete Nix for idiomatic NixOS modules, overlays, derivations, and wrapped standalone tools — sealed behind $\Sigma$.
   - **Control & Verification Engine (`aky` / `aky-core`)**: Pure typed Rust verified against Lean 4 DRT.

## Consequences
- **Positive:** Syntactic impossibility of leaking `nixpkgs`/thunks into boundaries; `5.8 ms` zero-Nix preflight & break-glass operation; lossless `toml_edit` Genesis onboarding & blast-radius revocation; bit-for-bit identical NixOS/standalone `.drv` outputs with 0 unrelated cache busts; universal standard `nix run` compatibility.
- **Trade-off accepted:** Atomic Nix agents consist of a clean 2-file directory (`agents/<name>/{agent.toml, interior.nix}`) rather than a single `.nix` file (mitigated by keeping non-Nix entities single-file `.toml`, passing `self` into `interior.nix` to prevent constant duplication, and gaining clean per-agent directory boundaries for `lib.fileset` cache isolation).
