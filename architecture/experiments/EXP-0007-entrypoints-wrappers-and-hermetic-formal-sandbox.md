---
id: EXP-0007
title: Stage 3A.2 Empirical Benchmark — Plain Flake vs flake-parts, Standalone Wrappers & Hermetic Lean 4 / Quint Nix Sandboxes
type: experiment
status: completed
created: 2026-11-24
updated: 2026-11-24
domain: tooling
tags: [experiment, benchmark, phase-3, stage-3a, flakes, flake-parts, nix-wrapper-modules, lean4, quint, tlc, sandbox, cache-isolation]
assumptions: [A-003, A-004, A-005, A-013]
summary: Empirically benchmarks Stage 3A.2 choices on astrolabe using pinned nixpkgs/flake-parts/wrapper-modules: proves plain flake (~45 LOC) and flake-parts evaluate identically (~2.7s dominated by nixpkgs), nix-wrapper-modules adds only ~101ms overhead over raw nixpkgs wrappers, and both Lean 4.35 (35 theorems + Audit.lean + native aky-oracle, 46.2s) and Quint 0.33.1 (8 tests + exhaustive TLC, 28.7s) build and verify 100% offline inside hermetic Nix sandboxes with full lib.fileset cache isolation.
---

<!-- abstract:start -->
## Executive Abstract

Empirically benchmarks and sandbox-validates the **Stage `3A.2`** packaging & toolchain candidates on `astrolabe` (100% offline using pinned `/nix/store` inputs):
1. **Plain `flake.nix` vs. `flake-parts` (Multi-Arch `x86_64-linux` + `aarch64-linux`):** Plain `forAllSystems` (`2,783 ms` median) vs. `flake-parts` (`2,687 ms` median) evaluate within ~100 ms noise (dominated by `import nixpkgs`) and produce bit-for-bit identical `.drv` paths — meaning dropping `flake-parts`, `import-tree`, and `.tack` is a pure complexity & dependency-risk (`D`) win with zero performance downside.
2. **Standalone `nix run` Wrapping (`W-Std` vs. `W-NWM`):** Pure `nixpkgs` `symlinkJoin` + `makeBinaryWrapper` (`2,200 ms`) vs. `nix-community/nix-wrapper-modules` (`2,301 ms`) differs by only **`+101 ms`**, confirming `nix-wrapper-modules` is lightweight enough for complex user apps (`foot`, `neovim`, `git`, `zsh`) while trivial standalone tools use pure `nixpkgs` directly.
3. **Hermetic Offline Nix Sandbox Build — Lean 4.35 (`architecture/formal/lean/`):** Built all 15 modules (`Data`/`Spec`/`Thm`/`Oracle`), compiled native `/nix/store/jc7rkpw87p76l0yh25ra62sxayfvjvg6-aky-lean-oracle-0.2.0/bin/aky-oracle`, and mechanically ran `lake env lean Nixconf/Audit.lean` (`0 sorryAx`) in **`46.25 s`** offline inside Nix's sandbox (`pkgs.lean4` + `pkgs.stdenv`, `HOME=$TMPDIR`), with **100% `lib.fileset` cache isolation** from unrelated edits.
4. **Hermetic Offline Nix Sandbox Run — Quint 0.33.1 + TLC (`architecture/formal/quint/`):** Passed all **8 `quint test` runs** plus exhaustive TLC verification (`lifecycle_recovery`, `conditional_degradation`) in **`28.68 s`** offline inside Nix's sandbox (`pkgs.quint`, `HOME=$TMPDIR`) with zero JVM or network sandbox failures.
<!-- abstract:end -->

# EXP-0007: Stage 3A.2 Entrypoints, Standalone Wrappers & Hermetic Formal Sandboxes

## 1. Pinned Environment (`astrolabe`, `x86_64-linux`)
- `nixpkgs`: `/nix/store/p7yx739q7ips4f9a1a26k509id1kd85i-source` (`lean4 4.35.0`, `quint 0.33.1`, `rustc 1.99.0`, `gcc 16.2.0`)
- `flake-parts`: `/nix/store/z8bni15xhz9qxxi9aarih0rydqqbbb7g-source`
- `wrapper-modules`: `/nix/store/8s21aagnx3lwhcgv5w36hx2110gyaacf-source`

---

## 2. Empirical Measurements

| Experiment | Metric / Scope | Median / Wall Time | Result |
| :--- | :--- | ---: | :--- |
| **Plain `flake.nix` (`forAllSystems`)** | `x86_64-linux` + `aarch64-linux` (`packages`, `devShells`, `checks`) | `2,783.06 ms` *(5 runs)* | Identical `.drv` to `flake-parts` |
| **`flake-parts` (`mkFlake`)** | Exact same multi-arch outputs | `2,686.97 ms` *(5 runs)* | Identical `.drv` (within ~100 ms noise; extra framework indirection & `self.inputs` plumbing) |
| **`W-Std` (Pure `nixpkgs` Wrapper)** | `foot` wrapped via `writeText` + `symlinkJoin` + `makeBinaryWrapper` | `2,199.64 ms` *(5 runs)* | Zero external inputs |
| **`W-NWM` (`nix-wrapper-modules`)** | `foot` wrapped via `wrappers.foot.wrap` | `2,301.10 ms` *(5 runs)* | **`+101 ms`** eval delta; preserves `.override`/submodules & drops `hjem`/HM duplication |
| **Hermetic Lean 4.35 Sandbox (`nix build`)** | `lake build Nixconf nixconf-oracle` + `Audit.lean` (`0 sorryAx`) + `lib.fileset` | **`46.25 s`** *(cold)* | **PASS** — `/nix/store/jc7rkp...aky-lean-oracle-0.2.0/bin/aky-oracle`, **0 unrelated cache busts** |
| **Hermetic Quint 0.33.1 + TLC Sandbox (`nix build`)** | 3× `quint test` (8 runs) + exhaustive TLC (`lifecycle_recovery`, `conditional_degradation`) | **`28.68 s`** *(cold)* | **PASS** — `/nix/store/3y3h58...aky-quint-check`, zero JVM/network issues w/ `HOME=$TMPDIR` |

---

## 3. Architectural Takeaways for Stage `3A.2`

1. **Zero Reason to Keep `.tack`, `flake-parts`, `import-tree`, or `flake-schemas`:** Because Antikythera's `A2` (`*.toml` + `interior.nix`) + `S1` binder ALREADY drives agent discovery and composition cleanly without `flake-parts` module merging, plain standard `flake.nix` + `flake.lock` (~45 LOC) eliminates 1,082 LOC of custom `.tack` resolver + 3 framework inputs while restoring 100% compatibility with `nix run github:...#tool`, `nix flake update`, Renovate, and GitOps tooling.
2. **Hermetic Formal CI Requires ZERO Extra Flake Inputs:** Both `pkgs.lean4` (4.35.0) and `pkgs.quint` (0.33.1) build and pass completely offline inside standard Nix sandboxes using stock `nixpkgs` + `lib.fileset.toSource` + `HOME=$TMPDIR`. Exposing them solely under lazy `packages.aky-oracle`, `checks.{lean-audit, quint-check, drt}`, and `devShells.formal` guarantees hosts and daily developers never download or compile Lean/Quint!
3. **`nix-wrapper-modules` Earns Its Keep Selectively (`W-Hybrid`):** Only `+101 ms` eval overhead and eliminates v1's `foot.nix` double-implementation (100 LOC of `hjem` + duplicated wrapper → ~20 LOC single wrapped package serving both `nix run` and NixOS hosts!). Simple standalone tools/binaries still use raw `nixpkgs` directly (`X2`).
