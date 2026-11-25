---
id: RES-0023
title: First-Principles Documentation Methodology — Information Architecture, Cognitive Load, C4/arc42/Diátaxis Synthesis, Anti-Rot Verification & Dual Human/Agent Design
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: knowledge-ux
tags: [research, stage-3c3, documentation-methodology, diataxis, minimalism, carroll, cognitive-load, sweller, c4-model, arc42, g3doc, mvd, freshness, runbooks, docs-as-tests, dual-audience, a-012]
assumptions: [A-012]
summary: Ground-up methodological study of the documentation itself (distinct from SSG tooling in RES-0022): audits v1's actual rendered docs (1,005-line README, 1,428-line astrolabe.md, 150-node spaghetti Mermaid diagrams, zero 3 AM crisis runbooks), synthesizes Diataxis + Carroll Minimalism + Sweller Cognitive Load + C4/arc42 + Google g3doc MVD/freshness + Docs-as-Tests, defines 4 concrete reader personas, specifies the exact Git-vs-Generated boundary, anti-spaghetti diagram invariants, minimalist runbook template, and 4 mechanical anti-rot gates.
---

<!-- abstract:start -->
## Executive Abstract

Establishes a **first-principles, methodical architecture for Antikythera's documentation content itself** — separating *what we write, for whom, how it is structured, and how we prevent decay* from the static-site generator tooling (`DOC-MdBook`, `RES-0022`):
1. **Honest Audit of v1's Rendered Documentation**: Inspecting [`README.md`](../../README.md) (`1,005` lines), [`docs/hosts/astrolabe.md`](../../docs/hosts/astrolabe.md) (`1,428` lines), and [`docs/contracts/backup.md`](../../docs/contracts/backup.md) (`741` lines) revealed a stark split:
   - *Genuine Gems to Preserve*: Clean ASCII storage/persistence trees, concise workload-tier & budget tables, host-tailored install tracks, and the `100%` mechanical coverage audit ([`docs/coverage.md`](../../docs/coverage.md)).
   - *Severe Cognitive Failures to Eliminate*: `80%+` of major pages consisted of **unreadable 100–300 node spaghetti Mermaid diagrams** (e.g., `astrolabe.md` included `x240` modules and unrelated `devShells` via multi-hop graph edges!) and single-line `2,000`-char truncated Nix dumps; meanwhile, despite `168` generated files (`3.26 MiB`), v1 had **ZERO step-by-step 3 AM crisis runbooks** (break-glass recovery, stolen-device revocation, rollback/unbrick, restore drills)!
2. **Theoretical Synthesis**: Unifies **Daniele Procida's Diátaxis** (strict 4-quadrant separation), **John Carroll's Minimalism (*The Nurnberg Funnel*, 1990)** & **John Sweller's Cognitive Load Theory (1988)** (task-first random access, error recognition/recovery, eliminating extraneous load), **Simon Brown's C4 Model** + **arc42** (explicit zoom levels: Context → Containers → Components → Code), **Google `g3doc` Minimum Viable Documentation (MVD)** (colocation, timeless prose, explicit `reviewed: YYYY-MM-DD` freshness decay budgets), and **Dual Human/Agent Design** (*Gloaguen et al. ETH Zurich 2026*, *Anthropic 2025*).
3. **Four Concrete Reader Personas & Strict Content Blueprint**: Explicitly designs distinct entry points for (A) *3 AM Stressed Operator*, (B) *Calm Builder 6 Months Later*, (C) *System Thinker / External Reviewer*, and (D) *AI Coding/Ops Agent* — pairing concise hand-authored primary sources in Git (`README.md ≤ 150 LOC`, `AGENTS.md ≤ 80 LOC / < 800 tokens`, `docs/tutorials/`, `docs/guides/`, `docs/runbooks/`, `architecture/`) with **compiled C4-scoped Reference** in `mdBook` (hard **≤ 15–20 node anti-spaghetti diagram cap**!).
4. **Four Mechanical Anti-Rot Verification Gates ("Docs as Tests")**: (1) `< 10 ms` `100%` boundary/option coverage audit (`aky doc audit`), (2) C4 diagram complexity cap, (3) CI link checking + executable TOML/CLI/Rust doctests (`aky doc test` + `cargo test --doc`), and (4) `> 180d` runbook freshness alerts surfaced automatically in the Weekly Operational Digest (`ADR-0015`).
<!-- abstract:end -->

