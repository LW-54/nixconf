---
id: AUD-0002
title: Phase 1 Audit — Meta Tooling, Documentation Enforcement, Rust Strategy & Dependencies
type: audit
status: active
created: 2026-11-23
updated: 2026-11-23
domain: tooling
tags: [audit, meta, rust, docs, graph, menu, tack, dependencies, redundancy]
assumptions: [A-003, A-004, A-005, A-012]
git_commit: 90c0b02
summary: Audits all 15,009 LOC of meta/, Justfile, .githooks/, Rust codebases (5,280 LOC across 3 incompatible patterns), documentation blind spots, tool redundancies, and the 15 external inputs pinned via .tack/.
---

<!-- abstract:start -->
## Executive Abstract

Audits `meta/` (74 files, **15,009 LOC — 30% of the entire repo**), `Justfile`, `.githooks/`, `.tack/`, and all Rust code (5,280 LOC) at commit `90c0b02`. **Core findings**: (1) **Massive un-enforced documentation blind spot** — `meta/docs/audit.nix:10` ONLY audits the 6 primitive kinds (`host`, `feature`, `contract`, `implementation`, `lib`, `primitive`) and defaults `docs.strict = false`; all 15k LOC of `meta/`, `Justfile`, `.githooks/`, `.tack/`, and all 5.3k LOC of Rust escape coverage enforcement entirely; (2) **Disproportionate custom graph engine** — `meta/graph/` alone is **5,327 LOC across 33 files** of pure Nix CPG/LPG machinery whose only active consumers are doc Mermaid diagrams and unused `cpg-json`/`graph --stats`; (3) **Overlapping UX surfaces** — 5 overlapping entrypoints (`Justfile`, `meta/menu` 829 LOC, `nix run .#test`, `nix run .#docs`, `nix run .#ci`, `nix run .#graph`, `nixprof`) duplicate host lists and command dispatch (with `Justfile` hardcoding `x86_64-linux`, `astrolabe`, `x240`); (4) **Fragmented Rust methodology** — 3 separate Rust codebases (5,280 LOC) split across two incompatible build styles (single-file zero-dep `rustc` via `runCommandCC` with hand-rolled HTTP/JSON parsers in `hub.rs` & `sync.rs` vs standalone Cargo crate `buildRustPackage` in `meta/prof`), zero Cargo workspace, and zero automated Rust tests (`cargo test`) in CI; (5) **Non-standard `.tack/` pinning** — 1,082 LOC vendored Nix loader replacing `flake.lock`, invisible to standard `nix flake update` / Renovate / Dependabot, with 15 global inputs (including a niche `denful/import-tree` fork and desktop-only flakes).
<!-- abstract:end -->

# AUD-0002: Auxiliary Tooling, Docs Enforcement, Rust & Dependencies Audit

- **Snapshot**: Git commit `90c0b02`

---

## 1. Inventory of `meta/` & Repository Entrypoints (15,009 LOC)

| Component | Files | LOC | Exported Artifacts / Role |
| :--- | ---: | ---: | :--- |
| `meta/graph/` | 33 | **5,327** | `lib.graph`, `packages.{graph,cpg-json,nixconf-json}` — Multi-strata Semantic CPG + Architecture LPG in pure Nix. |
| `meta/prof/` | 13 | **3,597** | `packages.prof` (`nixprof`) — Rust CLI (Cargo crate): trace/flamegraph, bench, cache-diff, CI telemetry, Prometheus metrics. |
| `meta/docs/` | 15 | **3,408** | `packages.docs`, `checks.docs` — Pure-Nix doc registry + 957-LOC Rust `sync.rs` materializer generating 169 Markdown files (`README.md` + `docs/**`). |
| `meta/ci/` | 6 | **1,007** | `packages.ci`, `checks.ci` — Generates `.github/workflows/{build,host-tests}.yml` from Nix + `actionlint`. |
| `meta/menu/` | 1 | **829** | `packages.menu` — `fzf` interactive command/package/devshell/secrets launcher. |
| `meta/tests/` | 4 | **783** | `packages.test` (`nixconf-test`) — Bash wrapper orchestrating `eval`/`inspect`/`vm`/`install`/`scenario`/`run` tiers. |
| `meta/devenv/` | 1 | 53 | `devShells.default` — Lightweight `mkShellNoCC` dev toolchain. |
| `meta/formatter.nix` | 1 | 5 | `formatter` (`alejandra`). |
| `Justfile` | 1 | 181 | 31 user-facing task recipes (default invokes `menu`). |
| `.githooks/` | 2 | 183 | `pre-commit` (149 LOC — staged `alejandra`, single-eval docs/ci/schemas/evals, local metrics) + hook installer. |

---

## 2. Structural Root Cause of Un-Enforced `meta/` Documentation

