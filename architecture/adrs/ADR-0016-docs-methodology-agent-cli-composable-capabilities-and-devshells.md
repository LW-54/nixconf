---
id: ADR-0016
title: Stage 3C.3 — Documentation Architecture & In-Code Contract (A-012), Agent-Native CLI (`aky`), Composable Capability Supervisor (`aky with`) & Stratified DevShells
type: adr
status: accepted
created: 2026-11-25
updated: 2026-11-25
domain: knowledge-ux
tags: [adr, stage-3c3, docs, mdbook, diataxis, c4-model, arc42, minimalism, rfc145, rustdoc, clig, cli-ux, capabilities, aky-with, devshells, mkShell, nix-direnv, templates, nixprof, a-012]
assumptions: [A-012]
supersedes: []
summary: Ratifies Stage 3C.3 (validating A-012 and completing Stage 3C): DOC-MdBook out-of-Git compiled site (eliminating 75.1% historical Git churn) + Diataxis/Carroll-Minimalist/C4-arc42/g3doc methodology & 5-language idiomatic zero-wrapper in-code doc contract w/ 4 anti-rot gates + CLI-AkyPlusThinJust (unified Rust aky folding nixprof/menu/docs/graph + <=40-LOC zero-logic Justfile) + CAP-AkyWith declarative composable capability supervisor (capabilities/*.toml DAG, RAII RAM tmpfs, scoped ssh-agent) + DEV-PureStratified (pkgs.mkShellNoCC + nix-direnv + flake.templates).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3C.3`** (**Knowledge & Documentation `A-012`, Unified Agent-Native CLI UX, Composable Ephemeral Capability Shells & Portable DevShells/Templates**), completing all of **Stage `3C`** for **Antikythera (`aky`, `LW-54/antikythera`)**, grounded in [`RES-0022`](../research/RES-0022-knowledge-docs-cli-ux-and-devshells.md), [`RES-0023`](../research/RES-0023-documentation-methodology-and-information-architecture.md), and [`EXP-0014`](../experiments/EXP-0014-docs-churn-ssg-and-token-benchmark.md):
1. **Assumption `A-012` Empirically Validated**: Auditing `main` proved committed generated `docs/` (`168` files, `3.26 MiB`, `853k` tokens) accounted for **`75.1%` of all historical line churn** (`341,250 / 454,669` lines across `55.4%` of commits) and a `~12 s` pre-commit Nix tax while burying real info inside 150–300 node spaghetti diagrams and shipping `0` crisis runbooks. Moving generated Reference out of Git cuts agent entry context **`103×`–`277×`** and eliminates `75%` of Git churn.
2. **Documentation Architecture & Tooling (`DOC-MdBook` + Diátaxis × C4/arc42 × Minimalism × `g3doc`)**:
   - **In Git (100% Hand-Authored, `0%` Generated Churn)**: `README.md` (`≤ 150` LOC, C4 L1 `≤ 8`-node diagram), `AGENTS.md` (`≤ 80` LOC / `< 800` tokens pure guardrails per *Gloaguen et al. ETH Zurich 2026*), `docs/tutorials/`, `docs/guides/`, **Carroll-Minimalist 5-part 3 AM Crisis Runbooks** (`docs/runbooks/` w/ `reviewed: YYYY-MM-DD`), `architecture/` (`OVERVIEW.md` living arc42+C4 map + append-only `adrs/`/`spec/`/`experiments/`/`incidents/`), and idiomatic colocated docstrings.
   - **Out of Git (`mdBook 0.5.4`, `1.39 s` build, `61.6 MiB` pure-Rust closure)**: Compiled by `aky doc build` (+ `mdbook-mermaid`, `llms.txt`), served privately on `astrolabe` Tailscale `zone:mesh` (`docs.<tailnet>.ts.net`, **`0 MiB` RAM**, full fleet book usable offline/GitHub-down!), optional privacy-filtered GitHub Pages, and local `aky doc serve`.
   - **5-Language Idiomatic In-Code Contract (Zero Custom Wrappers, `0` `.drv` Cache Busts)**: TOML `description` + generic `[doc.links]` (auto-populating SST `NEAR` edges!) + optional sibling `NOTES.md`; **Nix RFC 145 `/** ... */`** + `mkOption`; Rust `///` (`C-EXAMPLE`/`C-LINK`) + `clap` SSOT; Lean 4 `/-! -/` & `/-- -/`; Quint `///`. Enforced by **4 mechanical anti-rot gates** (`100%` `< 10 ms` coverage audit, C4 `≤ 15–20` node anti-spaghetti cap, CI doctests + link check, and `> 180d` runbook freshness patrol in the Weekly Digest!).
3. **Unified Agent-Native CLI (`CLI-AkyPlusThinJust`)**: Single compiled Rust `aky` binary (`crane` workspace) subsuming `check`, `inspect`, `list`, `graph`, `explain`, `blast-radius`, `secrets`, `pull`, `switch`, `diff`, `worker`, `job`, `status`, `query`, `mcp`, `doc`, `menu`, `with`, and **`aky prof`** (folding `meta/prof/` `nixprof` as workspace crate `aky-prof`!) — following `clig.dev` + zero-ambient-token agent contracts (`stdout`/`stderr` separation, auto-TTY + `--json`, semantic exit codes `0/2/3/4/5`, self-correcting error hints, few-shot `--help`, `clap_complete`/`clap_mangen`). Paired strictly with a **`≤ 30–40`-line zero-logic human-shortcut `Justfile`**.
4. **Composable Ephemeral Capability Framework (`CAP-AkyWith`) & Stratified DevShells (`DEV-PureStratified`)**: Separates **static pure-Nix `pkgs.mkShellNoCC` tool shells** (`default`, `formal`, composable via `inputsFrom`, instant via `nix-direnv 3.2.0`, zero secret prompts or LSP leakage!) from **dynamic declarative capabilities (`capabilities/*.toml` DAG + Rust RAII supervisor `aky with <cap1> <cap2> [-- cmd]`)**: deduplicated 1-prompt Vaultwarden/SOPS unlock, additive non-clobbering SSH keys via a single scoped RAM-tmpfs `ssh-agent` (`$XDG_RUNTIME_DIR`), `conflicts` enforcement, Cedar `L3+` `forbid` blocking AI agents, offline break-glass support, secret-free audit wide events, and portable **`flake.templates#{rust,python,nix-pkg,docs}`**!
<!-- abstract:end -->

# ADR-0016: Stage 3C.3 — Documentation Architecture (`A-012`), Agent-Native CLI, Composable Capability Supervisor & DevShells

## 1. Context & Empirical Motivation

Auditing v1's documentation, developer experience, and operational shells ([`EXP-0014`](../experiments/EXP-0014-docs-churn-ssg-and-token-benchmark.md), [`RES-0022`](../research/RES-0022-knowledge-docs-cli-ux-and-devshells.md), [`RES-0023`](../research/RES-0023-documentation-methodology-and-information-architecture.md)) revealed four systemic pain points:
1. **Committed Generated Docs (`75.1%` Repo Churn, `0` Crisis Runbooks)**: `168` auto-generated Markdown files (`3.26 MiB`, `45,517` lines, `853,311` tokens) accounted for `75.1%` of all line churn on `main` (`72/130` commits) and a `~12 s` pre-commit Nix eval tax. Direct reading of [`README.md`](../../README.md) (`1,005` LOC) and [`docs/hosts/astrolabe.md`](../../docs/hosts/astrolabe.md) (`1,428` LOC) showed `80%+` of page volume was unreadable 100–300 node spaghetti Mermaid diagrams and truncated Nix dumps, while shipping **zero** 3 AM recovery runbooks.
2. **Non-Idiomatic In-Code Doc Wrappers**: v1 wrapped every `lib` function in `{ docstring = ''...''; value = fn; }`, scattered `docs.sections.*` Nix string templates across modules, and added non-standard `meta.usage` fields.
3. **Eight Fragmented Operational Entry Points**: `Justfile` (`181` LOC), `meta/menu/` (`829` LOC Nix fzf builder), `meta/graph/` (`5,300` LOC Nix), `meta/docs/`, separate `meta/prof/` (`nixprof`), `.#test`, `.#ci`, and raw `sops`/`nixos-rebuild`.
4. **Non-Composable Ephemeral Secret Shells**: v1's Nix `devShells` (`sops-admin`, `github-cli`, `github-ssh`, `master-ssh`, `gemini-api`) broke under composition — clobbering `trap EXIT` cleanup handlers (leaking keys), clobbering `GIT_SSH_COMMAND`, prompting Bitwarden twice on nesting, colliding with `nix-direnv` subshells, and exposing terminal env secrets to background LSP/IDE plugins.

---

## 2. Ratified Decisions

### 2.1 Documentation Methodology, Layout & Tooling (`DOC-MdBook`, Validating `A-012`)
- **Strict Diátaxis × C4/arc42 × Carroll Minimalism × Google `g3doc` Separation**:
  - **Authoritative Primary Sources IN GIT (`0%` Generated Churn)**:
    - `README.md` (`≤ 150` LOC): Elevator pitch, **C4 Level-1 System Context diagram (`≤ 8` nodes)**, 5-minute quickstart, links to live `mdBook`, Runbooks, and Architecture.
    - `AGENTS.md` (`≤ 80` LOC / `< 800` tokens): Executable guardrails, narrowest fast-check table, `aky` CLI cheat-sheet, and progressive-disclosure pointers (grounded in *Gloaguen et al. ETH Zurich 2026*).
    - `docs/tutorials/`: Guided end-to-end lessons (`01-first-agent.md`, `02-first-host.md`).
    - `docs/guides/`: Calm builder recipes (`add-host.md`, `add-service-agent.md`, `rotate-secrets.md`, `cold-parquet-forensics.md`).
    - `docs/runbooks/`: **Carroll-Minimalist 5-Part 3 AM Crisis Runbooks** (Frontmatter w/ `reviewed: YYYY-MM-DD`, Trigger/Symptoms, Prerequisites/`aky with`, Numbered Copy-Paste Steps w/ Expected Healthy Output, Failure Branches & Verification):
      - `break-glass-recovery.md`, `stolen-device-revocation.md`, `rollback-and-unbrick.md`, `backup-restore-drill.md`.
    - `architecture/`: Living arc42 + C4 L1/L2 system overview (`OVERVIEW.md`) clearly separated from immutable append-only history (`adrs/`, `spec/`, `paper/`, `research/`, `experiments/`, `incidents/`).
  - **Derived Reference Site OUT OF GIT (`mdBook 0.5.4` + `mdbook-mermaid`)**:
    - Built in `~1.39 s` (`61.6 MiB` pure-Rust Nix closure — `4.5×` smaller and `8.3×` faster than `Zensical 0.0.72` in `EXP-0014`, zero Tera theme maintenance vs. `Zola`) by `aky doc build`.
    - Compiles all hand-authored guides/runbooks/architecture **plus** 100% auto-generated Reference preserving v1's best visual gems: Host **C4 L2 `≤ 15`-node diagrams**, **ASCII storage/persistence trees**, **workload-slice/Btrfs-`squota`/R2-budget tables**, **host-tailored install tracks**, Agent/Promise/Substrate catalogs, Cedar Policy & `capabilities/*.toml` `aky with` Reference, `clap` CLI Reference, Standalone `W-Std` Packages / DevShells / `flake.templates`, Coverage & Freshness Dashboard, and `llms.txt`.
  - **Dual Hosting & Privacy Boundary (`ADR-0012` / `ADR-0013`)**:
    - **Private Full Fleet Book**: Baked into `astrolabe`'s Caddy static **`docs.<tailnet>.ts.net`** (`zone:mesh`, **`0 MiB` runtime RAM**) — works offline / if GitHub is down! (Raw `docs/runbooks/*.md` also live on every host's `~3–15 MiB` offline bare mirror.)
    - **Public / CI Site**: GitHub Pages publishes only non-sensitive architecture/framework docs if the repo is public (never exposing private host internals, Tailnet domains, or secret values); full build also uploaded as CI artifact + instant local preview via `aky doc serve`.