# RES-0023: First-Principles Documentation Methodology & Information Architecture

---

## 1. Empirical Audit of v1's Actual Rendered Documentation

Tooling alone cannot fix bad information architecture. Direct inspection of v1's generated files exposed exact structural strengths and failures:

### 1.1 High-Value Elements Worth Preserving in v2
- **Scannable Physical & State Maps** ([`docs/hosts/astrolabe.md`](../../docs/hosts/astrolabe.md) L1200–1269): ASCII disk/subvolume trees and `/persist` state trees answer *"what survives a reboot on this host?"* in 5 seconds.
- **Compact Budget & Resource Tables** (`astrolabe.md` L1279–1316): Workload tiers (`critical.slice` … `background.slice`), Btrfs/local volumes, and remote storage budgets in tight Markdown tables.
- **Host-Specific Copy-Paste Deployment Tracks** (`astrolabe.md` L1377–1428): Concrete, pre-interpolated commands ready to paste without mental substitution.
- **100% Mechanical Coverage Enforcement** ([`docs/coverage.md`](../../docs/coverage.md)): Zero undocumented entities, options, or library symbols.

### 1.2 Cognitive & Operational Failures Found in v1
| Failure Mode | Direct Evidence in v1 | Violated Theory |
| :--- | :--- | :--- |
| **Spaghetti Diagrams (`80%` page bloat)** | [`README.md`](../../README.md) (`1,005` LOC), [`astrolabe.md`](../../docs/hosts/astrolabe.md) (`1,428` LOC), [`backup.md`](../../docs/contracts/backup.md) (`741` LOC) dump 100–300 node multi-hop Mermaid graphs (`astrolabe.md` even pulled in `x240` modules and unrelated `devShells`!) | **Simon Brown C4 Model** (mixing abstraction levels) & **Sweller Cognitive Load** (massive extraneous load) |
| **Unreadable Raw Evaluated Dumps** | `astrolabe.md` L1328 renders a 2,000-char single-line truncated Nix attrset | **Carroll Minimalism** & **Google MVD** |
| **Zero 3 AM Crisis Runbooks** | `168` generated files (`3.26 MiB`), yet **0** tested step-by-step runbooks for break-glass recovery, stolen laptop revocation, rollback/unbrick, or R2/`hbox` restore | **Diátaxis** (100% Reference, 0% How-To) & **Google SRE** |
| **Mixed Quadrants in `README.md`** | `README.md` jammed intro, architecture, 300-node graph, every package, every devShell, and tooling index into 1,005 lines | **Diátaxis** (mixing Orientation, Tutorial, Reference, and Explanation) |
| **Zero Prose Freshness / Snippet Testing** | Generated reference stayed fresh, while hand-written install/admin steps had no freshness dates, link verification, or executable snippet tests | **Google `g3doc`** (freshness decay) & **Docs-as-Tests** |

---

## 2. Foundational Theory Synthesis

Five bodies of research govern **what** we write and **how** we organize it:

