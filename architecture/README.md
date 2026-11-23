---
id: ARCH-METHODOLOGY
title: Architecture Redesign Methodology & Knowledge System
type: methodology
status: active
created: 2026-11-23
updated: 2026-11-23
tags: [methodology, knowledge-architecture, rfd, adr, gma, atam, progressive-disclosure]
summary: Defines the rigorous, bias-free research methodology, 5-layer token-efficient knowledge layout, append-only archiving rules, and experiment/decision lifecycles for the nixconf redesign.
---

<!-- abstract:start -->
## Executive Abstract

This directory (`architecture/`, tracked on branch `design/v2`) is the version-controlled research, experimentation, and specification workspace for a first-principles redesign of `nixconf`. It synthesizes six complementary systems-engineering frameworks: **Parnas/Ousterhout/Brooks/Jackson** (elegance & concept modularity), **Zwicky General Morphological Analysis** (exhaustive design-space exploration), **SEI ATAM** (testable quality attribute scenarios), **Assumptions Ledger + Scientific Spikes** (empirical grounding), **Oxide RFDs + MADR ADRs** (separating open exploration from immutable decisions), and **arc42** (final specification). To preserve expansive raw research without burning LLM tokens during navigation, knowledge is organized in **5 progressive-disclosure layers** (Layer 0 `INDEX.md`/`STATUS.md` → Layer 1 YAML frontmatter & ≤15-line abstracts → Layer 2 compiled audits/RFDs/ADRs → Layer 3 deep raw dossiers & benchmarks → Layer 4 append-only archive & session journal). Nothing is ever silently overwritten or deleted; superseded drafts move to `archive/` with lineage preserved in Git.
<!-- abstract:end -->

# Architecture Redesign Methodology & Knowledge System

## 1. Epistemic Principles

1. **Zero Architectural Bias**: Nothing in the current repository (`primitives/`, `modules/`, `meta/`, `flake-parts`, dendritic layout, specific monitoring stacks, etc.) is sacred. Only the fundamental goals in [`CHARTER.md`](CHARTER.md) are fixed. Existing code is studied strictly as *empirical data* during Phase 1, after which Phase 2+ formulates problems from first principles.
2. **Mathematical Elegance Over Accidental Abstraction**: Seek minimal, orthogonal, maximally expressive fundamental primitives from which concrete needs emerge naturally. Reject premature abstraction, shallow pass-through wrappers, alias piles, and gratuitous custom DSLs. Abstraction must earn its keep via Ousterhout depth (`expressive power / interface surface`).
3. **Explore the Manifold Before Choosing**: Every major design decision must map the multi-dimensional design space (Zwicky Morphological Box), eliminate contradictory combinations (Cross-Consistency Assessment), identify the Pareto frontier against ATAM scenarios, and understand the *shape* of the underlying problem before down-selecting.
4. **Empiricism Over Speculation**: Non-trivial claims go into [`ASSUMPTIONS.md`](ASSUMPTIONS.md) with explicit falsification criteria. High-leverage choices are validated with isolated, reproducible prototypes and benchmarks (`experiments/`).
5. **Standards with Discipline**: Prefer mature, well-maintained standards and battle-tested tools when they genuinely solve hard problems better than we want to maintain; avoid brittle/unmaintained dependencies; build clean owned implementations when a problem is small, core, and benefits from total control.
6. **Append-Only Preservation (Never Silently Overwrite)**: All research, rejected options, intermediate reasoning, and superseded drafts remain preserved in Git and `archive/`. History is part of the manifold.

---

## 2. Five-Layer Progressive-Disclosure Knowledge Architecture

To reconcile two competing needs — **comprehensive, expansive raw data** and **low-token, high-precision navigation** for both humans and LLMs — all documents follow a strict 5-layer retrieval hierarchy (rationale & RAG comparison documented in [`research/RES-0001-methodology-and-knowledge-architecture.md`](research/RES-0001-methodology-and-knowledge-architecture.md)):

| Layer | Location | Typical Read Cost | Purpose |
| :--- | :--- | ---: | :--- |
| **Layer 0 — Routing** | [`INDEX.md`](INDEX.md), [`STATUS.md`](STATUS.md) | ~300–700 tokens | Master catalog of every document (ID, path, status, tags, lines, 1-line summary) + current phase & open decisions. **Always read first.** |
| **Layer 1 — Abstracts** | Lines 1–40 of every `.md` file | ~150–250 tokens/doc | Standardized YAML frontmatter + `<!-- abstract:start --> ... <!-- abstract:end -->` (≤15 lines). Lets an agent screen candidates via `read_file(EndLine: 45)` without loading multi-kilobyte dossiers. |
| **Layer 2 — Compiled Analysis** | `CHARTER.md`, `ASSUMPTIONS.md`, `audit/`, `rfds/`, `adrs/`, `spec/` | ~1k–4k tokens/doc | Structured diagnoses, morphological analyses, trade-off tables, crisp MADR decisions, and final architectural specification. |
| **Layer 3 — Raw Evidence** | `research/`, `experiments/` (and `experiments/raw/`) | Variable (deep) | Expansive literature dossiers, paper notes, source URLs, full option enumerations, raw benchmark outputs, reproduction scripts. Loaded *on demand* when verifying a specific claim. |
| **Layer 4 — Lineage & Archive** | `journal/`, `archive/` | On demand | Chronological session logs (preserving user corrections, conversation IDs, commits) and immutable snapshots of superseded/abandoned drafts. |

