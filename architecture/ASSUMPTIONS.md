---
id: ARCH-ASSUMPTIONS
title: Architectural Assumptions Ledger
type: ledger
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [assumptions, hypotheses, falsification, empiricism]
summary: Central living ledger tracking every explicit architectural assumption, its risk if false, falsification/validation method, and current epistemic status.
---

<!-- abstract:start -->
## Executive Abstract

This ledger tracks every non-trivial technical and architectural assumption underlying the `nixconf` redesign. Each entry records an immutable ID (`A-NNN`), explicit falsifiable statement, affected domain(s), blast radius if false, status (`unverified` | `experimenting` | `validated` | `falsified` | `retired`), and linked evidence (`AUD-*`, `RES-*`, `EXP-*`, `RFD-*`). Assumptions are **never deleted**; when falsified or retired, their verdict and lessons learned remain permanently recorded to prevent repeating dead ends.
<!-- abstract:end -->

# Architectural Assumptions Ledger

## Status Legend
- `unverified` — Stated explicitly, not yet empirically tested or researched in depth.
- `experimenting` — Active prototype, benchmark, or deep literature review underway.
- `validated` — Confirmed via empirical measurement, proof, or authoritative primary evidence.
- `falsified` — Disproven; linked evidence explains why and what replaced it.
- `retired` — No longer applicable due to an accepted architectural decision.

---

## Ledger Summary Table

| ID | Domain | Status | Risk if False | Statement (Short) | Evidence |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **A-001** | Foundations | `validated` | High | Authoring medium & Nix↔Rust seam (`ADR-0008` + `EXP-0006`): Split `*.toml` boundaries (`A2`, `5.79 ms` zero-Nix) + pure idiomatic NixOS/package `interior.nix` via Zero-IFD `builtins.fromTOML` (`S1`) yields bit-for-bit identical `.drv` outputs with 0 cache busts and syntactic `Π_ext ⊥ Interior` enforcement. | [`EXP-0001`](experiments/EXP-0001-intent-sync-multi-provider-algebra.md), [`EXP-0006`](experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md), [`ADR-0008`](adrs/ADR-0008-authoring-medium-toml-boundaries-nix-interiors-and-zero-artifact-seam.md) |
| **A-002** | Foundations | `validated` | High | Multi-implementation & sub-component swapping can be modeled cleanly via typed named provider instances + declarative synchronizations without N×M glue or infinite recursion. | [`EXP-0001`](experiments/EXP-0001-intent-sync-multi-provider-algebra.md) |
| **A-003** | Foundations | `validated` | High | Standard `flake.nix` + `flake.lock` (~45 LOC plain outputs, dropping `.tack`/`flake-parts`/`import-tree`/`flake-schemas`) provides universal `nix run` portability & ecosystem/bot compatibility (`EXP-0007`, `ADR-0009`). | [`EXP-0007`](experiments/EXP-0007-entrypoints-wrappers-and-hermetic-formal-sandbox.md), [`ADR-0009`](adrs/ADR-0009-plain-flake-pure-wrappers-crane-quality-and-hermetic-formal-ci.md) |
| **A-004** | Verification | `validated` | Medium | Separating `< 6 ms` zero-Nix Rust `aky check` + cached `aky-oracle` PR DRT from path-filtered hermetic Lean 4 (`46.2s`) / Quint (`28.7s`) / VM checks enforces uniform 4-language invariants within pre-commit budget (`EXP-0006`, `EXP-0007`, `ADR-0009`). | [`EXP-0006`](experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md), [`EXP-0007`](experiments/EXP-0007-entrypoints-wrappers-and-hermetic-formal-sandbox.md), [`ADR-0009`](adrs/ADR-0009-plain-flake-pure-wrappers-crane-quality-and-hermetic-formal-ci.md) |
| **A-005** | Tooling | `experimenting` | Medium | Unified Cargo workspace built via `crane` + stock `nixpkgs` `rustc` + `lib.fileset.toSource` ratified in `ADR-0009`; incremental rebuild speed to be empirically benchmarked in `W1` Walking Skeleton. | [`AUD-0002`](audit/AUD-0002-meta-tooling-rust-deps.md), [`ADR-0009`](adrs/ADR-0009-plain-flake-pure-wrappers-crane-quality-and-hermetic-formal-ci.md) |
| **A-006** | Networking | `unverified` | High | A WireGuard-based mesh VPN (Tailscale / Headscale / NetBird) can operate cleanly on impermanent NixOS, WSL, `aarch64` RPi, and live ISOs without breaking public ingress or offline boot. | — *(RFD-0004)* |
| **A-007** | Fleet | `unverified` | High | Non-traditional NixOS targets (WSL via `NixOS-WSL`, Live USB ISO, `aarch64` Raspberry Pi) can share the same core host primitives as full-disk `x86_64` hosts cleanly. | — *(RFD-0004)* |
| **A-008** | GitOps | `unverified` | High | Pull-based NixOS convergence (e.g., `comin` or `system.autoUpgrade`) with protected `main` + PR-gated CI + Attic binary cache provides safer, lower-maintenance updates than push-only deploys. | — *(RFD-0005)* |
| **A-009** | Distributed | `unverified` | Medium | Distributed Nix remote builders + Attic binary cache deliver high value at low operational complexity, whereas general-purpose distributed filesystems (e.g., Ceph) are overkill/fragile on intermittent laptops. | — *(RFD-0006)* |
| **A-010** | Observability | `unverified` | Medium | On an 11 GiB RAM VPS, VictoriaMetrics + VictoriaLogs + Alloy + Grafana sits near the Pareto frontier of telemetry richness per GiB RAM compared to ClickHouse / OTel / Prometheus / Pyroscope stacks. | — *(RFD-0007)* |
| **A-011** | Knowledge | `validated` | Medium | For structured software/architecture repositories (tens to hundreds of docs), hierarchical progressive-disclosure Markdown + YAML metadata + `rg` outperforms naive vector RAG in precision, token efficiency, and zero-drift maintainability. | [`RES-0001`](research/RES-0001-methodology-and-knowledge-architecture.md) |
| **A-012** | Knowledge | `unverified` | Low-Med | Moving generated human documentation out of the main Git working tree (e.g., CI-built static site / artifact) while keeping a compact, prefix-cacheable context index in-repo eliminates doc-sync churn without hurting LLM comprehension. | — *(RFD-0008)* |
| **A-013** | Portability | `validated` | High | Decoupling portable capabilities via `A2` standalone agents + `W-Std` pure `nixpkgs` wrappers (`{ package; nixos.environment.systemPackages; }`) runs identically via `nix run` anywhere and on NixOS hosts with zero Home Manager / `hjem` duplication (`EXP-0006`, `EXP-0007`, `ADR-0009`). | [`EXP-0006`](experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md), [`EXP-0007`](experiments/EXP-0007-entrypoints-wrappers-and-hermetic-formal-sandbox.md), [`ADR-0009`](adrs/ADR-0009-plain-flake-pure-wrappers-crane-quality-and-hermetic-formal-ci.md) |