### 2.2 Five-Language Idiomatic In-Code Documentation Contract & Anti-Rot Gates
Retires v1's `{ docstring; value; }` wrappers, `docs.sections.*` Nix strings, and custom `meta.usage` fields in favor of **native language syntax with `0` `.drv` cache busting**:
1. **TOML Boundaries (`agents/*/agent.toml`, `capabilities/*.toml`, `profiles/*.toml`, `policies/*.toml`)**: Mandatory `description` (`≤ 140` chars, timeless present tense); optional per-promise/state/probe `doc` (only when non-obvious); optional generic `[doc.links]` (stored opaquely in `aky-core` as `BTreeMap<String, Vec<String>>` preserving 100% core purity, automatically generating `mdBook` cross-links, `< 5 ms` broken-link checks, and **Semantic Spacetime `NEAR` links** connecting alerts → ADRs & 3 AM runbooks!); optional sibling `NOTES.md` for `> 3`-line caveats. `realize.nix` strips `description`/`[doc]` at eval time → **`0` `.drv` cache busts**.
2. **Nix (`lib/*.nix`, `interior.nix`, `flake.nix`)**: **Standard Nix RFC 145 `/** ... */`** (`nixdoc`: summary, `# Inputs`, `# Type`, `# Examples`) lexed directly by `aky doc` in Rust (**zero Nix eval**), standard `lib.mkOption { description; example; }` (extracted once in CI for Reference), and standard `meta.{description,mainProgram,homepage}`. Comments invisible to Nix → **`0` `.drv` cache busts**.
3. **Rust (`v2/crates/*`)**: Standard `rustdoc` (`//!` / `///` following `C-EXAMPLE` & `C-LINK`, `#![deny(missing_docs)]` on public `aky-core` API, `cargo test --doc`); `clap` doc comments & `after_help` few-shot examples are the single source of truth for `--help`, completions, manpages, and `mdBook` CLI Reference.
4. **Lean 4 (`v2/formal/lean/Aky/**`) & Quint (`v2/formal/quint/*.qnt`)**: Standard `/-! -/` & `/-- -/` (`doc-gen4`/Verso-compatible conceptual meaning & safety invariants) and Quint `///` comments.
5. **Four Mechanical Anti-Rot Gates ("Docs as Tests")**:
   - **Gate 1 — `100%` Coverage Audit (`aky doc audit`, `< 10 ms` zero-Nix)**: Fails on missing/placeholder descriptions/types across TOML/Nix-RFC145/Rust/Lean/Quint (+ Nix `mkOption` check in CI).
   - **Gate 2 — C4 Anti-Spaghetti Cap**: Generator strictly bounds auto-diagrams to 1-hop neighborhoods capped at `≤ 15–20` nodes (auto-grouped by plane/slice); deep graphs explored on demand via `aky graph --focus <id> --depth N`.
   - **Gate 3 — Docs-as-Tests & Link Checking (CI)**: `cargo test --doc` + `aky doc test` (validates TOML examples against `aky-core` schemas & CLI snippets against `clap`) + internal/cross-doc broken-link check.
   - **Gate 4 — Runbook Freshness Patrol**: `aky doc audit` & the **Weekly Operational Digest (`ADR-0015`)** flag any runbook with `reviewed:` older than `180 days`.