### Navigation Protocol for Agents & Humans
1. Read `STATUS.md` and `INDEX.md` first (Layer 0).
2. Filter relevant documents by `domain`, `tags`, or `rg` against frontmatter/headings.
3. Read lines 1–45 of candidate documents (Layer 1 abstracts) before pulling full bodies (Layer 2).
4. Drill into `research/` or `experiments/` (Layer 3) only for the specific claims or benchmarks currently under investigation.
5. Whenever adding, updating, or archiving any document, update `INDEX.md` and `STATUS.md` in the same commit.

---

## 3. Document Conventions & Lifecycles

### Required YAML Frontmatter
Every Markdown file under `architecture/` (except `INDEX.md` and `TEMPLATE.md` files) MUST start with:

```yaml
---
id: <PREFIX>-<NNNN>           # RES, AUD, RFD, EXP, ADR, SPEC, SES, ARC
title: <Concise Title>
type: <research|audit|rfd|experiment|adr|spec|journal|archive|charter|ledger|methodology|status>
status: <draft|active|prediscussion|discussion|decided|accepted|validated|falsified|superseded|abandoned|archived>
created: YYYY-MM-DD
updated: YYYY-MM-DD
domain: <foundations|verification|tooling|networking-fleet|gitops|distributed|observability|knowledge|meta>
tags: [tag1, tag2]
assumptions: [A-001]          # Optional: linked assumption IDs
depends_on: [RFD-0001]        # Optional: upstream doc IDs
supersedes: null              # Optional: doc ID superseded by this doc
superseded_by: null           # Optional: set when superseded (never delete)
summary: <One crisp sentence for INDEX.md>
---
```

Followed immediately by a `<!-- abstract:start --> ... <!-- abstract:end -->` block (≤15 lines).

### Document Lifecycles

- **Research Dossier (`research/RES-NNNN-<slug>.md`)**: `draft` → `active` → `archived` (append new findings with dated addenda rather than erasing prior findings).
- **Audit Report (`audit/AUD-NNNN-<slug>.md`)**: `draft` → `active` (snapshot of current `nixconf` at a pinned git commit hash).
- **RFD (`rfds/RFD-NNNN-<slug>.md`)**:
  - `prediscussion` — Research, morphological mapping, and experiments underway.
  - `discussion` — Executive synthesis presented to the user; actively debating trade-offs and open questions.
  - `decided` — Consensus reached; decision crystallized into one or more ADRs (`adrs/ADR-NNNN-*.md`).
  - `abandoned` — Explored and explicitly rejected/closed (kept forever with rationale).
- **Experiment (`experiments/EXP-NNNN-<slug>.md`)**: `planned` → `running` → `completed` (always records git commit, host specs, exact commands, raw outputs, and assumption verdicts).
- **ADR (`adrs/ADR-NNNN-<slug>.md`)**: `proposed` → `accepted` → `superseded` (immutable once `accepted`; changes require a new ADR that references `supersedes: ADR-XXXX`).
- **Archive (`archive/YYYY-MM-DD-<slug>.md`)**: Immutable historical snapshot. Before making a structural rewrite to an active RFD or charter, copy the prior revision to `archive/` if its discarded content has historical value.

---

## 4. Code Prototypes & Branch Hygiene

- All design documents live in `architecture/` on branch `design/v2`, keeping `main` untouched until implementation/migration begins.
- **No `.nix` files inside `architecture/`**: keeps Nix flake evaluation, `import-tree`, `nixconf-docs` source scanning, and binary caches 100% isolated.
- When an experiment (`EXP-NNNN`) requires executable `.nix` or `.rs` code:
  1. Run it in an isolated temporary directory (`/tmp/exp-NNNN-*`) or a dedicated `exp/EXP-NNNN-<slug>` branch/worktree.
  2. Record exact reproduction code/patches, commands, and raw metrics inside `architecture/experiments/EXP-NNNN-<slug>.md` (and `experiments/raw/EXP-NNNN-*` if large).
  3. Keep `design/v2` free of broken or half-baked Nix files.

---

## 5. Phased Execution Cadence

| Phase | Goal | Exit Criterion |
| :--- | :--- | :--- |
| **Phase 0** | Methodology, knowledge architecture, Charter, initial Assumptions Ledger | Ratified `CHARTER.md`, `README.md`, `ASSUMPTIONS.md`, and templates on `design/v2` |
| **Phase 1** | Unbiased empirical audit of current `nixconf` + boundary-constraint harvest from all future hosts/capabilities | Completed `audit/AUD-0001..N` + updated `CHARTER.md` constraints & `ASSUMPTIONS.md` |
| **Phase 2** | First-principles core foundations (Ontology/Primitives, Invariants/Verification, Tooling/Rust purity) | Decided `RFD-0001`..`RFD-0003` + empirical spikes + ratified core ADRs |
| **Phase 3** | Domain architectures (Networking/Fleet, GitOps/Updates, Distributed Storage/Compute, Observability, Documentation/LLM) | Decided `RFD-0004`..`RFD-0008` + benchmarks + ratified domain ADRs |
| **Phase 4** | Cross-RFD Consistency Assessment (CCA) & End-to-End Validation | Zero unresolved contradictions across ADRs; key cross-domain risks prototyped |
| **Phase 5** | Formal v2 Specification (`spec/`) & Incremental Migration Plan | Complete `spec/` blueprint + safe, staged migration plan from current `nixconf` |
