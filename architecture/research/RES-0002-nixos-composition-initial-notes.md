---
id: RES-0002
title: Initial Raw Notes — NixOS Flake-Parts & Dendritic Pattern Survey
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [nixos, flake-parts, dendritic, import-tree, composition, initial-survey]
assumptions: [A-001, A-003]
summary: Preserves initial Phase 0 notes on the Dendritic + flake-parts NixOS pattern as one non-binding point in the broader composition design space to be mapped without bias in RFD-0001.
---

<!-- abstract:start -->
## Executive Abstract

Preserves the initial Phase 0 survey notes on the **Dendritic + `flake-parts` + `import-tree`** NixOS architecture pattern (collected during Phase 0 orientation). **Important epistemic caveat**: this document covers only *one* region of the NixOS composition manifold (the pattern partially used by current `nixconf`). It is preserved in full per our append-only rule and will be placed alongside fundamentally different alternatives (plain `lib.evalModules`, non-flake/pinned Nix, `flake-parts` partitions, aspect/flake-module algebras, Jackson Concepts & Synchronizations, pure functional host builders, etc.) without bias in `RFD-0001`.
<!-- abstract:end -->

# Initial Raw Notes: NixOS Dendritic & `flake-parts` Pattern

> **Non-Binding Scope Note**: Captured during Phase 0 meta-research (2026-11-23). Treated strictly as one candidate point in the Phase 2 (`RFD-0001`) morphological design space — NOT a preferred or assumed baseline.

## 1. Core Tenets of the Dendritic Pattern

1. **Every file is a top-level flake-parts module**: Except minimal entrypoints (`flake.nix`), every `.nix` file is ingested by `flake-parts` (`mkFlake` / `lib.evalModules`) via an auto-loader such as `import-tree`.
2. **Aspect / Cross-Context Orientation**: Code is organized by domain/feature ("aspect") rather than by target layer, allowing a single file to emit NixOS config, user-home config, packages, devShells, and checks simultaneously.
3. **Directory-Driven Loading**: Relies on tree auto-importing instead of long manual relative import chains (`../../foo.nix`).

## 2. Common Composition Mechanics Observed in the Ecosystem

- **Cross-context features**: Single module emits system config + home-layer modules + `perSystem` outputs.
- **Factories**: Reusable builders exposed via `flake.lib.*` for repeated entity types (users, containers, services).
- **`perSystem` partitioning**: Architecture-indexed outputs (`packages`, `devShells`, `checks`, `formatter`) automatically parameterized over `systems = [ "x86_64-linux" "aarch64-linux" ... ]`.
- **`flake-parts` partitions**: Isolating heavy dev/tooling inputs (`_inputs/` or sub-flakes) so production host evaluations do not inherit heavy toolchain lock entries or eval graphs.

## 3. Known Ecosystem Anti-Patterns Noted in Literature

1. **Premature abstraction**: Introducing multi-layer factory/meta-aspect wrappers before multiple concrete instances share identical structure.
2. **Over-nesting manual imports**: Mixing auto-loading trees with deep relative import chains negates the clarity of either approach.
3. **Root `flake.lock` pollution**: Pulling heavy dev/agent/tool inputs into the global root lock so every target system carries unrelated lock/eval overhead.
4. **Hidden evaluation overhead & cache-busting**: Top-level `self` references or monolithic tree scans can silently inflate eval time or bust derivation caches across unrelated edits.

## 4. Open Questions Deferred to Phase 1 (`AUD-0001`) & Phase 2 (`RFD-0001`)

- How much of `flake-parts` + `import-tree` actually simplifies composition vs introducing an extra indirection layer on top of `nixpkgs.lib.evalModules`?
- Does auto-importing an entire directory tree help or hurt **explicitness**, **multi-implementation polymorphism**, and **cache/eval isolation**?
- How does Dendritic compare against:
  - Plain `lib.evalModules` + explicit module registries / deferred modules
  - Pure functional combinators / overlays / fixed-points
  - Flake-parts partitions / multi-flake workspaces
  - Non-flake pinned-Nix architectures (`npins`, `lon`, `tack`)
  - Daniel Jackson's Concept + Synchronization model expressed directly in Nix?
