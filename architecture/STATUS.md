---
id: ARCH-STATUS
title: Redesign Program Live Status Dashboard
type: status
status: active
created: 2026-11-23
updated: 2026-11-25
domain: meta
tags: [status, dashboard, roadmap]
summary: Single-page live operational state of the nixconf v2 architectural redesign on branch design/v2.
---

<!-- abstract:start -->
## Executive Abstract

Live status dashboard for the **Antikythera (`aky`, `LW-54/antikythera`)** ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 3 — Stage `3A` Structural Kernel ✅ + `W1` Pure Zero-Sugar Walking Skeleton ✅ + Stage `3B` ALL Cross-Cutting Planes ✅ (`ADR-0011`..`ADR-0013`) + Stage `3C.1` Storage/Backups/Compute ✅ (`ADR-0014`) + Stage `3C.2` Six-Pillar Observability/SST/Lossless-Archival/AI-Ops ✅ (`ADR-0015`, `EXP-0011..0013`) → Entering Stage `3C.3` (Knowledge, Docs `A-012`, CLI/UX & DevShells)**!
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Project Identity**: **Antikythera (`aky`, `LW-54/antikythera`)** *(ratified in `ADR-0008` + `ADR-0013`)*
- **Current Phase**: **Phase 3 — Stage `3C.2` Observability, `E3` SST Spine, Lossless Archival & AI Ops RATIFIED (`ADR-0015`, `A-010` falsified/replaced) → Ready for Stage `3C.3` (Knowledge, Docs `A-012`, CLI/UX & DevShells)!**
- **Last Updated**: 2026-11-25

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (`B > E > D > A > C`), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001`..`AUD-0004` (50k LOC census, live `astrolabe` baseline, fleet boundary matrix) |
| **2A** | Foundational Decisions & Red-Team Synthesis | **Complete** | `RES-0003`..`RES-0011`, `EXP-0001`..`EXP-0004`, `ADR-0002`..`ADR-0006` (`ADR-0001` superseded), `spec/FOUNDATION.md` |
| **2B** | Formal Mathematical Specification, Rival-Theory Audit & Production Verification | **Complete** | `RES-0012`..`RES-0013`, `EXP-0005` (v0.2), `ADR-0007`, **`PAPER-FOUNDATION` v2.0**, `architecture/formal/` (**35 Lean 4 theorems**, **11 TLC invariants + 8 tests**, **2,005-fleet 1:1 modular Rust↔Lean4 DRT**) |
| **3** | Concrete Realization, Risk Burn-Down & Walking Skeleton (`RES-0014`) | **Active (`3C.3`)** | **3A** Structural Kernel ✅ (`ADR-0008`..`ADR-0010`) → **`W1` Walking Skeleton ✅ (`v2/`, `EXP-0009`)** → **3B** ALL Cross-Cutting Planes ✅ (`ADR-0011`..`ADR-0013`) → **3C.1** Storage/Backups/Compute ✅ (`ADR-0014`) → **3C.2** Obs/SST/AI ✅ (`ADR-0015`, `EXP-0011..0013`) → **3C.3** Docs/UX (NEXT) → **3D** CCA, `M1-Sunset` Cutover & Factorization |
| **4** | Full v2 Implementation & `M1-Sunset` Cutover (`x240` → `astrolabe`) | Queued | Production build on top of Walking Skeleton + zero-carry-forward live cutover & legacy deletion |

---

## Active & Open Items

- **Ratified Foundational Decisions**:
  - **`ADR-0002` (`accepted`) — Decision 1**: Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries ($\Sigma$).
  - **`ADR-0003` (`accepted`, supersedes `ADR-0001`) — Decision 2**: Unified Hard/Soft Conditional Promise Algebra, `B3` Cardinality-Checked Scoped Binding, `P-Dual` (Strict `P-Explicit` Dressed Superagents + Transparent Profiles), and Strict Stratification + Commutative Keyed Aggregation.
  - **`ADR-0004` (`accepted`) — Decision 3**: `L3+` Offline Root Identity + Attenuated Capabilities + **Boolean Set-Algebra Authorization** ($\cup, \cap, \in, \setminus$ over agent attributes/groups) and `S2+` **Mandatory Agent-Declared State-As-Promise** with open composable traits.
  - **`ADR-0005` (`accepted`) — Decision 4**: `C3` Triadic Calibrated Autonomous Pull with self-assessing atomic switches & auto-rollback, and `E3` Semantic Spacetime $\gamma(3,4)$ universal epistemic spine over specialized bulk telemetry & trust-budgeted assessment.
  - **`ADR-0006` (`accepted`) — Foundational Corollaries**: 7 red-team corollaries (`C1`–`C7`) closing lifecycle genesis/revocation/break-glass, Boundary-First Stratification, Ousterhout/foreign wrapping, Budgeted Capacity, epistemic zoom, portable user-space, and tri-purpose probes.
  - **`ADR-0007` (`accepted`) — Phase 2B Formal Verification (`F3-b`)**: AWS Cedar VGD (Lean 4 verified oracle + Quint/TLC models + Rust production engine + DRT) + 4 formal upgrades (Cedar `forbid`-dominance, Biscuit offline attenuation, TUF downgrade/freeze/mix-and-match defense on `C3`, CALM monotonicity on `S2+`).
  - **Verified Constitution & Paper**: [`spec/FOUNDATION.md`](spec/FOUNDATION.md) + [`paper/FOUNDATION-PAPER.md`](paper/FOUNDATION-PAPER.md) (**Phase 2A + 2B COMPLETE**).
  - **`ADR-0008` (`accepted`) — Stage `3A.1` (`Antikythera` / `aky`, `A2` + `S1`)**: Split `*.toml` Boundaries Everywhere + Pure `interior.nix` + Zero-Artifact Parallel Read (`builtins.fromTOML`, zero IFD, `5.79 ms` zero-Nix verification, Three-Tier Power Stratification).
  - **`ADR-0009` (`accepted`) — Stage `3A.2` (`P1` + `W-Std` + `R-Crane` + `F-Hermetic`)**: Plain `flake.nix` + `flake.lock` (~45 LOC), zero-dep pure `nixpkgs` standalone wrappers, single `crane` Cargo workspace + unified 4-language quality gates (`LW-54/rust-env` + `unsafe_code = "forbid"` + `cargo-deny`), and offline hermetic Lean/Quint Nix sandboxes.
  - **`ADR-0010` (`accepted`) — Stage `3A.3` (`Open Orthogonal Substrates` + `I1` + `H2`)**: Arbitrary-axis composable Substrate Agents (zero fixed axis count / zero inheritance), sealed `impermanence` auto-consuming `[state.*]`, and sealed standalone-capable `feel-co/hjem`.
- **Walking Skeleton Gate (`W1`) + `F1` + Pure Zero-Sugar Core PASSED (`v2/`, `EXP-0009`)**:
  - Live runnable **100% usage-agnostic, zero-sugar** Antikythera core (`4` flake inputs, 0 `home-manager`, **0 domain strings** in `Aky/Spec/*` and `aky-core/src/*`), **41 machine-checked Lean 4 theorems (0 `sorryAx`)** over recursive `Agent` trees (`checkAgentTree_substitution_invariant`), declarative `AttrExpr` `PromiseInvariant`s (CALM as pure data), mandatory `Broadcast`/`Partitioned` binding, and NixOS `{ config, ... }:` backdoor blocking (`assertNonPiercingNixos`).
  - `7/7` hermetic checks passing (0 warnings), **`2,003/2,003` recursive-tree Rust↔Lean DRT (0 divergences)**, bit-for-bit `S1` Rust==Nix equivalence, byte-for-byte identical `astrolabe` & `live-iso` `.drv` hashes, and `2.39 ms` zero-Nix `aky check`.
  - **Ergonomics Policy Locked**: Build initial production implementation on raw primitives first; defer syntactic sugar & factorization helpers to a dedicated post-architecture Ergonomics phase once Stages `3B`–`3D` provide global vision.
- **Stage `3B` Cross-Cutting Planes COMPLETE**:
  - **Ratified `ADR-0011` (`accepted`) — Stage `3B.1` (`S-Sops` + `C-Pragmatic`)**: Sealed `sops-nix`, Cedar→`.sops.yaml` compiler & audit, multi-recipient Vaultwarden + offline break-glass `age` & emergency SSH keys, LUKS2+TPM2-PIN+Lanzaboote, `LoadCredential=`, OIDC/CLI tokens, `biscuit-auth`.
  - **Ratified `ADR-0012` (`accepted`) — Stage `3B.2` (`M-Tailscale` + `H-TailnetTLS` + Dual SSH)**: Sealed `mesh-tailscale` (Personal Free \$0, 0 server RAM, GitOps `policy.hujson`, zero dormant Headscale bloat while retaining `config:mesh-control-url` swappability), Tailscale SSH + key-only `sshd`, `*.ts.net` Caddy auto-certs & split-horizon firewall.
  - **Ratified `ADR-0013` (`accepted`) — Stage `3B.3` (`P-AkyPull` + `BC-Niks3` R2 + `U-SplitGHA` + `Perm-AgentApp` + `M-FleetBare + Codeberg`)**: Zero-eval Rust `aky pull` + TUF `calibration.json` + $\alpha$ auto-rollback + `systemd-boot.bootCounting`; `niks3 1.16.0` on Cloudflare R2 (`cache.adje.app`, GitHub OIDC, retiring B2/Attic/Cachix/CI-SOPS); free `ubuntu-24.04-arm` multi-arch CI; `LW-54/antikythera` strict PR-only `main` + locked `calibrated` Rulesets + `dix`/`gitleaks`; fleet-wide `~3–15 MiB` offline bare mirrors + Codeberg + `3-2-1-1-0` R2 WORM/Hetzner Box/metadata backups.
- **Stage `3C.1` Storage, Backups & Opportunistic Compute RATIFIED (`ADR-0014`, `EXP-0010`, `A-009` VALIDATED)**:
  - `ST-UnifiedRestic` (native S3 R2 `< \$2/mo` w/ prefix-scoped Governance WORM, tuned SFTP `hbox`, optional `gdrive`, home-laptop `restic-rest-server`, substrate-isolated `btrbk` + Linux 6.18 Btrfs `squota`); `SP-GitAnnex` (`0 MiB` idle, client-encrypted `gdrive`) + workstation-only `harmonia` + `Copyparty` + optional `Syncthing`; sandboxed `DC-NATS-Pull` (`services.nats` JetStream `20.8 MiB`, allowlisted/signed Nix closures, NATS `submitter`/`worker` RBAC) + workstation `nix.buildMachines` + universal AC lid-closed mode (session lock, battery hysteresis `35%/25%`, `80/90 °C` thermal watchdog, metered-link byte quotas).
- **Stage `3C.2` Six-Pillar Observability, `E3` SST Spine, Lossless Archival & Stratified AI Ops RATIFIED (`ADR-0015`, `EXP-0011..0013`, `A-010` FALSIFIED/REPLACED)**:
  - `COL-FluentNode` (`44.4 MiB`, `100%` `SIGKILL` crash-safe vs. falsified `vlagent`) + native cgroups v2/PSI (`768` vs `6,166` cAdvisor series) + structured journald (`SD_MESSAGE_UNIT_RESOURCES`) + Observability 2.0 wide JSON events + battery-adaptive sampling (`15s`/`30s`/`60s`), privately over Tailscale `zone:mesh`; `VictoriaStack` (`VM` + `VL` + `VictoriaTraces` `17.5 MiB`) + `ARC-LosslessKeepAll` (`1–3y` hot + `1h` mergeable rollups `45.8×` faster + 100% lossless pre-redacted `DuckDB 1.5.5` zstd-9 Parquet on `hbox`/`git-annex` + compact R2 mirror); `UI-PersesPure` (`Perses 0.54.0`, `89.9 MiB`, 64 built-in plugins, 5-step GQM/Endsley/Shneiderman/Cleveland–McGill generative dashboards); Tri-Purpose Probes (`C7`) → MWMBR SLOs + Availability Classes + Tiers 1–4 deterministic math/stats (`Theil–Sen`/`CUSUM`/`collapse_nums`/SST collapse + Weekly Digest) + Tier 5 read-only Biscuit MCP & `AI-EscalatedPR` strictly for semantic last-mile value (`~525–580 MiB` total on `astrolabe` = `2.6×` lighter than v1!).
- **Next Step — Stage `3C.3` (Knowledge, Documentation `A-012`, CLI/UX & Portable DevShells/Templates)**:
  - Audit v1 `meta/docs/` (169 generated Markdown files causing pre-commit churn), `Justfile`, `devShells`, and `nixprof`; research 2025–2026 static doc generation + LLM progressive-disclosure indices (`A-012`), unified `aky` CLI UX, and standalone portable DevShell/project templates.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **9** (`A-001`, `A-002`, `A-003`, `A-004`, `A-005`, `A-007`, `A-009`, `A-011`, `A-013`)
- Experimenting: **2** (`A-006`, `A-008` — queued for Phase 4 QEMU runtime/fault-injection tests)
- Unverified: **1** (`A-012`)
- Falsified: **1** (`A-010` — v1 `Alloy + Grafana` Pareto assumption disproven by `EXP-0011..0013` and replaced by `ADR-0015`)
