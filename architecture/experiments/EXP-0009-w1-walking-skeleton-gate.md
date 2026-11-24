---
id: EXP-0009
title: Mandatory W1 Walking Skeleton Gate — Full End-to-End Antikythera (v2/) Verification & Empirical Benchmark
type: experiment
status: completed
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [experiment, benchmark, walking-skeleton, w1-gate, crane, rust, lean4, quint, drt, impermanence, hjem, cache-isolation, aky]
assumptions: [A-001, A-002, A-003, A-004, A-005, A-007, A-013]
summary: Mandatory W1 Walking Skeleton empirical gate on v2/ (design/v2) proving Stage 3A end-to-end: 7/7 hermetic flake checks PASS (strict LW-54/rust-env Clippy, rust-test, rust-fmt, Lean 4 Audit 35 theorems/0 sorryAx, Quint/TLC, real+500 fuzzed DRT, bit-for-bit S1 Rust==Nix binding equivalence), 2002/2002 live DRT (Rust 10.52ms vs Lean 1053.8ms), crane incremental rebuild 18.61s (validating A-005), 1.88ms zero-Nix aky check, real standalone W-Std git, real NixOS astrolabe (sealed impermanence + hjem) & live-iso, 0 unrelated cache busts, and 3 real integration snags caught early.
---

<!-- abstract:start -->
## Executive Abstract

Executes and passes the **Mandatory `W1` Walking Skeleton Gate** ([`RES-0014`](../research/RES-0014-phase3-realization-methodology-and-dsm.md)) inside [`v2/`](../../v2/flake.nix) on `design/v2`, validating the entire **Stage `3A` Structural Kernel** (`ADR-0008`..`ADR-0010`) end-to-end before entering Stage `3B`:
1. **7/7 Hermetic Flake Checks PASS (`nix build path:./v2#checks.x86_64-linux.*`):** `rust-fmt`, `rust-clippy` (0 warnings under `LW-54/rust-env` strict zero-panic + `pedantic` + `nursery` + `unsafe_code = "forbid"` + `missing_docs`), `rust-test`, `lean-audit` (35 theorems, `0 sorryAx`), `quint-check` (8 tests + exhaustive TLC), `aky-fleet-and-drt` (real repo hosts + 500 fuzzed vs. Lean 4), and **`s1-binding-equiv`** (`diff -u` confirming `aky resolve astrolabe` Rust JSON == `v2/lib/realize.nix` Nix JSON bit-for-bit!).
2. **`crane` Incremental Rust Caching Validated (`A-005`):** Real uncached source edit to `v2/crates/aky-cli/src/main.rs` rebuilt in **`18.61 s`** reusing cached `buildDepsOnly` (zero Cargo crate recompilation); `cargo-deny` passed (`advisories ok, bans ok, licenses ok, sources ok`, 0 warnings).
3. **Live `aky` CLI & 2,002-Fleet DRT:** `aky check` verified the fleet in **`1.88 ms`** (`6.78 ms` process wall time, zero Nix!); `aky explain` blocked `agy` via `forbid-roaming-or-ai-vault` and allowed `astrolabe`; `aky blast-radius chromebook` returned `["wifi-eduroam"]`; `aky drt --cases 2000` matched **`2,002 / 2,002` cases bit-for-bit** (Rust **`10.52 ms`** vs. Lean 4 **`1,053.80 ms`**).
4. **Standalone `W-Std` + Contrasting NixOS Targets + Cache Isolation:** `nix run path:./v2#git` executed `git 2.56.0` with embedded `init.defaultBranch = main`; `astrolabe` evaluated cleanly with `hjemEnabled = true` and `persisted = ["/var/lib/nixos", "/var/lib/vaultwarden"]` auto-derived strictly from `[state.*]`; `live-iso` evaluated to a real `isoImage.drv`; mutating an unrelated file inside `v2/` caused **0 cache busts** across `aky`, `aky-oracle`, and `astrolabe`.
5. **3 Real Integration Snags Caught Early by `W1`:** (1) `devShells.default` required `mkShell` over `mkShellNoCC` for Cargo's linker `cc`; (2) `nix-community/impermanence` pulls `home-manager` into `flake.lock` unless pinned with `flake = false` (keeping `v2/flake.lock` at **4 clean inputs total** with zero `home-manager`!); (3) `impermanence`'s `/var/lib/nixos` UID/GID persistence warning was solved cleanly via `[state.nixos-ids]` inside `storage-ephemeral/agent.toml`.
<!-- abstract:end -->