### 2.3 Unified Agent-Native CLI & Thin `Justfile` (`CLI-AkyPlusThinJust`)
- **Unified Rust Binary (`aky` in `v2/crates/`, single `crane` workspace)**: Consolidates all domain tooling: `aky {check, inspect, list, graph, explain, blast-radius, resolve, drt, secrets, pull, switch, diff, worker, job, status, query, mcp, doc, with, menu, prof}` — folding v1's `meta/prof/` (`nixprof`) cleanly as workspace crate `crates/aky-prof` and retiring v1's 829-LOC `meta/menu/` Nix TSV script in favor of `< 80` LOC `aky menu` reading `aky list --json`.
- **Dual Human + Agent CLI Contract (`clig.dev` + `QA-10`)**:
  - Strict stream separation (`stdout` = pure data; `stderr` = logs/progress/errors).
  - Rich ANSI tables & diagnostics on TTY; automatic compact JSON when piped (`!isatty`) or with `--json` (`NO_COLOR` respected).
  - Semantic exit codes (`0` OK, `2` CLI usage, `3` boundary/invariant/Cedar violation, `4` auth/permission denied, `5` transient/retryable I/O/network) + structured `{code, message, retryable, hint}` JSON errors on non-TTY `stderr`.
  - Few-shot copy-paste examples at top of `--help`, `clap_complete` shell completions, and `clap_mangen` manpages.
  - **Zero ambient prompt tokens** for coding agents using shell (`aky ... --json`), while `aky mcp` serves Biscuit-scoped read-only remote/GUI MCP clients.