1. **Daniele Procida — *Diátaxis* (Strict 2×2 Quadrant Separation)**:
   - Never mix quadrants on the same page!
     - **Tutorials** (*acquisition + action*): Guided end-to-end learning path (*"Build and verify your first Antikythera Agent in 10 minutes"*). Safe, concrete, minimal branching.
     - **How-To Guides & Runbooks** (*application + action*): Goal-oriented recipes for someone who already knows what they want (*"Recover `astrolabe` after total VPS loss"*). Concise, assumes competence, **zero theoretical tangents**.
     - **Reference** (*application + cognition*): Dry, complete, consistent, **100% generated from code/TOML** (Agents, Promises, Policies, Capabilities, Options, CLI flags, Hosts).
     - **Explanation** (*acquisition + cognition*): Why the system is designed this way (`architecture/` — Promise Theory, Semantic Spacetime, ADRs, trade-offs, experiments).
2. **John Carroll — *Minimalism* (*The Nurnberg Funnel*, 1990) & John Sweller — *Cognitive Load Theory* (1988)**:
   - Technical users rarely read sequentially; they arrive **impatient, task-driven, and often stressed**.
   - **Four Minimalist Rules for All Antikythera Guides & Runbooks**:
     1. *Action-first*: Start immediately with trigger conditions and concrete commands (no 3-paragraph preamble!).
     2. *Random-access entry*: Every runbook is self-contained with explicit prerequisites (`aky with ...`) so it works at 3 AM without reading 4 other pages first.
     3. *Built-in error recognition & recovery*: After critical commands, state **what healthy output looks like** AND **what to do if it fails**!
     4. *Ruthless pruning*: Cut extraneous prose so human working memory stays focused on the actual operational task.
3. **Simon Brown — *C4 Model* + *arc42* (Starke & Hruschka)**:
   - Use **arc42** as the concise living architectural narrative (`architecture/OVERVIEW.md`: Goals, Constraints, Context, Building Blocks, Runtime Flows, Deployment, Cross-Cutting Concepts, Risks) and embed **strictly scoped C4 diagrams** at matching zoom levels:
     - **C4 Level 1 (System Context — ≤ 8 nodes)**: Fleet + GitHub/Codeberg + Cloudflare R2 + Hetzner Box + Tailscale + Human Root (lives in `README.md`!).
     - **C4 Level 2 (Containers / Planes — ≤ 12 nodes)**: Trust, Mesh, GitOps/Cache, Storage/Compute, Observability, Docs planes.
     - **C4 Level 3 (Component / 1-Hop Agent View — hard cap ≤ 15–20 nodes)**: One host or Agent + ONLY its direct 1-hop dependencies/promises, automatically grouped by plane/slice!
     - **C4 Level 4 (Code)**: **Never drawn as a giant static graph** — inspect interactively on demand via `aky graph --focus <agent> --depth 1`!
4. **Google `g3doc` — *Minimum Viable Documentation (MVD)* & Freshness Physics**:
   - *"A small set of fresh, accurate docs beats a vast library in disrepair."* Every unverified prose claim is a future trap.
   - **Timeless Style**: Never write *"currently"*, *"new"*, *"recently migrated from v1"* in living docs — state what the system *is*, and leave historical context inside immutable `architecture/adrs/`!
   - **Living Spec vs. Immutable History (*Parnas & Clements 1986*; *Nygard 2011*)**: Living specs (`OVERVIEW.md`, `docs/runbooks/`, `docs/guides/`) are updated in the same PR as code changes; historical records (`architecture/adrs/ADR-*`, `experiments/EXP-*`, `incidents/INC-*`) are **append-only** (never rewritten, only superseded).
   - **Freshness Ownership**: Every hand-authored runbook carries YAML frontmatter `reviewed: YYYY-MM-DD` and `verification: manual-drill | vm-test | ci-doctest`.
5. **Dual-Audience Design (Humans vs. AI Coding Agents — *Gloaguen et al. ETH Zurich 2026*; *Anthropic 2025*)**:
   - **Do NOT write prose essays for AI agents**, and **do NOT force humans to read raw JSON schemas**.
   - **Humans** get: crisp `README.md`, C4 Mermaid diagrams (≤ 15 nodes), Minimalist 3 AM runbooks, and searchable `mdBook` Reference.
   - **AI Agents** get: `< 800`-token guardrail `AGENTS.md` (fast commands + hard invariants), `architecture/INDEX.md` (Layer-0 progressive-disclosure map), **1 canonical worked exemplar per pattern** (few-shot anchor!), and **zero-ambient-token `aky ... --json`** CLI introspection!

