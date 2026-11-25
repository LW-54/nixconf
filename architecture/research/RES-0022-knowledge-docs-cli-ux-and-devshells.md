---
id: RES-0022
title: Stage 3C.3 Research — Knowledge & Documentation Architecture (A-012), Agent-Native CLI UX & Portable DevShells/Templates
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: knowledge-ux
tags: [research, stage-3c3, diataxis, docs-as-code, context-engineering, agents-md, clig, cli-ux, mdbook, zola, zensical, devshells, mkShell, nix-direnv, templates, nixprof, a-012]
assumptions: [A-012]
summary: First-principles academic, empirical, and 2025-2026 ecosystem research for Stage 3C.3 (A-012) backed by EXP-0014: covers Diataxis & Docs-as-Code SSOT, ETH Zurich 2026 / Lost-in-the-Middle / Anthropic context engineering studies, CLI-vs-MCP ambient token economics, clig.dev & agent-native CLI ergonomics, Rust SSG comparison (mdBook vs Zola vs Zensical), folding nixprof & menu into unified aky, and stratified pure pkgs.mkShellNoCC + nix-direnv + flake.templates portability.
---

<!-- abstract:start -->
## Executive Abstract

Conducts a first-principles literature review, v1 audit, and live empirical evaluation ([`EXP-0014`](../experiments/EXP-0014-docs-churn-ssg-and-token-benchmark.md)) across the three pillars of **Stage `3C.3`** (**Knowledge & Docs `A-012`**, **Unified `aky` CLI/UX**, and **Portable DevShells & Project Templates**):
1. **Documentation & Knowledge (`A-012` Empirically Validated!)**: Grounded in **Daniele Procida's Diátaxis** (*Tutorials, How-To, Reference, Explanation*), **Docs-as-Code SSOT** (separating authoritative primary sources from derived build artifacts), **Liu et al. (*Lost in the Middle*, TACL 2024)**, **Anthropic Context Engineering (2025)**, and **ETH Zurich (*Gloaguen et al., arXiv:2602.11988*, 2026 — proving bloated auto-generated repo context files degrade coding-agent accuracy by `~3%` while inflating token cost `> 20%`!)**. Auditing v1 proved committed generated `docs/` (`168` files, `3.26 MiB`, `853k` tokens) caused **`75.1%` of ALL historical Git line churn on `main`** (`72/130` commits) and a `~12 s` pre-commit Nix eval tax! Moving generated Reference out of Git into a CI-built + Tailnet-hosted **`mdBook 0.5.4`** site (`1.39 s` build, `61.6 MiB` Rust closure) while retaining a `< 800`-token guardrail `AGENTS.md`, `architecture/` Explanation/ADRs, and `< 10 ms` Rust `aky doc audit` eliminates `75%` of Git churn and cuts agent entry context **`103×`–`277×`**!
2. **Unified Agent-Native CLI UX (`clig.dev` + Zero-Ambient-Token Design)**: Consolidates v1's 8 fragmented interfaces (`Justfile` 181 LOC, `meta/menu/` 829 LOC Nix fzf script, `meta/docs/`, `meta/graph/` 5,300 LOC, `meta/prof/`, `.#test`, `.#ci`) into a single compiled Rust binary **`aky`** (with `nixprof` folded into the workspace as `aky prof`!) following `clig.dev` + 2025–2026 agent-native CLI contracts (strict `stdout`/`stderr` separation, auto-TTY / `--json`, semantic exit codes, self-correcting structured error hints, copy-pasteable `--help` examples, `clap_complete`/`clap_mangen`, and `0` ambient prompt tokens vs. always-loaded MCP schemas!). Pairs cleanly with an optional **~30-line human-shortcut `Justfile`** (or pure `aky`-only).
3. **Portable DevShells & Project Templates (`X4`, `QA-09`)**: Honors v1's empirical lesson rejecting `devenv` (`~4 s` eval overhead + impure `PWD`/`TMPDIR` hacks) in favor of pure **`pkgs.mkShellNoCC`** + **`nix-direnv 3.2.0`**, cleanly stratified into **`devShells.default`** (lean daily driver), **`devShells.formal`** (isolated Lean 4 / Quint / Rust verification so daily edits never download heavy toolchains), **ephemeral capability shells** (`admin-sops`, `admin-github`, `admin-breakglass` w/ `$TMPDIR` trap shred per `ADR-0011`), and reusable **`flake.templates`** (`rust` w/ `LW-54/rust-env`, `python`, `nix-pkg`, `docs`)!
<!-- abstract:end -->