- **Strict `Justfile` Boundary (`≤ 30–40` lines, zero bash logic)**: Retained solely as zero-recompile human muscle-memory wrappers around repo-local Nix/formatter invocations (`fmt`, `lint`, `check-host`, `test-vm`, `build-host`) so repo shortcuts work even mid-Rust-refactor; zero business logic or `if/for` control flow permitted in `Justfile`.

### 2.4 Composable Ephemeral Capability Framework (`CAP-AkyWith`) & Stratified DevShells (`DEV-PureStratified`)
- **Static Tool Layer — Pure `pkgs.mkShellNoCC` + `nix-direnv 3.2.0` (Zero `devenv`, Zero Secret Prompts)**:
  - **`devShells.default`** *(Lean Daily Driver)*: `aky`, `just`, `alejandra`, `statix`, `deadnix`, `sops`, `age`, `dix`, `gitleaks`, `gh`, `duckdb`, `mdbook`, `fzf`, `jq`, `nix-output-monitor`, `nix-fast-build`.
  - **`devShells.formal`** *(Isolated Heavy Verification)*: extends `default` via `inputsFrom` with `lean4`, `quint`, `rustc`/`cargo`/`clippy`/`rustfmt`/`cargo-deny`/`rust-analyzer` (daily edits never download Lean/JVM!).
  - **Portable Project Templates (`flake.templates`)**: `nix flake init -t github:LW-54/antikythera#{rust,python,nix-pkg,docs}` (integrating `LW-54/rust-env` strict Clippy/deny + `crane` + `pkgs.mkShellNoCC` + `.envrc`), alongside standalone `W-Std` packages (`nix run`).