---

## Detailed Assumption Records

### A-001 — Nix Module System as Core Composition Algebra
- **Full statement**: Standard `nixpkgs.lib.evalModules` (with proper typing, `mkOption`, deferred modules, and fixed-point merging) is mathematically sufficient as the core composition engine; custom wrappers/primitives should only add genuinely orthogonal semantics (or be eliminated if they merely shadow `evalModules`).
- **Validation / Falsification plan**: Audit existing `primitives/` in Phase 1 (`AUD-0001`), compare `evalModules` directly against flake-parts, Dendritic, and Jackson Concept/Synchronization patterns in `RFD-0001`, and prototype a minimal algebra in `EXP-0001`.

### A-002 — Clean Multi-Implementation & Sub-Component Swapping
- **Full statement**: Supporting both single-backend swapping (e.g., proxy A vs B) and *simultaneous* multi-backend instantiation (e.g., two storage/secret/home backends active at once, or swapping sub-components) is achievable cleanly without `lib.evalModules` infinite recursion or excessive boilerplate.
- **Validation / Falsification plan**: Formalize as an interface/adapter/synchronization problem in `RFD-0001` and test concrete Nix prototypes for recursion, option collision, and eval cost.

### A-003 — Flakes vs Alternatives as Entry Point
- **Full statement**: Nix Flakes (with or without `flake-parts` or `tack`) remain the highest-leverage top-level entry point compared to pure-Nix pinning (`npins`/`lon`) or alternative evaluators (`lix`/Determinate), considering NixOS tooling, GitOps (`comin`/`autoUpgrade`), CI, and binary caching.
- **Validation / Falsification plan**: Evaluate objectively in `RFD-0001` (including cache-isolation pitfalls of `${self}` and `flake-parts` overhead vs plain flake outputs).

### A-004 — Uniform Structural Invariant Enforcement
- **Full statement**: Every layer of the repository — infrastructure config, primitives, tooling, CI, and documentation — can be subjected to the same mechanical invariant checks without violating the <15s local iteration budget.
- **Validation / Falsification plan**: Audit current gaps (notably `meta/` documentation & test coverage) in Phase 1 and benchmark unified verification architectures in `RFD-0002`.