# EXP-0009: Mandatory `W1` Walking Skeleton Verification & Benchmark

## 1. Walking Skeleton Architecture (`v2/`)
- **4 Flake Inputs Total (`v2/flake.lock`):** `nixpkgs`, `crane`, `impermanence` (`flake = false`), `hjem` (down from v1's 15 pins + 1,082-LOC `.tack` + `flake-parts` + `import-tree` + `flake-schemas`).
- **Workspace Crates:** `v2/crates/aky-core` (pure `std::fs`-free, Wasm-ready, 0 `unsafe`, 0 panics) + `v2/crates/aky-cli` (`aky`).
- **Formal Suite:** `v2/formal/lean/` (`Aky.*` 4-layer `cedar-lean`, 35 theorems, `aky-oracle`) + `v2/formal/quint/`.
- **Real Fleet Slice:** `agents/{git, caddy, vaultwarden, target-nixos-efi, target-nixos-iso, storage-ephemeral, sub-home-hjem}`, `profiles/base-server.toml`, `policies/default.toml`, `hosts/{astrolabe, live-iso}.toml`, and `lib/realize.nix`.

---

## 2. Empirical Measurements (`astrolabe`, `x86_64-linux`)

| Check / Benchmark | Wall Time | Result |
| :--- | ---: | :--- |
| **Nix Hygiene (`alejandra --check` + `statix` + `deadnix`)** | **`50.78 ms`** | **PASS** (0 warnings) |
| **`cargo-deny check`** | `< 1.0 s` | **PASS** (`advisories/bans/licenses/sources ok`, 0 warnings) |
| **`crane` Incremental Rebuild (uncached `.rs` source edit)** | **`18.61 s`** | **PASS** (reused cached `buildDepsOnly` artifacts; `A-005` validated!) |
| **`checks.x86_64-linux.{rust-fmt, rust-clippy, rust-test}`** | `1.88 / 2.13 / 1.97 s` *(warm)* | **3/3 PASS** (0 warnings under `LW-54/rust-env` strict Clippy) |
| **`checks.x86_64-linux.{lean-audit, quint-check}`** | `1.69 / 2.87 s` *(warm)* | **2/2 PASS** (35 theorems `0 sorryAx`, 8 Quint tests + exhaustive TLC) |
| **`checks.x86_64-linux.aky-fleet-and-drt`** | **`3.37 s`** | **PASS** (real fleet + 500 fuzzed vs. `aky-oracle`) |
| **`checks.x86_64-linux.s1-binding-equiv`** | **`3.35 s`** | **PASS** (`diff -u` Rust `aky resolve` == Nix `lib/realize.nix` bit-for-bit!) |
| **`aky --root v2 check`** *(zero-Nix)* | **`6.78 ms`** *(engine: `1.88 ms`)* | **PASS** (`astrolabe` 6 agents / 2 persisted; `live-iso` 2 agents / 0 persisted; standalone `[git]`) |
| **`aky drt --oracle aky-oracle --cases 2000`** | **`1,170 ms`** *(Rust: `10.52 ms`, Lean: `1,053.8 ms`)* | **PASS** (`2,002 / 2,002` bit-for-bit, **0 divergences**) |
| **Standalone `W-Std` `git` (`nix build path:./v2#git`)** | **`2.14 s`** | **PASS** (`git 2.56.0`, embedded `init.defaultBranch = main`) |
| **`astrolabe` NixOS Eval (`impermanence` + `hjem` + `vaultwarden`)** | **`12.15 s`** | **PASS** (`hjemEnabled = true`, `persisted = ["/var/lib/nixos", "/var/lib/vaultwarden"]`) |
| **`live-iso` NixOS Eval (`isoImage.drv`)** | **`30.57 s`** | **PASS** (`7xw5xs...nixos-minimal-x86_64-linux.iso.drv`) |
| **Zero-`${self}` Cache Isolation (unrelated file mutated in `v2/`)** | — | **PASS** (`aky`, `aky-oracle`, `astrolabe` `.drv` paths 100% unchanged!) |

---

## 3. Gate Verdict
**`W1` WALKING SKELETON GATE PASSED.** All Stage `3A` Structural Kernel decisions (`ADR-0008`..`ADR-0010`) hold under real Nix/Rust/Lean/Quint execution with clean ergonomics, `< 7 ms` zero-Nix verification, bit-for-bit Nix↔Rust and Rust↔Lean equivalence, and 0 cache busts. Cleared to enter **Stage `3B` — Trust, Mesh & Convergence Plane**!

---

## 4. Pure Model-A Refactor Addendum (2026-11-24 — Zero `HostManifest`, Parameters-as-Promises, Recursive `web-stack`)

Following a critical architectural audit of the initial skeleton, we eliminated two subtle drifts from `ADR-0002` + `ADR-0003`:
1. **Hosts ARE Regular Dressed Superagents:** Deleted `HostManifest`, `v2/hosts/`, and special host-only fields (`ram_mib`, `backup_providers`, `substrate_offers`). `astrolabe`, `live-iso`, and nested `web-stack` ALL use the exact same universal `AgentManifest` (`v2/agents/<name>/agent.toml`), checked recursively with `superagent_conforms`.
2. **Parameters ARE Promises:** Deleted the unverified `params` side-channel and magic `host` argument in `interior.nix`. Config inputs (`config:hostname`, `config:domain`, `config:primary-user`) flow strictly through `-b` / `+b` promises (`internal_offers` & child-scoped `offers`), hardened with `#[serde(deny_unknown_fields)]` (which immediately caught a real TOML section-scoping bug!).

### Re-Verified Pure Model-A Results
- **`aky --root v2 check`**: **`2.43 ms`** engine (`9.11 ms` wall) — `[PASS] astrolabe (x86_64-linux)`, `[PASS] live-iso (x86_64-linux)`, `[PASS] web-stack (nested-superagent)`, `Standalone: [git]`.
- **`aky drt --cases 2000`**: **`2,003 / 2,003` bit-for-bit** (`3` real Dressed Superagents incl. nested `web-stack` + `2,000` fuzzed, **0 divergences**; Rust `9.42 ms` vs. Lean 4 `1,010.10 ms`).
- **7/7 Hermetic Flake Checks PASS**: incl. recursive **`s1-binding-equiv`** matching `web-stack/caddy`, `web-stack/vaultwarden`, `target-nixos-efi`, `sub-home-hjem` bit-for-bit between Rust and Nix on both `astrolabe` and `live-iso`, plus **4/4 Rust unit tests** (including negative tests catching lying/leaking Dressed Superagents and missing mandatory parameter promises!).
- **Real NixOS & Cache Isolation**: `astrolabe` (`hjemEnabled = true`, `persisted = ["/var/lib/nixos", "/var/lib/vaultwarden"]`), `live-iso` (`isoImage.drv`), standalone `git 2.56.0`, and **0 cache busts** on `aky`, `aky-oracle`, and `astrolabe`.

---

## 5. `F1` Core TCB & Boundary Gap Closure Addendum (2026-11-24 — 41 Lean Theorems, Zero Piercing, Partitioned Routing)

Following a line-by-line formal audit comparing `v2/` against `SPEC-FOUNDATION` and `Aky/Spec/*`, we closed the **TCB/Projection Gap** plus all **5 structural gaps**:

1. **TCB Closure (Recursive `Agent` Tree in Lean 4 + DRT)**: Upgraded `Aky.Spec.Agency`, `Aky.Spec.Binding`, and `Aky.Oracle.Protocol` so Lean 4 accepts the **actual recursive `Agent` tree** (`atomic` / `superagent` / `profile`) and verifies conformance + scoped binding recursively at every level via `checkAgentTree`. Added **6 new machine-checked theorems** (`35 → 41`, still **0 `sorryAx`** in `Aky/Audit.lean`), culminating in **`checkAgentTree_substitution_invariant`** (proving any valid interior refactor preserving `Π_ext` preserves validity of the enclosing parent Superagent!).
2. **Gap #1 (Zero Interior Piercing for RAM Budgets & State Volumes)**: Deleted `subtree_ram_demands()` and `collect_subtree_state_and_traits()` from `aky-core/src/fleet.rs` and recursive `collectPersistentPaths` from `v2/lib/realize.nix`. `ExteriorSurface` now carries `volumes : List StateVolume` and budgeted `-b ram` promises; `web-stack/agent.toml` explicitly declares `[budgets] ram_mib = 384, tier = "critical"` and `[state.vaultwarden-data] path = "/var/lib/vaultwarden"`, checked by coarse-grained budget & volume conformance (`conforms_budget_and_critical_sound`, `conforms_volume_persistence_sound`, `conforms_volume_backup_sound`, `conforms_volume_calm_sound`). `astrolabe` reads strictly direct children's exteriors.
3. **Gap #2 (Separate `(ptype, key)`)**: Restored optional explicit `ptype` & `key` on `OfferSpec` / `RequireSpec` (defaulting to the table key for simple offers), enabling distinct keyed offers (`ptype = "http:route", key = "vault"`) and multi-instance providers.
4. **Gap #3 (`ch.offers` Scoped Private Wrapper)**: Desugared child-scoped `ch.offers` into an anonymous 1-child Dressed Superagent wrapper in `build_agent_tree`, eliminating sibling scope pollution and false `DuplicateOffer` collisions across multiple instances of the same agent (`rclone-gdrive` + `rclone-b2`).
5. **Gap #4 (Dynamic `Partitioned` `AttrExpr` Routing in `caddy` ↔ `vaultwarden`)**: Removed the hardcoded `127.0.0.1:8222` from `v2/agents/caddy/interior.nix`. `vaultwarden` emits `+b` `http:route` (`key = "vault"`, `kind = "partitioned"`, `tags = ["zone:public"]`, `subdomain = "vault"`, `port = 8222`); `caddy` consumes `-b` `http:route` (`selector = atom "zone:public"`) and generates `services.caddy.virtualHosts` dynamically from `bound."http:route"` in both Rust and Nix (`evalAttrExpr` matching `Aky.Data.AttrExpr.eval` 1:1).
6. **Gap #5 (NixOS Global `config` Backdoor Blocked)**: Added `assertNonPiercingNixos` in `v2/lib/realize.nix` (verified by negative assertions in `checks.s1-binding-equiv`), rejecting `{ config, ... }:` module functions across `Σ` and forbidding `imports` on non-substrate atomic agents.

### Re-Verified `F1` Results
- **`lean-audit`**: **41/41 theorems verified, 0 `sorryAx`**.
- **`aky --root v2 check`**: **`2.01 ms`** zero-Nix — `astrolabe`, `live-iso`, `web-stack`, standalone `[git]` all PASS.
- **`aky drt --cases 2000`**: **`2,003 / 2,003` recursive `Agent` trees matched bit-for-bit** (`3` real recursive Superagent trees + `2,000` fuzzed multi-level trees, **0 divergences**; Rust `17.32 ms` vs. Lean 4 `1,022.32 ms`).
- **7/7 Hermetic Flake Checks PASS** + **7/7 Rust unit tests** (including negative tests for Gaps #1–#4) + **`s1-binding-equiv`** matching dynamic `Partitioned` `bound."http:route".vault` + Gap #5 `{ config, ... }:` rejection assertions!
- **Real NixOS Eval**: `astrolabe` dynamically produces `services.caddy.virtualHosts."vault.astrolabe.example.org".extraConfig = "reverse_proxy 127.0.0.1:8222\n"` (zero hardcoded port/subdomain), `hjemEnabled = true`, `persisted = ["/var/lib/nixos", "/var/lib/vaultwarden"]` (non-piercing), `live-iso` (`isoImage.drv`), standalone `git 2.56.0`.
