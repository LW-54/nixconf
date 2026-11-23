---
id: ARC-0002
title: Archived Phase 0 Charter Snapshot (Pre-User-Calibration)
type: archive
status: archived
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [archive, charter, pre-calibration]
superseded_by: ARCH-CHARTER
summary: Preserves the initial Phase 0 Charter before incorporating the user's calibration on standalone nix-run portability, reliability-first priority ordering, graceful degradation, and language-agnostic primitives.
---

<!-- abstract:start -->
## Executive Abstract

Archived pre-calibration snapshot of `CHARTER.md` (from commit `0ca7747`) prior to integrating the user's five calibration answers on 2026-11-23: (1) standalone portability (`nix run` anywhere) as a first-class goal, (2) explicit priority ordering with Operational Reliability first and Elegance defined as reconciling conflicts rather than trading them off, (3) graceful/robust degradation instead of rigid 100% isolation, (4) AI-first behind clean human UIs, and (5) explicit language/layer-agnostic definition of "primitives" (not limited to Nix or `primitives/`).
<!-- abstract:end -->

# Archived Pre-Calibration Charter Summary (Commit `0ca7747`)

Full verbatim file exists at Git commit `0ca7747:architecture/CHARTER.md`.

## Key Deltas Applied in Calibrated `CHARTER.md`
1. **Added Standalone Portability Axiom & Scenario (`QA-09`)**: As many tools, wrapped apps, and capabilities as possible must work standalone from anywhere (`nix run`, non-NixOS Linux/WSL/etc.), decoupled from NixOS host machinery.
2. **Clarified "Primitives" Scope**: Explicitly stated that "primitives" refers to the irreducible core design foundations across *any* layer or language (not necessarily Nix, not necessarily a single category).
3. **Calibrated Priority Hierarchy & Elegance Criterion**: Reliability (`B`) first; true elegance must *reconcile* reliability, maintainability, capability richness, and speed (a "pure" design that hurts reliability or usability fails the elegance test).
4. **Defined Graceful Degradation Policy**: Hosts must remain fundamentally self-sufficient (boot, local core services, safe operation), while cross-host enhancements may temporarily pause when peers are unreachable — provided degradation is bounded, non-blocking, self-healing, and observable.
5. **Calibrated AI-First Boundary**: Human UX/UIs remain human-optimized; everything behind the UI boundary welcomes AI-first design (determinism, introspection, token efficiency, safe autonomy).
6. **Recorded User's Core Audit Signal**: Current repo feels overly entangled, unclear, and fragile; Phase 1 must specifically expose entanglement and fragility hotspots.