# RES-0022: Knowledge, Documentation (`A-012`), Agent-Native CLI UX & Portable DevShells

---

## 1. Pillar 1 — Knowledge & Documentation Architecture (`A-012`)

### 1.1 Foundational Literature
1. **Daniele Procida — *Diátaxis Documentation Framework***: Partition all documentation strictly across four orthogonal cognitive quadrants:
   - **Tutorials** (*learning-oriented*): e.g., `README.md` 5-minute quickstart / onboarding a new host.
   - **How-To Guides** (*goal-oriented*): e.g., hand-written runbooks in `docs/guides/` (Break-Glass Recovery, Adding a Host, Rotating Secrets, Restoring from R2/`hbox`).
   - **Reference** (*information-oriented*): dry, factual, **100% auto-generated** schemas, Agents, Promises, Policies, CLI flags, Packages, DevShells, and SST graphs.
   - **Explanation** (*understanding-oriented*): `architecture/` (`CHARTER.md`, `SPEC-FOUNDATION`, `PAPER-FOUNDATION`, `ADR-0002..0016`, `RES-*`, `EXP-*`).
   - *Key Failure Mode in v1*: Mixing hand-written prose and massive generated Reference inside Git caused every tiny code refactor to generate thousands of lines of noisy diffs (`75.1%` of all churn!).
2. **Docs-as-Code & Single Source of Truth (Knuth *Literate Programming* 1984; Parnas *Rational Design Process* 1986)**: Authoritative documentation lives **in one place** alongside the source code (`*.toml` boundary `description`, Nix option `description`, Rust `///`, Lean 4 `/-- ... -/`, hand-written ADRs & runbooks). Generated HTML/Markdown sites are **compiled build artifacts** — committing them to Git is equivalent to committing `target/` or `.o` binaries!
3. **Empirical LLM Context Engineering Literature (2024–2026)**:
   - **Liu et al. (*Lost in the Middle*, TACL 2024)**: Attention degrades sharply over bloated contexts; stuffing redundant generated docs actively hurts reasoning accuracy.
   - **Anthropic (*Effective Context Engineering for AI Agents*, 2025)**: Optimal agent harness combines a **minimal, high-signal upfront guardrail manifest** with **Just-in-Time (JIT) programmatic inspection** (`rg`, `aky --json`, sliced file reads).
   - **ETH Zurich (*Gloaguen et al., arXiv:2602.11988*, 2026 — Empirical Evaluation of `AGENTS.md` / `CLAUDE.md` on SWE-bench & AGENTbench)**: Auto-generated verbose repository overviews **decreased task success by `~3%` while increasing token cost by `> 20%`**! Minimal human-curated executable guardrails (*"use `aky check`, never `nix flake check` during iteration; never interpolate `${self}`"*) gave positive value without token bloat.
   - **`llms.txt` (Jeremy Howard / Answer.AI)**: Clean machine-readable cover-letter index published alongside the static site for external/web AI consumers without polluting Git.

### 1.2 v1 Audit vs. v2 Architecture (`EXP-0014`)
- **What v1 got right (MUST preserve!)**:
  - **`100%` Documentation Coverage Audit** (`meta/docs/audit.nix`): Mechanically verifying every Agent, Promise, Policy, Package, DevShell, and Option carries a non-placeholder description and type — moved into Rust **`aky doc audit`** (`< 10 ms` zero-Nix for boundaries, plus Nix option check in CI!).
  - **Zero Special Cases**: Adding a new Agent/Package/DevShell automatically appears in generated Reference.
- **What v1 broke (FIXED by `A-012`)**:
  - Eliminating `168` committed generated files (`3.26 MiB`, `45,517` lines, `853k` tokens) removes **`75.1%` of historical Git churn**, eliminates `~12 s` pre-commit Nix docs evaluation, and shrinks agent entry context **`103×`–`277×`**!