---

## 3. Concrete Antikythera Documentation Blueprint

### 3.1 Four Reader Personas & Entry Doors
1. **3 AM Stressed Operator**: `docs/runbooks/*.md` (accessible 3 ways: local bare Git mirror on every host per `ADR-0013`, Tailscale `docs.<tailnet>.ts.net` static mirror at `0 MiB` RAM, and GitHub Pages!).
2. **Calm Builder (6 Months Later)**: `docs/guides/*.md` + searchable `mdBook` Reference + `aky inspect <agent>`.
3. **System Thinker / External Reviewer**: `README.md` (`≤ 150` lines) → `architecture/OVERVIEW.md` (living arc42+C4 map) → `architecture/spec/FOUNDATION.md` & `adrs/`.
4. **AI Coding / Ops Agent**: `AGENTS.md` (`≤ 80` lines / `< 800` tokens) → `architecture/INDEX.md` → `aky check / list / inspect / graph --json`.

### 3.2 Exact Repository Structure (Primary Sources IN Git vs. Derived Site OUT of Git)

```text
IN GIT (Authoritative, Hand-Authored, 0% Generated Churn):
├── README.md                     # ≤ 150 LOC: C4 L1 context, 5-min quickstart, links (Diátaxis: Orientation)
├── AGENTS.md                     # ≤ 80 LOC (< 800 tokens): Guardrails, fast-check table, aky CLI cheat-sheet
├── docs/
│   ├── tutorials/                # Diátaxis: Tutorials (2-3 guided end-to-end lessons)
│   │   ├── 01-first-agent.md
│   │   └── 02-first-host.md
│   ├── guides/                   # Diátaxis: How-To Guides (calm builder recipes)
│   │   ├── add-host.md
│   │   ├── add-service-agent.md
│   │   ├── rotate-secrets.md
│   │   └── cold-parquet-forensics.md
│   └── runbooks/                 # Diátaxis: Crisis How-To (Carroll Minimalist 5-part template + reviewed date!)
│       ├── break-glass-recovery.md
│       ├── stolen-device-revocation.md
│       ├── rollback-and-unbrick.md
│       └── backup-restore-drill.md
├── architecture/                 # Diátaxis: Explanation & Immutable Lineage
│   ├── OVERVIEW.md               # Living arc42 + C4 L1/L2 map of the implemented system
│   ├── INDEX.md, STATUS.md, CHARTER.md, ASSUMPTIONS.md
│   ├── spec/, paper/, adrs/, research/, experiments/, incidents/
└── agents/, capabilities/, policies/, profiles/, crates/, formal/
                                  # Colocated inline docstrings (SSOT for Reference!)

OUT OF GIT (Compiled in ~1.4s by `aky doc build` -> `mdBook 0.5.4`):
└── <CI artifact / GitHub Pages / Tailnet docs.*.ts.net / local `aky doc serve`>
    ├── Tutorials, Guides & Runbooks (rendered from docs/)
    ├── Living Architecture & ADRs (rendered from architecture/)
    ├── Auto-Generated Reference (compiled from SST + TOML + Nix options + clap CLI):
    │   ├── Hosts (C4 L2 ≤ 15-node diagram, ASCII disk/state tree, slice/R2/quota tables, install track)
    │   ├── Agents, Promises, Substrates & Profiles (1-hop diagram, probes, [state.*], options)
    │   ├── Cedar Policies & Capabilities (`aky with` catalog + blast-radius matrix)
    │   ├── CLI (`aky` flags from clap), Standalone Packages (`W-Std`), DevShells & `flake.templates`
    │   └── Coverage & Freshness Dashboard (`100%` docstrings + runbook `reviewed` ages)
    └── llms.txt (compact web-facing machine index)
```

