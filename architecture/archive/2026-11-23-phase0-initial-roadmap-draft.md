---
id: ARC-0001
title: Archived Initial Phase 0 Roadmap Draft (Pre-Bias-Correction)
type: archive
status: archived
created: 2026-11-23
updated: 2026-11-23
domain: meta
tags: [archive, phase0, roadmap, bias-correction]
superseded_by: ARCH-CHARTER
summary: Preserves the first Phase 0 roadmap proposal before the user's bias-correction removing references to current repo structures (meta/, Dendritic, etc.) from Phase 2+ problem statements.
---

<!-- abstract:start -->
## Executive Abstract

Historical snapshot of the initial Phase 0 proposal presented on 2026-11-23 before user alignment. Preserved verbatim in summary because the user's critique exposed an important epistemic trap: our initial draft accidentally leaked current `nixconf` concepts (`meta/`, `Dendritic`, `flake-parts`, `VictoriaMetrics`) into Phase 2–3 RFD titles, biasing future exploration. Superseded by the bias-free formulation in [`CHARTER.md`](../CHARTER.md) and [`README.md`](../README.md), and moved to dedicated branch `design/v2`.
<!-- abstract:end -->

# Archived Initial Phase 0 Proposal (2026-11-23)

## What Was Originally Proposed

1. **Workspace location**: Originally recommended putting `architecture/` directly on `main`.
2. **Initial Phase 2–3 RFD framing (contained accidental current-repo bias)**:
   - `RFD-0001`: Mentioned "flake-parts / Dendritic / generalized contract↔implementation duality" directly in the prompt framing.
   - `RFD-0002`: Named "Architectural Invariants & **`meta/` Consolidation**" — presupposing a `meta/` directory/subsystem exists in v2.
   - `RFD-0003`: Assumed Nix-Rust tooling around existing tools.
   - `RFD-0004`–`RFD-0008`: Framed partially relative to existing stack components (`VictoriaMetrics + VictoriaLogs + Alloy + Grafana`, `docs/llm-context.md`).
3. **Retrieval design**: Proposed plain Markdown + YAML frontmatter without explicitly formalizing the 5-layer progressive-disclosure / RAG comparison.

## User Critique & Corrections Applied (2026-11-23)

1. **Dedicated branch**: Moved all redesign research & specification work onto branch `design/v2` instead of `main`.
2. **Strict zero-bias problem formulation**: Removed all presuppositions of `meta/`, `primitives/`, `modules/`, `dendritic`, `flake-parts`, or current stacks from Phase 2+ problem statements. Current `nixconf` is examined *only* as empirical input in Phase 1; Phase 2+ starts from a blank sheet of fundamental goals.
3. **Append-only preservation + token-efficient retrieval**: Added explicit `research/`, `archive/`, and 5-layer progressive-disclosure knowledge architecture (`INDEX.md` → frontmatter/abstracts → compiled analysis → raw dossiers → lineage/archive) so expansive raw data is preserved without wasting tokens during navigation.