- **Dual Publication (Offline-Capable + Public/Mesh)**:
  - **CI Static Site Build (`~1.4 s`)**: Deployed automatically to **GitHub Pages** (and optionally baked into `astrolabe`'s Caddy static `docs.<tailnet>.ts.net` vhost at **`0 MiB` runtime RAM** so full searchable docs work even offline / if GitHub is down!).
  - **Local Preview**: `aky doc serve` builds and serves locally in `~1.4 s`.

### 1.3 Static Site Generator Comparison (Empirically Tested in `EXP-0014` on All 168 Real Files)
| Option | Build Time (`168` files) | Nix Closure | Runtime Stack | Search | Trade-Offs |
| :--- | ---: | ---: | :--- | :--- | :--- |
| **`DOC-MdBook`** *(Recommended)* — **`mdBook 0.5.4`** (+ `mdbook-mermaid`, optional `pagefind`) | **`1.39 s`** | **`61.6 MiB`** *(smallest!)* | Pure Rust | Built-in client-side (or `Pagefind`) | Zero theme maintenance; rock-solid (`Rust Book`, `Nixpkgs Manual`); clean dark/light UI; instant offline HTML |
| **`DOC-Zola`** — **`Zola 0.23.6`** + `Pagefind 1.5.2` | **`0.55 s`** | `102.1 MiB` | Pure Rust | Built-in JS or `Pagefind` (`1.06 s`) | Fastest build & smallest output (`5.28 MiB`), but requires authoring/maintaining custom Tera HTML/CSS templates or an external theme flake input |
| **`DOC-Zensical`** — **`Zensical 0.0.72`** (Material-for-MkDocs successor) | `11.50 s` (`8.3×` slower) | `274.1 MiB` (`4.5×` heavier) | Python 3.14 + Rust | Built-in Material | Gorgeous Material aesthetic out-of-the-box, but heavy Python closure and pre-1.0 (`0.0.72`) API churn risk |

*(Astro Starlight rejected for heavy Node/`node_modules` Nix derivation maintenance under `CHARTER.md` `D > C`.)*

---

## 2. Pillar 2 — Unified Agent-Native CLI UX & Profiling (`aky`)

### 2.1 Foundational Literature
- **Command Line Interface Guidelines (`clig.dev` — Prasad, Firshman, Tashian, Parish)**: Human-first ergonomics: discoverable help, concise defaults, meaningful exit codes, `NO_COLOR`, shell completions, manpages, never hanging on unexpected stdin prompts.
- **Agent-Native CLI Design & The CLI-vs-MCP Token Economy (2025–2026)**:
  - Always-mounted MCP servers carry an **ambient prompt-token tax** (dozens of JSON tool schemas injected into every turn!).
  - A **dual human + agent CLI** (`aky`) costs **`0` ambient tokens** until called, composes with Unix pipes (`jq`, `rg`, `duckdb`), and implements five concrete contracts:
    1. **Strict Stream Separation**: `stdout` = pure structured data; `stderr` = human progress, warnings, structured errors.
    2. **Auto-TTY + Explicit `--json`**: Colored tables & `miette`-style error spans on interactive terminals; automatic compact JSON when piped (`!isatty`) or with `--json`.
    3. **Semantic Exit Codes**: `0` OK, `2` bad CLI usage, `3` boundary/invariant/Cedar failure, `4` auth/permission denied, `5` transient/retryable network/lock failure.
    4. **Self-Correcting Error Payloads (`stderr` JSON in non-TTY)**: `{code, message, retryable, hint}` (e.g., `"hint": "run 'aky secrets sync' to regenerate .sops.yaml"`) so agents recover in 1 turn instead of looping!
    5. **Few-Shot `--help` Examples + Minimal `SKILL.md` / `AGENTS.md`**: Every subcommand's `--help` opens with 2–3 concrete copy-paste examples.

### 2.2 Consolidating v1's 8 Fragmented Entry Points into One `aky` Workspace (`crane`)
| v1 Fragmented Tool | v1 Cost / Pain | v2 Unified `aky` Subcommand |
| :--- | :--- | :--- |
| `meta/graph/` (`5,300` LOC Nix) | Slow Nix eval, custom graph DSL | **`aky check` / `aky inspect` / `aky list` / `aky graph`** (`2.4 ms` zero-Nix Rust over SST $\gamma(3,4)$!) |
| `meta/docs/` (`~1,200` LOC Nix + `sync.rs`) | `~12 s` Nix eval, `75.1%` Git churn | **`aky doc {audit,build,serve}`** (`< 10 ms` audit + `1.39 s` `mdBook` build!) |
| `meta/prof/` (`nixprof` separate Rust crate) | Separate `Cargo.toml`/`Cargo.lock` | **`aky prof {trace,cache-diff,ci,compare}`** (workspace crate `crates/aky-prof`, shared `crane` deps!) |
| `meta/menu/` (`829` LOC Nix TSV fzf script) | Giant brittle Nix string builder | **`aky menu`** (tiny fuzzy launcher reading `aky list --json` into `fzf`/`skim` — `< 80` LOC Rust!) |
| `sops` + `.sops.yaml` manual drift | Manual key-sync drift | **`aky secrets {sync,gen,audit,revoke}`** (`ADR-0011`) |
| `nixos-rebuild` / `comin` / `nvd` | Local `662–906 MiB` eval | **`aky pull` / `aky switch` / `aky diff`** (`ADR-0013` TUF pull + `dix 3.0.0`!) |
| NATS batch jobs & cold Parquet queries | N/A in v1 | **`aky worker` / `aky job` / `aky status` / `aky query --cold` / `aky mcp`** (`ADR-0014`, `ADR-0015`) |

### 2.3 `Justfile` Boundary Trade-Off
- **`CLI-AkyPlusThinJust`** *(Recommended)*: Keep a tiny **~30-line `Justfile`** solely as human muscle-memory wrappers around common Nix/repo tasks (`just check-host`, `just test-vm`, `just fmt`, `just switch`), delegating ALL real logic to compiled, unit-tested, standalone `aky`! Zero bash logic in `Justfile`.
- **`CLI-AkyOnly`**: Delete `Justfile` completely; fold `aky fmt` and `aky test` directly into `aky` so there is strictly **one** command (`aky`) to remember. *(Trade-off: slightly more Rust glue wrapping `nix build` / `alejandra`, whereas `Justfile` is a ubiquitous 30-line repo task index.)*

---

## 3. Pillar 3 — Portable DevShells & Project Templates (`X4`, `QA-09`)

### 3.1 v1 Audit & 2025–2026 Nix Ecosystem Evaluation
- v1 already empirically rejected **`devenv`** (documented in [`meta/devenv/default.nix`](../../meta/devenv/default.nix) L1–2: eliminated `~4 s` flake eval overhead and impure `PWD`/`TMPDIR` hacks!) and adopted pure **`pkgs.mkShellNoCC`** + `direnv`/`nix-direnv`.
- **`numtide/devshell`** adds a TOML-in-Nix menu DSL that duplicates our own `aky` CLI.
- **Pure `pkgs.mkShellNoCC` + `nix-direnv 3.2.0` (`DEV-PureStratified`)** aligns 100% with `ADR-0009` (`P1` plain `flake.nix` + `W-Std` zero-dep wrappers):
  1. **Stratified Repo DevShells** *(never force Lean 4 / JVM downloads on everyday Nix/TOML edits!)*:
     - **`devShells.default`** *(Lean Daily Driver)*: `aky`, `just`, `alejandra`, `statix`, `deadnix`, `sops`, `age`, `dix`, `gitleaks`, `gh`, `duckdb`, `nix-output-monitor`, `nix-fast-build`, `mdbook`, `fzf`, `jq`.
     - **`devShells.formal`** *(Formal & Rust Verification)*: extends `default` with `lean4`, `quint`, `rustc`, `cargo`, `clippy`, `rustfmt`, `cargo-deny`, `rust-analyzer`.
     - **Ephemeral Operational Capability Shells (`ADR-0011` `C-Pragmatic`)**: `devShells.admin-sops`, `devShells.admin-github`, `devShells.admin-breakglass` — lazily unlocking Vaultwarden / short-lived tokens into `$TMPDIR` tmpfs and securely wiping on `EXIT` trap!
  2. **Portable Project Templates (`flake.templates`) & Standalone Tools (`X4`, `QA-09`)**:
     - `nix flake init -t github:LW-54/antikythera#rust` (integrating **`LW-54/rust-env`** strict Clippy/deny + `crane` + `pkgs.mkShellNoCC` + `.envrc`!)
     - `nix flake init -t github:LW-54/antikythera#python` (lean `uv` / `python` + `ruff` + `pkgs.mkShellNoCC` + `.envrc`)
     - `nix flake init -t github:LW-54/antikythera#nix-pkg` (minimal pure `nixpkgs` flake package + `alejandra`/`statix`)
     - `nix flake init -t github:LW-54/antikythera#docs` (`mdBook` + `mdbook-mermaid` + `alejandra`)
     - Plus every standalone Antikythera tool (`nix run github:LW-54/antikythera#{aky,git,...}`) works identically across NixOS, WSL, Ubuntu, and macOS!
