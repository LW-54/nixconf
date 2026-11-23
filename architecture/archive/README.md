---
id: ARCH-ARCHIVE-POLICY
title: Append-Only Archive Policy
type: archive
status: active
created: 2026-11-23
updated: 2026-11-23
domain: meta
tags: [archive, lineage, append-only]
summary: Defines the append-only preservation rules for superseded drafts, abandoned explorations, and historical architectural snapshots.
---

<!-- abstract:start -->
## Executive Abstract

This directory holds immutable historical snapshots of superseded drafts, abandoned proposals, and prior framings. Nothing in `architecture/` is ever silently overwritten or deleted: when a framing changes meaningfully (such as correcting an unconscious architectural bias or superseding an RFD/ADR), the previous version is archived here with a dated filename (`YYYY-MM-DD-<slug>.md`) and linked from `INDEX.md` and the superseding document.
<!-- abstract:end -->

# Append-Only Archive Policy

1. **Never delete historical reasoning**: Dead ends, falsified hypotheses, and biased first drafts contain crucial signal that prevents repeating mistakes months later.
2. **Naming convention**: `YYYY-MM-DD-<short-slug>.md` with standard YAML frontmatter (`type: archive`, `status: archived`, `superseded_by: <ID>`).
3. **Token efficiency**: Because archived files sit inside `architecture/archive/` (Layer 4) and are clearly marked `status: archived` in `INDEX.md`, agents skip them by default unless explicitly investigating history or lineage.