### 3.3 The Mandatory 5-Part Minimalist Runbook Template (`docs/runbooks/*.md`)
Every operational runbook MUST be short (1–2 screens), random-access, and strictly structured:
1. **Frontmatter**: `id`, `trigger`, `severity`, `reviewed: YYYY-MM-DD`, `verification: manual-drill | vm-test`.
2. **When to Use / Symptoms**: 2–3 exact signals confirming this is the right runbook.
3. **Prerequisites & Capabilities**: Exact `aky with <caps>` command or offline break-glass media needed.
4. **Step-by-Step Procedure**: Numbered copy-paste blocks, each paired with an **Expected Healthy Output** check.
5. **Failure Branches & Verification**: What to do if a step fails + final `aky status` / probe verification confirming full recovery.

---

## 4. Four Mechanical Anti-Rot Verification Gates ("Docs as Tests")

| Gate | Mechanism | Runs Where | What It Prevents |
| :--- | :--- | :--- | :--- |
| **1. `100%` Coverage Audit** | `aky doc audit` (`< 10 ms` zero-Nix on TOML/Rust/Lean + Nix option check in CI) | Pre-commit + CI | Undocumented Agents, Promises, Capabilities, Options, Packages, or placeholder `TODO`s |
| **2. C4 Anti-Spaghetti Cap** | Generator enforces 1-hop scope + hard `≤ 15–20` node cap w/ automatic plane/slice grouping | `aky doc build` | Regression back to v1's unreadable 150–300 node Mermaid blobs |
| **3. Docs-as-Tests & Link Check** | `cargo test --doc`, `aky doc test` (validating TOML examples against `aky-core` & CLI flags against `clap`), and internal/cross-doc link check (`lychee` / `aky doc audit`) | CI on every PR | Broken internal links, stale CLI flag names, or invalid TOML examples in guides/tutorials |
| **4. Runbook Freshness Patrol** | `aky doc audit` checks `reviewed: YYYY-MM-DD` on `docs/runbooks/*`; flags `> 180d` unverified runbooks inside the **Weekly Operational Digest (`ADR-0015`)** | Weekly Digest + `aky doc audit` | Untested "paper runbooks" failing at 3 AM |

---

## 5. In-Code Documentation Authoring Contract (How Docs Live Inside Code)

Writing generated-doc inputs cleanly into code requires obeying three hard constraints: **(1) Zero custom wrappers** (use each language's own standard doc syntax — retiring v1's non-idiomatic `{ docstring = ...; value = ...; }` lib wrappers and scattered `docs.sections` Nix string blobs), **(2) Zero Nix `.drv` cache busting** (editing prose/docstrings must never invalidate runtime build hashes), and **(3) Zero-boilerplate minimalism** (mandatory descriptions on public boundaries/options; optional `doc` on internal items only when adding non-obvious intent!).

### 5.1 Per-Language Authoring Specification

