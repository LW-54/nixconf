---
id: EXP-0014
title: Stage 3C.3 Empirical Documentation Churn Audit, Token Economics & Static Site Generator Benchmark
type: experiment
status: completed
created: 2026-11-25
updated: 2026-11-25
domain: knowledge-ux
tags: [experiment, benchmark, stage-3c3, docs, git-churn, tokens, mdbook, zola, zensical, pagefind, a-012]
assumptions: [A-012]
summary: Empirical audit of v1's committed generated docs/ tree on main (168 files, 3.26 MiB, 853k tokens, responsible for 75.1% of all historical repo line churn across 55.4% of commits!) paired with a live head-to-head SSG build benchmark on all 168 real Markdown files comparing mdBook 0.5.4 (1.39s, 61.6 MiB closure), Zola 0.23.6 (0.55s, 102.1 MiB), Zensical 0.0.72 (11.50s, 274.1 MiB), and Pagefind 1.5.2 — empirically validating A-012.
---

<!-- abstract:start -->
## Executive Abstract

Empirically audits v1's committed auto-generated `docs/` tree on `main` and benchmarks three pinned `nixpkgs 26.11` (`1d06008`) static site generators (`mdbook 0.5.4`, `zola 0.23.6`, `zensical 0.0.72`) plus `pagefind 1.5.2` against the **actual `168`-file `3.26 MiB` `docs/` corpus** on `astrolabe`, **decisively validating `A-012`**:
1. **Committed Generated Docs Account for `75.1%` of All Repository Line Churn**: Across `130` commits on `main`, `72` commits (**`55.4%`**) were forced to modify generated `docs/` files, churning **`341,250` lines (`+193,379 / -147,871`) out of `454,669` total repo line changes (`75.1%`)** while imposing a `~12 s` Nix pre-commit eval tax.
2. **Progressive Disclosure Cuts Agent Entry Context by `103×`–`277×`**: v1's `docs/` totals **`853,311` estimated tokens** (`docs/hosts/astrolabe.md` alone is `115.6 KiB` / `~29k` tokens!). By contrast, `AGENTS.md` (`631` tokens) + `architecture/INDEX.md` (`7,655` tokens) = **`8,286` tokens (`103.0×` smaller)**, and ALL `18` `v2/` `*.toml` boundary files combined total only **`3,080` tokens (`277×` smaller)** — verified by `aky check` in `2.4 ms` with zero Nix evaluation!
3. **Live SSG Benchmark on All `168` Real Files (`3.26 MiB`)**:
   - **`mdBook 0.5.4`**: **`1.39 s`** build, **`61.6 MiB`** pure-Rust Nix closure (smallest by `1.7×`–`4.5×`!), `0` theme maintenance, built-in themes + search (`+3.51 s` w/ optional Pagefind).
   - **`Zola 0.23.6`**: Fastest raw build (**`0.55 s`**), `102.1 MiB` pure-Rust closure, `5.28 MiB` output, but requires maintaining custom Tera HTML/CSS templates or an external theme flake input.
   - **`Zensical 0.0.72`** (Material-for-MkDocs successor): Gorgeous Material UI out of the box, but **`11.50 s`** (`8.3×` slower than `mdBook`), **`274.1 MiB`** Python 3.14 + Rust Nix closure (`4.5×` heavier), and pre-1.0 (`0.0.72`) churn risk.
<!-- abstract:end -->

# EXP-0014: Documentation Churn Audit, Token Economics & Live SSG Benchmark

Reproducible harness: `scratch/exp0014_docs_ssg_bench.py` (`astrolabe`, `nixpkgs 1d06008`).

---

## 1. Empirical Git Churn & Context Footprint Audit (`main`)

| Artifact Corpus | Files | Size (`MiB`) | Lines | Est. Tokens (`B/4`) | Git History Impact (`main`, `130` commits) |
| :--- | ---: | ---: | ---: | ---: | :--- |
| **v1 Generated `docs/` (Committed in Git)** | `168` | `3.26 MiB` | `45,517` | **`853,311`** | **`72 / 130` commits (`55.4%`); `341,250 / 454,669` churned lines (`75.1%`!!)** |
| Hand-authored `architecture/` (ADRs, specs, research) | `101` | `0.91 MiB` | `9,611` | `239,641` | High-signal permanent design lineage (progressive disclosure) |
| Entry Layer: `AGENTS.md` (Always-loaded guardrails) | `1` | `0.002 MiB` | `29` | **`631`** | Minimal executable-first routing map (*Gloaguen et al. 2026*) |
| Entry Layer: `architecture/INDEX.md` (Layer-0 map) | `1` | `0.029 MiB` | `105` | **`7,655`** | **`103.0×` smaller** than `docs/` (`AGENTS.md + INDEX.md`) |
| Complete `v2/` `*.toml` Boundaries (All agents/policies) | `18` | `0.012 MiB` | `~400` | **`3,080`** | **`277.0×` smaller** than `docs/`, verified in `2.4 ms` zero-Nix |

Single-file bloat examples in v1 `docs/`: `docs/hosts/astrolabe.md` = `115.6 KiB` (`~28.9k` tokens), `docs/hosts/x240.md` = `109.8 KiB` (`~27.5k` tokens).

---

## 2. Live Head-to-Head Static Site Generator Benchmark (`168` Real `docs/` Files)

All three SSGs built the **complete 168-file (`3.26 MiB`, `45,517` lines) real Markdown corpus** cleanly (`exit_code = 0`):

| Static Site Generator (`nixpkgs 1d06008`) | Runtime Stack | Nix Closure Size | Build Time (`168` files) | HTML Site Size | Optional `Pagefind 1.5.2` Index Time / Size | Theme & Maintenance Ergonomics |
| :--- | :--- | ---: | ---: | ---: | ---: | :--- |
| **`mdBook 0.5.4`** | Pure Rust binary | **`61.6 MiB`** *(smallest!)* | **`1,393.8 ms`** (`1.39 s`) | `17.86 MiB` | `3,511 ms` / `2.10 MiB` *(or built-in Elasticlunr)* | **Zero theme maintenance**; built-in light/dark themes, keyboard nav, native `mdbook-mermaid` |
| **`Zola 0.23.6`** | Pure Rust binary | `102.1 MiB` | **`545.8 ms`** (`0.55 s`) | **`5.28 MiB`** | `1,057 ms` / `1.41 MiB` *(+ built-in `1.53 MiB` JS)* | Requires custom Tera HTML/CSS templates or maintaining an external theme input + frontmatter wrapping |
| **`Zensical 0.0.72`** | Python 3.14 + Rust (`pymdown`) | `274.1 MiB` (`4.5×` `mdBook`) | `11,500.2 ms` (`11.50 s`, `8.3×` slower!) | `19.15 MiB` | Built-in Material search | Richest Material UI out-of-the-box, but early `0.0.72` alpha & heavy Python closure |

*(Reference: `pagefind-extended 1.5.2` standalone Nix closure = `104.4 MiB`.)*