The user explicitly observed *"documentation for `meta` doesn't seem enforced well"*. Direct code inspection pinpoints **three exact structural causes**:

1. **Primitive-Only Audit Scope** (`meta/docs/audit.nix:10`):
   ```nix
   kinds = ["host" "feature" "contract" "implementation" "lib" "primitive"];
   ```
   Every file in `meta/` (`meta/ci`, `meta/docs`, `meta/graph`, `meta/menu`, `meta/prof`, `meta/tests`, `meta/devenv`, `meta/formatter.nix`) is a raw `flake-parts` module, **not** an instance of those 6 primitives. Therefore `audit.nix` completely ignores all 74 files / 15,009 LOC of `meta/`, plus `Justfile`, `.githooks/`, `.tack/`, and all Rust sources!
2. **Non-Strict Default** (`meta/docs/options.nix:83-87`): `docs.strict` defaults to `false`, so even inside audited primitives, missing docstrings only emit a warning to stderr instead of failing CI.
3. **Manual Prose Drift**: Pages under `meta/docs/pages/` and `meta/*/docs.nix` are hand-wired ad-hoc via `docs.pages.<name>.sections` with zero verification that every exported package, script, CLI flag, or subsystem has an up-to-date architectural doc.

---

## 3. Tool Redundancies, Overlaps & Disproportionate Complexity

| Redundancy / Complexity Hotspot | Evidence | Architectural Smell |
| :--- | :--- | :--- |
| **`meta/graph/` (5,327 LOC, 33 files in Nix)** | Implements a full multi-strata Code Property Graph (CPG), algebraic slicing, LPG projection functors, and source regex extractors *inside Nix* (slow dynamic string/attrset manipulation, uses `self + "/..."` in `source.nix`). | Massive maintenance & eval-complexity surface whose primary consumer today is generating Mermaid diagrams in `docs/`! If graph/index analysis is genuinely needed (e.g., for impact analysis & LLM context), a compiled Rust tool parsing clean JSON/AST would be 10× faster, typed, unit-testable, and far smaller. |
| **`Justfile` vs `meta/menu` vs `meta/tests`** | `Justfile` (181 LOC) hardcodes `x86_64-linux`, `eval-astrolabe`, `eval-x240`, AND wraps `nix run .#test`, `nix run .#docs`, `nix run .#ci`, `nix run .#graph`, AND calls `menu` (829 LOC), which *itself* re-introspects `config.packages`, `config.devShells`, `topConfig.host`, and `internal.graph` to launch the same commands! | Three overlapping command-discovery & dispatch layers (`Justfile`, `menu`, `nixconf-test`) that must be kept in sync manually and double-evaluate the flake when invoked naively (`nix run .#test` evaluates flake twice!). |
| **Six Separate `meta/*` CLIs** | `nixconf-docs`, `nixconf-ci`, `nixconf-graph`, `nixconf-test`, `menu`, `nixprof` — 5 are Nix-generated Bash wrappers + 1 Cargo Rust binary + 1 zero-dep Rust helper (`sync.rs`). | Fragmented CLI UX, duplicated flag parsing/help templates, zero shared library/error handling, inconsistent output formats (no uniform `--json` contract for AI agents). |
| **In-Repo Generated Docs Churn (169 files)** | Every minor option/module edit regenerates and commits diffs across `README.md` + `docs/**/*.md` (169 tracked files), requiring pre-commit synchronization on every commit. | Heavy Git diff noise; open question for `RFD-0008` whether generated human docs belong out-of-repo (static site/artifact) vs in-repo. |

---

## 4. Rust Codebase & Build Strategy Audit (5,280 LOC Total)

There are currently **three completely disconnected Rust components** built with **two incompatible methodologies**:

| Component | Path | LOC | Dependencies | Build Mechanism | Automated Tests? |
| :--- | :--- | ---: | :--- | :--- | :---: |
| **`nixprof`** | `meta/prof/` (10 `.rs` + `Cargo.toml`) | 3,597 | `clap`, `inferno`, `libc`, `serde`, `serde_json` | `pkgs.rustPlatform.buildRustPackage` + `makeBinaryWrapper` | **None in CI** |
| **`nixconf-docs-sync`** | `meta/docs/sync.rs` (single file) | 957 | **Zero** (hand-rolled JSON parser + Mermaid renderer + scanner) | `pkgs.runCommandCC` invoking raw `rustc -C opt-level=3` | **None** (indirect via `checks.docs`) |
| **`agy-hub`** | `modules/features/antigravity/hub.rs` (single file) | 1,228 | **Zero** (hand-rolled HTTP server + JSON + HTML + PTY/process mgmt) | `pkgs.runCommandCC` invoking raw `rustc -O` | **None** |