| Language / Layer | Standard In-Code Syntax | Mandatory vs. Optional Rules | Extraction & Verification | Cache Isolation |
| :--- | :--- | :--- | :--- | :--- |
| **1. TOML Boundaries** (`agents/*/agent.toml`, `capabilities/*.toml`, `profiles/*.toml`, `policies/*.toml`) | Native `description = "..."` + optional generic `[doc]` table (`links = { adrs = [...], runbooks = [...] }`) + optional sibling `NOTES.md` for `> 3`-line caveats/prose | **Mandatory**: `description` (`≤ 140` chars, timeless present tense).<br>**Optional**: per-promise/state/probe `doc = "..."` (only when non-obvious!), `[doc].links` (populates SST `NEAR` edges!), and sibling `NOTES.md` (keeps `*.toml` tiny!). | Parsed directly in `< 5 ms` zero-Nix by `aky doc audit` & `aky doc build`; all `[doc].links` targets mechanically verified! | `realize.nix` evaluates `builtins.fromTOML` and projects ONLY operational `bound` fields into `interior.nix` (`description`/`[doc]` stripped; `NOTES.md` unread) → **`0` `.drv` busts!** |
| **2. Nix** (`interior.nix`, `lib/*.nix`, `flake.nix`) | **Nix RFC 145 `/** ... */`** (`nixdoc` format: summary, `# Inputs`, `# Type`, `# Examples`) for functions + standard `lib.mkOption { description; example; }` + standard `meta.{description,mainProgram,homepage}` | **Mandatory**: RFC 145 `/** ... */` on all exported `lib` functions; `description` on every `mkOption`; `meta.description` on packages/devShells.<br>**Retired**: v1's `{ docstring; value; }` attrset wrappers, `docs.sections.*` Nix strings, and custom `meta.usage` hacks! | `aky doc` lexes RFC 145 `/** ... */` directly in Rust (**zero Nix eval!**); CI extracts evaluated `mkOption` types/defaults JSON once for `mdBook` Reference. | Nix `/** ... */` comments are invisible to Nix evaluation → **`0` `.drv` busts!** |
| **3. Rust** (`v2/crates/*`) | Standard **`rustdoc`** (`//!` module + `///` items) following Rust API Guidelines **`C-EXAMPLE`** & **`C-LINK`**; **`clap`** `///` + `after_help` examples in `aky-cli` | **Mandatory**: `//!` crate/module headers, `///` + `[`Type`]` intra-doc links on public `aky-core` items (`#![deny(missing_docs)]` on public API), runnable doc-examples (`cargo test --doc`). **`clap` doc comments are SSOT** for `--help`, completions, manpages, and `mdBook` CLI Reference! | `cargo clippy` + `cargo test --doc` + `aky doc build` introspects `clap::Command` directly. | Scoped to Rust `crane` `lib.fileset` (`0` unrelated NixOS host `.drv` busts). |
| **4. Lean 4** (`v2/formal/lean/Aky/**`) | Standard **`/-! ... -/`** (module) & **`/-- ... -/`** (def/theorem — Mathlib/`doc-gen4`/Verso-compatible) | **Mandatory**: module `/-! -/` linking governing `ADR-*` / spec section; `/-- -/` explaining conceptual meaning & safety invariant on exported `Aky/Spec/*` & `Aky/Thm/*` items (never just echoing the type signature). | Checked by `aky doc audit` and rendered into `mdBook` Formal Verification Reference. | Scoped to `formal/lean` fileset (`0` host `.drv` busts). |
| **5. Quint** (`v2/formal/quint/*.qnt`) | Standard `///` doc comments on `module`, `action`, and `val` invariants | Concise state-machine & invariant meaning linked to governing `ADR-*`. | Parsed by `aky doc audit` & rendered in Formal Reference. | Scoped to `formal/quint` fileset (`0` host `.drv` busts). |

### 5.2 Core Purity & Automatic SST `NEAR` Edge Generation
- Inside `aky-core` and `Aky/Spec/*`, documentation metadata stays **100% usage-agnostic** (`description: String`, `doc_links: BTreeMap<String, Vec<String>>` — zero hardcoded domain names like `"runbooks"` or `"adrs"` in the formal kernel!).
- At the documentation & observability layer (`aky doc`, `aky inspect`, `ADR-0015`), `[doc.links]` entries like `runbooks = ["break-glass-recovery"]` and `adrs = ["ADR-0011"]` automatically compile into:
  1. Bidirectional hyperlinks in `mdBook` Reference pages,
  2. `< 5 ms` broken-reference assertions in `aky doc audit`, and
  3. Live **Semantic Spacetime `NEAR` links** — so when an alert fires or an operator/agent runs `aky inspect vaultwarden --json`, the governing ADRs and exact 3 AM runbooks surface immediately!