- **Dynamic Capability Layer — Declarative Capability Algebra (`capabilities/*.toml` + Rust RAII Supervisor `aky with`)**:
  - Every ephemeral capability declares `id`, `description`, `requires = [...]`, `conflicts = [...]`, `provides` (`Env`, `RamFile`, `SshKey`, or `Biscuit`), `ttl`, and optional `packages`.
  - **`aky with <cap1> [<cap2> ...] [-- <cmd>]`**:
    1. **DAG Resolution & Deduplication**: Topologically resolves shared prerequisites (e.g., `github-cli` + `r2-admin` both requiring `sops-root` → `vaultwarden-session` unlocks Vaultwarden **once**!).
    2. **Additive Non-Clobbering SSH Composition**: All requested SSH key capabilities (`github-ssh`, `master-ssh`, `breakglass-ssh`) load into **one ephemeral, session-scoped `ssh-agent` Unix socket** inside a `0700` RAM-only tmpfs dir (`$XDG_RUNTIME_DIR/aky-cap-<nonce>/`) with per-key TTL (`ssh-add -t`) and a generated `SSH_CONFIG` — eliminating v1's `GIT_SSH_COMMAND` collisions!
    3. **Kernel-Grade RAII Cleanup**: Rust parent process supervisor + signal handling (`SIGINT`/`SIGTERM`/`SIGHUP`) kills the scoped `ssh-agent` and wipes/unlinks the RAM tmpfs dir unconditionally on child exit or crash — zero bash `trap EXIT` clobbering, zero NVMe secret writes, zero LSP secret leakage!
    4. **Security, Offline Break-Glass & Audit (`ADR-0011` / `ADR-0013` / `ADR-0015`)**: Cedar `L3+` policies explicitly `forbid` `role:ai-agent` from invoking human-root capabilities; `cap:breakglass` operates **100% offline** from cold recovery media (zero Vaultwarden/network requirement); every session emits a **secret-free Observability 2.0 wide event** (`cap_session`) to `VictoriaLogs`; thin standalone `devShells.admin-*` wrappers simply delegate to `aky with` so `nix develop github:LW-54/antikythera#admin-sops` remains portable with zero duplicated logic.

---

## 3. Consequences & Trade-Offs
- **Benefits**: Eliminates `75.1%` of Git diff churn and `~12 s` pre-commit doc tax; cuts agent entry context `103×`–`277×`; guarantees readable C4 diagrams (`≤ 15–20` nodes) and tested 3 AM crisis runbooks reachable offline; retires 4 v1 doc hacks + 8 fragmented CLIs + 5,300 LOC `meta/graph` + 829 LOC `meta/menu` into one idiomatic, zero-cache-busting Rust/Nix architecture; solves multi-secret shell composition cleanly without key leaks or duplicate auth prompts.
- **Trade-Offs Accepted**:
  - `aky doc` maintains lightweight lexers for Nix RFC 145 `/** ... */`, Lean `/-- -/`, and Quint `///` (small, pure Rust, well-tested via `cargo test`) in exchange for `< 10 ms` zero-Nix auditing.
  - `mdBook` has a simpler visual aesthetic than `Zensical`/Material in exchange for `4.5×` smaller closure, `8.3×` faster builds, zero Python dependencies, and rock-solid long-term stability.
  - Maintaining `≤ 40`-line `Justfile` requires enforcing the zero-logic discipline in PR reviews.