### Key Structural Problems with Current Rust Usage
1. **No unified workspace or policy**: Decisions between "hand-roll a 1,200-line zero-dep HTTP/JSON parser with raw `rustc`" vs "use Cargo + `serde` + `buildRustPackage`" were made ad-hoc per task.
2. **Duplicated low-level plumbing**: Custom JSON/string escaping/HTTP parsing is reinvented across `sync.rs` and `hub.rs`, while `meta/prof` pulls in `serde_json`.
3. **Zero Rust quality gates**: Neither `cargo test`, `cargo clippy`, nor `rustfmt --check` runs in `.githooks/pre-commit` or GitHub Actions CI!
4. **Slow cold/incremental rebuilds**: `buildRustPackage` rebuilds all crate dependencies from scratch on *any* `meta/prof/src/*.rs` change (unlike dependency-splitting builders such as `crane` or `naersk`).
5. **Untracked local `target/` artifact**: `meta/prof/target/` can accumulate local build artifacts outside Nix if `cargo` is invoked interactively (must be cleanly gitignored & excluded via `lib.fileset`).

---

## 5. External Dependency & Pinning Audit (`.tack/pins.toml`)

### 5.1 `.tack/` Custom Input Manager (1,082 LOC vendored Nix)
`flake.nix` has **no `inputs = { ... };` block and no `flake.lock`**. Instead it calls `(import ./.tack) { ... }` (`github:manic-systems/tack`, 1,082 LOC vendored into `.tack/default.nix`) which loads `.tack/pins.lock.json` via `builtins.fetchTree` inside `outputs`.

| Property | `.tack` (Current) | Standard `flake.nix` + `flake.lock` (Reference) |
| :--- | :--- | :--- |
| Recursive `follows` deduplication | Excellent (`[all_follow]` in 4 lines) | Verbose manual `inputs.nixpkgs.follows` per input |
| Commit signer verification / patches / tag tracking | Built-in (`[signers]`, `patches`, `tag`) | Not built-in |
| Ecosystem compatibility (GitOps, Renovate, `nix flake update`, `nix flake metadata`, `Determinate`/CI bots, `nix run github:LW-54/nixconf`) | **Poor / Non-standard** — `nix flake metadata` shows 0 inputs; standard update automation does not understand `pins.toml`; requires `tack` binary & vendored 1,082-LOC loader; impure/non-standard `fetchTree` inside `outputs` may face future Nix flake purity friction | **Universal standard** |

*(Must be evaluated rigorously and empirically in `RFD-0001` & `RFD-0005`!)*

### 5.2 Complete External Input Inventory (15 Pins)

| Input | Upstream | Category | Risk / Weight Assessment |
| :--- | :--- | :--- | :--- |
| `nixpkgs` | `NixOS/nixpkgs/nixos-unstable` | Core OS | Essential standard |
| `systems` | `nix-systems/default` | Core | Tiny standard (only 4 systems) |
| `flake-parts` | `hercules-ci/flake-parts` | Composition | Mature standard — evaluate whether needed vs plain `evalModules` in `RFD-0001` |
| `import-tree` | **`denful/import-tree`** | Composition | **Risk**: Personal/niche fork (vs `vic/import-tree` or 15 lines of native Nix) |
| `flake-schemas` | `DeterminateSystems/flake-schemas` | Meta/Schemas | Niche / Determinate-specific; adds schema weight with minimal external tooling payoff |
| `tack` | `manic-systems/tack` | Pinning | **Risk**: Young/niche custom replacement for `flake.lock` |
| `wrapper-modules` | `nix-community/nix-wrapper-modules` | Portability | Used in only 2 files (`foot`, `git`) today, yet high strategic potential for `QA-09` standalone portability |
| `hjem` | `feel-co/hjem` | Home files | Lightweight alternative to `home-manager`; NixOS-only (cannot run standalone on non-NixOS!) |
| `sops-nix` | `Mic92/sops-nix` | Secrets | Mature standard |
| `impermanence` | `nix-community/impermanence` | Persistence | Mature standard (bare-metal/VPS only; incompatible with WSL/Live ISO) |
| `disko` | `nix-community/disko` | Disk layout | Mature standard (bare-metal/VPS/installer only; incompatible with WSL) |
| `nix-index-database` | `nix-community/nix-index-database` | UX | Optional CLI lookup DB |
| `antigravity-nix` | `jacopone/antigravity-nix` | Agent CLI/IDE | Community packaging for Antigravity |
| `helium` | `oxcl/nix-flake-helium-browser` | Desktop app | Niche single-user browser flake in global lock |
| `noctalia` | `noctalia-dev/noctalia` | Desktop shell | Desktop-only shell in global lock |

> **Structural observation**: All 15 inputs sit in a single flat global lock — so a headless VPS (`astrolabe`) or `aarch64` Raspberry Pi shares lock/update coupling with niche desktop flakes (`helium`, `noctalia`) and schema/doc frameworks (`flake-schemas`).
