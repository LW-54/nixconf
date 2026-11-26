---
id: ADR-0017
title: Stage 3D Final Synthesis — Four-Repo Norse Ecosystem (Baugr -> Verft -> Ivaldi -> Skidbladnir), Unix Tooling, Certified Per-Repo Formal Standards (F-1..F-6), 7 Deep Unifications & ERG-L2
type: adr
status: accepted
created: 2026-11-26
updated: 2026-11-26
domain: synthesis
tags: [adr, stage-3d, baugr, verft, ivaldi, skidbladnir, unix-philosophy, certikos, formal-methods, progress-preservation, tlc-liveness, falsification, erg-l2, m1-sunset, four-repo]
rfd: null
assumptions: [A-001, A-002, A-003, A-004, A-005, A-006, A-007, A-008, A-009, A-010, A-011, A-012, A-013]
supersedes: []
superseded_by: null
summary: Ratifies Stage 3D Final Synthesis (completing Phase 3 Architecture Design and amending ADR-0008, ADR-0012, ADR-0013, ADR-0016): adopts the strictly layered 4-repo Norse + Unix + hjem/rum ecosystem (baugr -> verft -> ivaldi -> skidbladnir, archiving nixconf post-cutover and freeing astrolabe/antikythera as physical host names), splits the CLI into small sharp Unix tools piped via JSON plus a thin dispatcher & justfile, enforces CertiKOS per-repo formal verification closing all 6 gaps F-1..F-6 (54 Lean 4 theorems incl. Resolve Progress & Preservation, 514/514 DRT, falsifiable Quint/TLC safety + temporal liveness), locks all 7 Deep Unifications & 10 oversight fixes, and ratifies ERG-L2 schema-driven desugaring + M1-Sunset cutover.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3D` Final Synthesis** (completing all of **Phase 3 Architectural Design** across `ADR-0002`–`ADR-0016`), grounded in [`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md), [`RES-0025`](../research/RES-0025-architectural-audit-formal-review-and-scope-stratification.md), and the machine-verified `W2.2` capstone ([`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)):
1. **Four-Repo Ecosystem & Norse Quartet** *(amending `ADR-0008` / `ADR-0013` repository naming and freeing `astrolabe` & `antikythera` for physical hosts)*: **`LW-54/baugr`** (L0 universal Promise Theory + SST framework; `0` Nix, `0` Linux, `0` domain strings) <- **`LW-54/verft`** (L1 `hjem`-style minimal Nix/Linux realization engine + Unix runtime tools; `0` prebuilt agents) <- **`LW-54/ivaldi`** (L2 `hjem-rum`-style optional prebuilt reusable agent library; `0` personal data, flat barrier-free fractal namespace organized purely by human folders) <- **`LW-54/skidbladnir`** (L3 personal situated foldable fleet replacing archived `nixconf`).
2. **Unix Philosophy Across CLI & Runtime** *(amending `ADR-0016` `CLI-AkyPlusThinJust`)*: Splits monolithic CLI into small sharp single-purpose binaries speaking canonical JSON/TOML streams (`baugr`, `baugr-doc`, `verft-pull` tiny host daemon, `verft-cap` Linux `CLONE_NEWNS` supervisor, `nixprof`, stateless `ivaldi/emitters/{sops,tailscale,nats}`), with an optional thin `git`-style `verft` dispatcher one layer up and per-repo `<= 40`-LOC `justfile` shortcuts.
3. **CertiKOS Per-Repo Formal Verification (`F-1`–`F-6` Closed)**: Each repo owns its own formal pillar — **`baugr`**: 54 Lean 4 theorems (`0 sorryAx`, split `Baugr.Theory.*` <- `Baugr.Engine.*`, **Type Soundness Progress & Preservation `valid_agent_tree_resolves_safely`**, `Agent.atomic` principal auth, tight `outboundFromExterior`, dead `HandlerRule` pruned, `514/514` DRT covering checker + `Resolve` + `SST` + Cedar); **`verft`**: mechanism-faithful Quint/TLC verifying positive safety + **temporal liveness** (`triadic_pull_tlc`, `97,141` states) AND mechanically **falsifying** naive `userspace_drop` (`SIGKILL` leak) & `vaultwarden_only` (DR deadlock) + `S1` Rust == Nix equivalence; **`ivaldi`**: synthetic-host checks + reusable KVM QEMU fault-injection suite; **`skidbladnir`**: full fleet gate + 6-plane Cedar projections + adversarial tests + `vm-*` gates.
4. **7 Deep Unifications, 10 Oversight Fixes, `ERG-L2` & `M1-Sunset`**: Ratifies all 7 Deep Unifications and 10 Stage `3D` fixes (amending `ADR-0012` decoupled `caddy-public`/`caddy-mesh` & `ADR-0013` R2 CDN write-server independence + `failedEpochs`), data-driven `schemas/promises.toml` Layer-1 total desugaring (`ERG-L2`), and clean bottom-up Phase 4 execution across the 4 fresh repos before archiving `nixconf`.
<!-- abstract:end -->

# ADR-0017: Stage 3D Final Synthesis — `Baugr` -> `Verft` -> `Ivaldi` -> `Skidbladnir`, Unix Tooling & Certified Formal Standards

---

## 1. Context & Problem Statement

Full-platform composition of all 15 ratified ADRs (`ADR-0002`–`ADR-0016`) in `W2`–`W2.1` ([`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)) followed by a ground-up architectural & formal-methods audit ([`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md), [`RES-0025`](../research/RES-0025-architectural-audit-formal-review-and-scope-stratification.md)) identified four structural improvements required before entering Phase 4 implementation:
1. **Scope & Privacy Separation Without Artificial Composability Walls**: Combining a universal Promise Theory engine, a NixOS realization runtime, reusable infrastructure/app agents, and personal hosts/secrets in one repo conflates unrelated audiences and leaks personal history into open-source tooling — *yet* imposing hard boundaries between "platform agents" and "app agents" would violate Fractal Uniform Agency (`ADR-0002`).
2. **Unix Tooling Over a Monolithic God-CLI**: Bundling pure static verification, Linux `CLONE_NEWNS` sandboxing, a production server TUF daemon, Nix profiling, and Nix build shortcuts into one binary mixes distinct closures and lifecycles.
3. **Six Formal-Methods Gaps (`F-1`–`F-6`)**: Vacuous Quint invariants in `capability_session.qnt` & `lifecycle_recovery.qnt`, missing Lean 4 Progress & Preservation (`checkAgentTree -> resolveAgentTree`), dead `HandlerRule` spec vs. un-DRT'd `Spacetime`, missing TLC + temporal liveness on `triadic_pull.qnt`, conflation of pure Burgess Promise Theory with engine extensions, and an `Agent.atomic` principal auth blind spot (`actor-gha-ci`).
4. **Seven Deep Unifications, Ten Cross-Plane Oversights & Ergonomics (`ERG-L2`)**: Closing the Vaultwarden DR deadlock (`recovery.sops.yaml`), R2 WORM vs. Restic retention ordering, impermanent root boot-loop suppression (`failedEpochs`), `caddy-public` independence from `tailscaled`, and ~3.3x raw TOML compression via data-driven `schemas/promises.toml`.

---

## 2. Decision Outcome

### 2.1 Four-Repository Norse + `hjem`/`rum` + Promise-Theory Ecosystem
Amends `ADR-0008` / `ADR-0013` repository identity (freeing `astrolabe` and `antikythera` for physical hosts) and adopts **4 clean, fresh repositories** initialized directly from the verified `v2/` blueprint (archiving `nixconf` once live cutover completes):

| Layer | Repository | Analogy & Role | Strict Boundary | Own Formal Pillar (CertiKOS CAL) |
| :---: | :--- | :--- | :--- | :--- |
| **L0** | **`LW-54/baugr`** *(Old Norse: Oath Ring)* | Universal Promise Theory & Semantic Spacetime $\gamma(3,4)$ framework (usable for K8s, Terraform, microservices, AI multi-agent governance, ECS, orgs, or NixOS) | **0 Nix, 0 Linux, 0 domain strings.** Ships Lean 4 `Baugr.{Theory,Engine,Oracle}`, `std::fs`-free Wasm-ready `baugr-core`, `baugr` CLI, `baugr-doc` filter, `ERG-L2` schema desugarer, and golden conformance fixtures. | **`F0`**: 54 Lean 4 theorems (`0 sorryAx`), `Baugr.Theory` <- `Baugr.Engine`, `Resolve` Progress & Preservation, `514/514` DRT (checker + `Resolve` + `SST` + Cedar), zero-domain-string guard. |
| **L1** | **`LW-54/verft`** *(Nordic: Shipyard)* | Minimal Nix/Linux realization engine (`hjem`-like) + independent Unix runtime tools | **0 prebuilt opinionated agents.** Ships multi-root recursive `lib/realize.nix`, `assertNonPiercingNixos`, `verft-pull` (tiny static host TUF daemon), `verft-cap` (`CLONE_NEWNS` + `PR_SET_PDEATHSIG`), `nixprof`, and optional thin `git`-style `verft` dispatcher. | **`F1`**: Mechanism-faithful Quint/TLC verifying positive safety + temporal liveness (`triadic_pull_tlc`) AND negative counterexample falsifications (`userspace_drop` SIGKILL & `vaultwarden_only` DR deadlock) + `S1` Rust == Nix equivalence + non-piercing proofs. |
| **L2** | **`LW-54/ivaldi`** *(Sons of Ivaldi)* | Optional prebuilt reusable Agent & Contract Library (`hjem-rum`-like) | **0 personal hostnames/domains/secrets; 0 artificial composability barriers.** Ships `schemas/promises.toml`, `policies/platform.toml` (`CALM`, `split-horizon`, generic `auth_bindings`), stateless Unix `emitters/{sops,tailscale,nats}`, `profiles/`, and flat logical fractal `agents/{substrates,trust,mesh,gitops,storage,compute,obs,apps,dev,docs}/` keeping natural clean agent names. | **`F2`**: Synthetic-host `< 5 ms` contract checks + reusable KVM QEMU fault-injection suite (`A-006` offline boot, `A-008` boot-counting rollback, `SIGKILL` spool recovery, Btrfs `squota`, Restic WORM retention). |
| **L3** | **`LW-54/skidbladnir`** *(Foldable Fair-Wind Ship)* | Personal situated fleet (replaces archived `nixconf`) | Composes `ivaldi`'s agents + bespoke personal agents in **one barrier-free fractal namespace** (`agentRoots = [ ivaldi.agentsDir ./agents ]`): personal hosts (`astrolabe`, `antikythera`, `x240`, `tuf`, `zenbook-duo`, `chromebook`, `rpi`, `wsl`, `live-iso`), actors, personal Cedar policies, and encrypted `secrets/*.sops.yaml` (incl. cold `recovery.sops.yaml`). | **`F3`**: Full fleet `baugr check`, 6-plane Cedar projections, 12-attack adversarial regression suite, and `vm-*` integration QEMU gates. |

### 2.2 Unix Philosophy CLI & Pipe Architecture (Amending `ADR-0016`)
- Small, single-purpose binaries communicating via canonical JSON/TOML `stdin`/`stdout` streams:
  - `baugr` (`check`, `resolve`, `explain`, `blast-radius`, `project`, `graph`, `schema-json`, `drt`)
  - `baugr-doc` (`baugr graph --json | baugr-doc --out <dir>`)
  - `emitters/{sops,tailscale,nats}` (`baugr project <action> --json | emitters/<plane>`)
  - `verft-pull` (minimal static host daemon — zero dev tooling on VPS/RPi!)
  - `verft-cap` (standalone Linux `CLONE_NEWNS` ephemeral capability supervisor)
  - `nixprof` (standalone Nix eval/build & `cache-diff` profiler)
- Optional thin `git`-style `verft` dispatcher one layer up (`verft <subcmd>` invoking the underlying tools with zero duplicated logic), plus a `<= 40`-LOC transparent per-repo `justfile` for pure workflow shortcuts (`just vm`, `just fmt`, `just check-host`).

### 2.3 Seven Deep Unifications, Ten Stage 3D Fixes & `ERG-L2`
1. **Unifications & Fixes ([`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md))**:
   - Ephemeral capability sessions modeled as pure transient Superagents verified by `baugr` and isolated by `verft-cap` (`CLONE_NEWNS` + `PR_SET_PDEATHSIG`).
   - Unified 6-plane Cedar SSOT (`secret:claim`, `cap:claim`, `agent:class`, `mesh:service`, `nats:claim`, `obs:scope`) with zero ghost host/session offers.
   - Symmetric decoupled `caddy-public` (zero `tailscaled` dependency, amending `ADR-0012`) vs. `caddy-mesh`; `obs-hub` decomposed into 6 swappable atomic daemons; orthogonal `target-nixos-*` vs. `fs-*` substrates; multi-instance outbound offer key namespacing (`"{instance}:{key}"`, `QA-02`).
   - Cloudflare R2 CDN read path strictly independent of local `niks3` write server; `failedEpochs` persisted on `/persist` preventing boot-crash loops; `keepDaily > wormLockDays` R2 WORM retention rule; cold `recovery.sops.yaml` eliminating the Vaultwarden DR deadlock.
2. **Ergonomics (`ERG-L2`)**: Data-driven `schemas/promises.toml` Layer-1 total desugaring (`baugr` core reads schemas as pure data — `0` domain strings in Rust/Lean; `S1` Rust == Nix equivalence enforced against golden conformance fixtures).
3. **Bottom-Up Phase 4 Execution & `M1-Sunset` Cutover**:
   - Initialize the 4 fresh repos cleanly from the verified `v2/` `W2.2` blueprint:
     1. **`baugr` `v0.1.0`**: Land `ERG-L2` schema desugarer + `schema-json` + golden conformance suite.
     2. **`verft` `v0.1.0`**: Wire `lib/realize.nix` + `verft-pull` + `verft-cap` + `nixprof` + thin `verft` against `baugr v0.1.0`.
     3. **`ivaldi` `v0.1.0`**: Replace stub `interior.nix` with real NixOS/standalone modules, `emitters/*`, and reusable KVM QEMU fault-injection gates (`A-006`, `A-008`).
     4. **`skidbladnir`**: Realize personal hosts, execute `M1-Sunset` live cutover (`x240` -> `astrolabe` + remaining fleet), and archive `nixconf` cleanly.

---

## 3. Verification & Empirical Proof (`W2.2` Capstone in `v2/`)

Mechanically verified via `nix build --no-link -L ./v2#checks.x86_64-linux.*` (**8 / 8 checks GREEN**) and the 12-attack adversarial suite ([`EXP-0015` §7](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)):
- **`baugr-lean-audit`**: `54 / 54` Lean 4 theorems (`0` warnings, `0 sorryAx`), including `valid_agent_tree_resolves_safely` (Type Soundness Progress & Preservation), `resolve_parent_scope_non_piercing`, `imposition_never_cooperates`, `siblingFollowsEdges_non_piercing`, and `checkAgentTree_atomic_sound`.
- **`baugr-{fmt,clippy,test}` + `baugr-doc-pipe`**: `0` warnings (`clippy::pedantic --deny warnings`), `9 / 9` unit tests (zero-domain-string guard passing across all 9 `baugr-core` modules), and clean Unix pipe `baugr graph --json | baugr-doc`.
- **`verft-quint-check`**: All 4 hardened models exhaustively TLC-verified (`triadic_pull_tlc`: `97,141` states / `33,326` distinct, `0` safety & temporal liveness violations) AND naive `userspace_drop` & `vaultwarden_only` models mechanically **falsified** by TLC in CI.
- **`skidbladnir-fleet-and-drt` + `verft-s1-equiv`**: `14 / 14` real superagents (`63` agents across `ivaldi` + `skidbladnir` folders) verified in `6.00 ms`, `514 / 514` DRT `0` divergences (checker + `Resolve` + `SST` + Cedar), `12 / 12` `S1` Rust == Nix `0` diffs, `12 / 12` adversarial attacks blocked statically, and `0` cross-layer / cross-host `.drv` cache busts.

---

## 4. Links
- Research Dossiers: [`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md), [`RES-0025`](../research/RES-0025-architectural-audit-formal-review-and-scope-stratification.md)
- Empirical Proof: [`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)
- Amended ADRs: [`ADR-0008`](ADR-0008-authoring-medium-toml-boundaries-nix-interiors-and-zero-artifact-seam.md), [`ADR-0012`](ADR-0012-mesh-fabric-tailscale-dual-ssh-and-split-horizon-tls.md), [`ADR-0013`](ADR-0013-gitops-tuf-pull-niks3-r2-governance-and-resilience.md), [`ADR-0016`](ADR-0016-docs-methodology-agent-cli-composable-capabilities-and-devshells.md)