### A-005 — Pure Nix Rust Integration Ergonomics & Performance
- **Full statement**: There exists a clean, pure-Nix Rust workflow (evaluating `rustPlatform.buildRustPackage`, `crane`, `naersk`, `fenix`, single-file `rustc`, and Nix-Rust interoperability tools like `nix-rs`/`tvix`/`harmonia`) that provides fast builds, minimal lockfile churn, and unified tooling maintenance.
- **Validation / Falsification plan**: Survey ecosystem + run real incremental build & cache-hit benchmarks on `astrolabe` in `RFD-0003`.

### A-006 — Mesh VPN Compatibility Across All Target Form Factors
- **Full statement**: A mesh VPN (Tailscale / Headscale / NetBird / WireGuard) can run reliably across impermanent VPS (`astrolabe`), roaming laptops, WSL, `aarch64` Raspberry Pi, and ephemeral live ISOs without breaking offline boot, DNS resolution, or public reverse-proxy traffic.
- **Validation / Falsification plan**: Research + test in QEMU VM / WSL docs & Tailscale/Headscale architecture analysis in `RFD-0004`.

### A-007 — Unified Host Primitives Across Exotic Targets
- **Full statement**: Full-disk NixOS (`astrolabe`, laptops), `aarch64` SBCs (Raspberry Pi), diskless WSL (`NixOS-WSL`), and Live USB ISOs can share a single clean host/capability composition model without turning host definitions into conditional spaghetti.
- **Validation / Falsification plan**: Harvest exact structural differences of WSL, ISO, and `aarch64` RPi in Phase 1; validate composition in `RFD-0001` and `RFD-0004`.

### A-008 — Pull-Based GitOps + PR Workflow Safety
- **Full statement**: Treating GitHub `main` as the single source of truth (agents/bots open PRs → CI tests & pushes to Attic → hosts converge via `comin` or `system.autoUpgrade`) is strictly safer and lower-maintenance than manual `nixos-rebuild switch`, including for unattended security updates like Vaultwarden.
- **Validation / Falsification plan**: Compare `system.autoUpgrade`, `comin`, `deploy-rs`, `colmena`, and hybrid pull/push models in `RFD-0005` (including rollback semantics, secret boot, and offline laptops).

### A-009 — Distributed Storage & Compute Value-to-Complexity Ratio
- **Full statement**: Distributed Nix builds + shared Attic cache + selective file sync/object storage provide >80% of practical fleet value at <20% of the operational failure risk of clustered filesystems (Ceph/Gluster) or heavy orchestrators (K8s) on heterogeneous intermittent home/mobile hardware.
- **Validation / Falsification plan**: Map full morphological design space in `RFD-0006` (Ceph, SeaweedFS, Garage, MinIO, Syncthing, Rclone, Nomad, K3s, Incus, Nix remote builders) against intermittent-node failure modes.

### A-010 — Observability Stack Efficiency Frontier on 11 GiB VPS
- **Full statement**: VictoriaMetrics + VictoriaLogs + Alloy + Grafana is near-optimal for RAM/disk footprint on a 6 vCPU / 11 GiB VPS, though gaps may exist in continuous profiling (eBPF/Pyroscope), distributed tracing (Tempo/VictoriaTraces/ClickHouse), or lighter query/UI tools (Perses, VictoriaUI).
- **Validation / Falsification plan**: Research modern 2025–2026 observability stacks + measure live RSS/disk footprint on `astrolabe` and compare trade-offs in `RFD-0007`.

### A-011 — Hierarchical Progressive Disclosure vs Vector RAG (`VALIDATED`)
- **Full statement**: For a versioned engineering/architecture corpus of tens to hundreds of structured Markdown files, a 5-layer progressive-disclosure hierarchy (`INDEX.md` → YAML frontmatter/abstracts → compiled RFDs/ADRs → raw dossiers) navigated via native file tools (`rg`, sliced `read_file`) yields higher reasoning accuracy, lower token cost, and zero chunk/index rot compared to naive vector RAG.
- **Verdict**: `validated` (2026-11-23) via [`RES-0001`](research/RES-0001-methodology-and-knowledge-architecture.md); revisit only if corpus scales beyond ~500+ unstructured documents where local BM25/FTS5 hybrid search adds value.

### A-012 — Decoupling Human Generated Docs from Git Working Tree
- **Full statement**: Moving large auto-generated human documentation trees out of Git (e.g., publishing as a static site or CI artifact) while keeping crisp hand-authored ADRs/specs + a tiny LLM-optimized index in-repo removes commit churn without hurting developer or agent productivity.
- **Validation / Falsification plan**: Analyze in `RFD-0008` with concrete token-usage and workflow comparisons.
