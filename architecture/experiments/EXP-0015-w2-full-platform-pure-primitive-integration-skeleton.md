---
id: EXP-0015
title: W2 Full-Platform Pure-Primitive Integration Skeleton — 15-ADR Composition, 47 Lean 4 Theorems, 4 Quint/TLC Models, 9/9 Adversarial Attacks & 6-Target Cross-Arch Non-Piercing Nix Verification
type: experiment
status: active
created: 2026-11-25
updated: 2026-11-25
domain: synthesis
tags: [experiment, w2-skeleton, stage-3d, lean4, quint, tlc, drt, s1-equivalence, cedar, broadcast, adversarial-testing, cache-isolation, aarch64]
assumptions: [A-001, A-002, A-003, A-004, A-005, A-007, A-009, A-011, A-012, A-013]
summary: Empirical full-platform pure-primitive integration stress-test (W2) composing all 15 ratified ADRs (ADR-0002..ADR-0016) and all 7 Stage 3D Deep Unifications on 100% raw zero-sugar primitives (0 domain strings in Lean 4 Aky/Spec/* or Rust aky-core/src/*). Verifies 47/47 Lean 4 theorems (0 sorryAx), 4 Quint/TLC specs (incl. new capability_session.qnt), 11/11 real superagents in 4.19 ms, 511/511 DRT bit-for-bit matches against Lean 4, 10/10 S1 Rust==Nix equivalence, 6/6 real heterogeneous NixOS .drv evaluations (x86_64 & aarch64), 9/9 adversarial attacks blocked statically, and 100% non-piercing cross-host cache isolation.
---

<!-- abstract:start -->
## Executive Abstract

Validates whether Antikythera's **fundamental pure zero-sugar primitives** hold up rigorously when **all 15 ratified ADRs (`ADR-0002`–`ADR-0016`)** and **all 7 Stage `3D` Deep Unifications** ([`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md)) are composed simultaneously from scratch in `v2/` — with **zero syntactic sugar**, **zero premature abstractions**, and **zero domain strings** in `Aky/Spec/*` or `aky-core/src/*`.

### Headline Empirical Results
- **47 / 47 Lean 4 Theorems Verified (`0 sorryAx`, `0` warnings)**: Upgraded formal kernel with symmetric `AttrExpr`-filtered `Broadcast` (`M:N` fan-out), tag-preserving `-b` forwarding (`hasBackingUse`), and usage-agnostic structural Cedar `AuthBinding` inside `checkAgentTree`.
- **4 / 4 Quint Protocols + Exhaustive TLC Verified**: Upgraded `triadic_pull.qnt` (`failedEpochs` boot-loop suppression + `niks3` write-server independence, `30,000` test traces) and added `capability_session.qnt` (`89` TLC states, `24` distinct, `0` remaining, `0` violations proving `CLONE_NEWNS` zero host residue on `SIGKILL`!).
- **11 / 11 Real `W2` Superagents Verified in `4.19 ms` (`511 / 511` DRT `0` Divergences)**: Composed top-level recursive `fleet` containing `astrolabe`, `x240`, `tuf`, `rpi` (`aarch64`), `wsl`, `live-iso`, `web-stack`, 5 external boundary stubs, and 3 pure-`Agent` capability sessions (`cap-admin-session`, `cap-breakglass-session`, `cap-ai-session`).
- **10 / 10 `S1` Rust == Nix Bit-for-Bit Equivalence & 6 / 6 Real Heterogeneous NixOS `.drv` Evaluations**: Cross-host `fleet` endpoints (`obs-ingest`, `nats-broker`, `r2-cdn`, `r2-worm`, `hbox-sftp`) resolved cleanly across `Σ` into real NixOS configurations (`x86_64-linux` & `aarch64-linux`) + standalone `git`.
- **9 / 9 Adversarial Security, Isolation, CALM & Budget Attacks Blocked Statically (`100%`)** + **100% Cross-Host Non-Piercing Cache Isolation** (`0` `.drv` busts on `x240`, `tuf`, `rpi`, `wsl`, `live-iso`, `git` when mutating `astrolabe/web-stack/vaultwarden/interior.nix`!).
<!-- abstract:end -->

# EXP-0015: `W2` Full-Platform Pure-Primitive Integration Skeleton

---

## 1. Motivation & Experimental Hypothesis

Prior walking skeleton `W1` ([`EXP-0009`](EXP-0009-w1-zero-sugar-pure-core-verification.md)) only modeled 2 toy targets (`astrolabe` w/ `vaultwarden`+`caddy`, and `live-iso`). Before locking Stage `3D` and entering Phase 4 implementation, we tested the strict hypothesis:

> **Hypothesis**: *All 15 ratified ADRs (`ADR-0002`–`ADR-0016`) — spanning Trust/SOPS/Cedar, Tailscale split-horizon Caddy, TUF `P-AkyPull` + R2 `niks3`, Restic WORM + Btrfs `squota`/`btrbk` + `git-annex` + `NATS` AC compute donor + workstation `harmonia`, `COL-FluentNode` + `VictoriaStack` + `Perses` + `DuckDB` Parquet, `mdBook` docs, and ephemeral `aky with` capabilities — can be unified and verified end-to-end using **ONLY** our minimal usage-agnostic formal primitives (`0` domain strings in Lean/Rust, `0` syntactic sugar), with zero real-world hacks.*

**Falsification Outcome**: Attempting this full composition **immediately falsified 4 latent `W1` kernel defects** (`O-1`..`O-4` in [`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md)):
1. `Partitioned` caused fatal `OverlappingPartitionHandlers` crashes on multi-consumer `state:persist` & `probe` → fixed via symmetric `AttrExpr`-filtered `Broadcast`.
2. `resolveTree` stripped `tags` and double-nested `Broadcast`/`Partitioned` maps across nested Superagent boundaries → fixed via lossless `inboundStructured` forwarding.
3. `verify_fleet` / `checkAgentTree` did not enforce Cedar `L3+` policies structurally during `aky check` → fixed via usage-agnostic `AuthBinding` + SSOT principal/resource derivation (`aky project`).
4. First live `W2` run caught synthetic `outboundFromExterior` sinks tripping `isScopeAuthValid` on `astrolabe` → fixed by scoping `isScopeAuthValid` strictly to real interior child promises (`intPs`).

---

## 2. Formal Kernel & Protocol Verification Results (`7 / 7` Hermetic Nix Checks)

Command: `nix build --no-link -L ./v2#checks.x86_64-linux.{rust-fmt,rust-clippy,rust-test,lean-audit,quint-check,aky-fleet-and-drt,s1-binding-equiv}` — **ALL 7 exited `0`**:

| Check Derivation | Exact Empirical Result |
| :--- | :--- |
| **`lean-audit`** (`aky-oracle-0.2.0`) | **47 / 47** Lean 4 theorems compiled (`32 s`, `0` warnings) & audited via `Aky/Audit.lean` (**0 `sorryAx`**, standard axioms only). New theorems: `conforms_no_dropped_mandatory_broadcast_offers`, `broadcast_mandatory_offer_handled_sound`, `broadcast_subscriber_non_interference`, `validateScopeAuth_nil_iff_valid`, `scope_auth_sound`, `scope_auth_forbid_blocks_promise`, plus updated `checkAgentTree_substitution_invariant`. |
| **`quint-check`** (`aky-quint-check`) | **4 / 4** specs passed: `triadic_pull.qnt` (`30,000` test traces incl. `niks3WriteServerDown` + `midSwitchPowerCrashRecoveryAndFixTest`), `lifecycle_recovery.qnt` (TLC exhaustive), `conditional_degradation.qnt` (TLC exhaustive), and new **`capability_session.qnt`** (**89 states generated, 24 distinct, 0 remaining, 0 violations in `1.29 s`**). |
| **`rust-fmt` & `rust-clippy`** | `--deny warnings` (`clippy::pedantic`) passed `0` warnings. |
| **`rust-test`** | `7 / 7` unit tests passed, including automated **`purity_tests::core_kernel_contains_zero_domain_strings`** scanning every `.rs` source in `v2/crates/aky-core/src/` for 15 domain terms (`vaultwarden`, `caddy`, `tailscale`, `restic`, `perses`, `victoria`, `btrfs`, `systemd`, `astrolabe`, `state:persist`, `http:route`, `sops`, `niks3`, `nats`, `mdbook` → **0 hits**!). |
| **`aky-fleet-and-drt`** | **`11 / 11` real `W2` superagents** (`fleet`, `astrolabe`, `x240`, `tuf`, `rpi`, `wsl`, `live-iso`, `web-stack`, `cap-admin-session`, `cap-breakglass-session`, `cap-ai-session`) + `6` self-contained agents verified in **`4.19 ms`**! **DRT**: **`511 / 511`** cases matched bit-for-bit (`11` real + `500` fuzzed; Rust `13.29 ms`, Lean 4 oracle `691.91 ms`, **0 divergences**!). |
| **`s1-binding-equiv`** | **`10 / 10` targets** (`fleet`, `astrolabe`, `x240`, `tuf`, `rpi`, `wsl`, `live-iso`, `cap-admin-session`, `cap-breakglass-session`, `cap-ai-session`) diffed **0 bytes** between Rust `aky resolve` and pure-Nix `v2/lib/realize.nix`, plus `assertNonPiercingNixos` blocked `{ config, ... }:` and unauthorized `imports`. |

### Single-Source Cedar `L3+` Projections (`aky project` — Zero Duplicated `[[principals]]`/`[[resources]]`)
```text
astrolabe (read-secret) => [r2-cache-write, restic-repo, tailscale-auth, vaultwarden-master]
rpi       (read-secret) => [tailscale-auth]
tuf/wsl/x240 (read-secret) => [restic-repo, tailscale-auth]       # live-iso => [] (ZERO prod secrets!)
cap-ai-session (assume-capability) => [obs-mcp-ro]                # ALL root/admin/breakglass FORBIDDEN!
astrolabe/rpi/tuf/wsl/x240 (mesh-connect) => [nats-broker, obs-ingest]  # live-iso => [] (FORBIDDEN!)
astrolabe (nats-queue) => [nats-hub]  |  tuf (nats-queue) => [nats-worker]
```

---

## 3. Real 6-Target Heterogeneous NixOS Realization & Cross-Host Cache Isolation Proof

Evaluating `v2#nixosConfigurations` resolved from top-level `fleet` produced **6 real NixOS system derivations** (including **`aarch64-linux` `rpi`** and **diskless `wsl`**) and verified cross-host `Π_ext` wiring in `/etc/aky/*.json`:

- **`astrolabe`** (`x86_64-linux`):
  - `btrfs-snapshots.json`: `["/var/lib/postgresql", "/var/lib/vaultwarden", "/var/lib/victoriametrics"]`
  - `restic-plan.json`: `keepDaily: 21`, `wormLockDays: 14`, `repos: ["hbox-sftp", "r2-worm"]`, `paths: ["/var/lib/aky-pull", "/var/lib/caddy", "/var/lib/nixos", "/var/lib/postgresql", "/var/lib/vaultwarden"]`
  - `mdbook-manifest.json`: all `11` `/persist` paths + all `4` `sstNearDocLinks` (`zone: mesh-only`, `0 MiB` RAM)
  - `obs-victoria-hub.json`: all `8` `probesTracked` + all `11` `stateVolumesTracked`
  - `pull-rollback-probes.json`: strictly the `3` `critical` probes (`["caddy-public", "tailscale-alive", "vaultwarden-alive"]`)
  - `caddy-mesh-routes.json`: strictly `zone:mesh` routes (`docs`, `niks3`, `perses` → `*.astrolabe.tailnet.ts.net`)
- **`x240`**, **`tuf`**, **`rpi` (`aarch64-linux`)**, **`wsl`**: All automatically received `ingestTargets: ["https://obs.astrolabe.tailnet.ts.net:9428"]` from `astrolabe`'s `Π_ext` via `fleet` (`tuf` also received `brokers: ["astrolabe.tailnet.ts.net:4222"]` + `worker-only` + lid-close lock + thermal/battery guardrails).

### Empirical Non-Piercing Cache-Isolation Test (Mutating `v2/agents/vaultwarden/interior.nix` inside `fleet/astrolabe/web-stack`)

| Target | Arch | `.drv` Hash Before | `.drv` Hash After | Changed? |
| :--- | :--- | :--- | :--- | :---: |
| **`astrolabe`** | `x86_64-linux` | `33cvn27l...` | `07zmvfch...` | **YES** *(expected)* |
| **`x240`** *(consumes `astrolabe` `obs-ingest`)* | `x86_64-linux` | `xl7ywd1j...` | `xl7ywd1j...` | **NO (0 bust!)** |
| **`tuf`** *(consumes `astrolabe` `nats-broker` + `obs-ingest`)* | `x86_64-linux` | `s6548xfz...` | `s6548xfz...` | **NO (0 bust!)** |
| **`rpi`** *(consumes `astrolabe` `obs-ingest`)* | **`aarch64-linux`** | `zq0ni66b...` | `zq0ni66b...` | **NO (0 bust!)** |
| **`wsl`** *(consumes `astrolabe` `obs-ingest`)* | `x86_64-linux` | `bzh49kip...` | `bzh49kip...` | **NO (0 bust!)** |
| **`live-iso`** | `x86_64-linux` | `n1brv4ld...` | `n1brv4ld...` | **NO (0 bust!)** |
| **`git` (`W-Std` standalone)** | `x86_64` & `aarch64` | `i8pc0qar...` / `s6sbjfgz...` | identical | **NO (0 bust!)** |

---

## 4. Nine Adversarial Security, Isolation, CALM & Budget Attacks (`9 / 9` Blocked Statically)

Executed against temporary clones of the live on-disk `W2` `v2/` fleet via `aky check` (`< 5 ms` per run):

| # | Adversarial Mutation on Real `W2` Fleet | Blocked? | Exact Machine Diagnostic Emitted by `aky check` |
| :---: | :--- | :---: | :--- |
| **1** | Wire `web-stack` (`vaultwarden-master`) onto roaming `x240` | **BLOCKED** | `UnauthorizedPromise { binding_id: "ab-read-secret", principal_id: "x240", key: "vaultwarden-master" }` |
| **2** | Wire `cap-sops-root` inside `cap-ai-session` (`actor:ai-agent`) | **BLOCKED** | `UnauthorizedPromise { binding_id: "ab-assume-capability", principal_id: "cap-ai-session", key: "sops-root" }` |
| **3** | Mix offline `cap-breakglass` into online `cap-admin-session` | **BLOCKED** | `MissingBroadcastProvider { ptype: "trust:posture" }` + `DuplicateOffer { key: "slot:ssh-agent", offer_count: 2 }` |
| **4** | Wire workstation `cache-harmonia-dev` onto prod `astrolabe` | **BLOCKED** | `MissingBroadcastProvider { ptype: "host:posture" }` + `LeakedRequirement { ptype: "host:posture" }` |
| **5** | Remove `caddy-mesh` from `astrolabe` (testing if `Perses` leaks into `caddy-public`) | **BLOCKED** | `ExclusiveMismatch { ptype: "proxy:mesh" }` + `UnhandledPartitionedOffer { ptype: "http:route", key: "perses" }` |
| **6** | Tag `obs-victoria-hub` route with BOTH `zone:public` & `zone:mesh` | **BLOCKED** | `InvariantError { invariant_id: "split-horizon-disjoint-zones", ptype: "http:route" }` |
| **7** | Strip `"monotonic"` from multi-writer `sync-git-annex` `state:persist` | **BLOCKED** | `InvariantError { invariant_id: "calm-monotonicity", ptype: "state:persist" }` |
| **8** | Overcommit `rpi` RAM (`141 MiB` demand > `96 MiB` test supply) | **BLOCKED** | `BudgetExceeded { ptype: "ram", supply: 96, total_demand: 141, critical_demand: 64 }` |
| **9** | Compromised `tuf` compute donor claims NATS `submitter` role | **BLOCKED** | `UnauthorizedPromise { binding_id: "ab-nats-queue", principal_id: "tuf", action: "nats-queue" }` |

---

## 5. Quantitative Pure-Primitive Ergonomics Measurement

Measuring the completed raw zero-sugar `W2` manifests across all `v2/agents/*/agent.toml` files gives hard empirical data for our Stage `3D` ergonomics decision (`TP-2` in [`RES-0024`](../research/RES-0024-stage3d-cca-sunset-cutover-and-ergonomics.md)):
- **Raw `W2` Manifest Volume**: **`44` agent manifests** (`2,112` lines, `219` raw promises, **`48.0` avg lines/agent**, **`9.6` avg lines/promise**; largest: `astrolabe` `167` LOC / `17` promises, `web-stack` `118` LOC / `12` promises, `vaultwarden` `100` LOC / `11` promises, `x240` `94` LOC / `10` promises, `tuf` `93` LOC / `10` promises).
## 6. `W2.1` First-Principles Promise-Theory Refinement Results (All 7 Elegance Gaps Closed!)

Following a brutal conceptual-integrity audit from pure Promise Theory foundations (Burgess & Bergstra *Autonomy* + *Polarity Symmetry*), `v2/` was refined into **`W2.1`** — eliminating every monolith, ghost offer, duplicated posture, and hardcoded flake list while keeping **0 domain strings** across all 8 pure `aky-core/src/*` modules (now including [`spacetime.rs`](../../v2/crates/aky-core/src/spacetime.rs)):

| Metric / Verification Gate | `W2` Baseline | **`W2.1` Pure Promise-Theory Refinement** |
| :--- | :--- | :--- |
| **Total Pure-Primitive Agents** | `44` (`obs-victoria-hub` monolith, no `auth-stack`/`ntfy`/`dev-*`/`actor-*`) | **`63` fine-grained fractal Agents** (`obs-hub` = 6 swappable atomics, `auth-stack` = `lldap`+`authelia`, `notify-ntfy`, orthogonal `fs-impermanence`+`fs-btrfs-btrbk`+`fs-luks-disk`+`fs-simple-disk`, `dev-{rust,nix,docs,formal,default}`, `actor-{gha-ci,aky-agent-bot}`) |
| **Ghost `[[internal_promises]]` on Hosts & Sessions** | `secret:ref`, `cap:grant`, `nats:role`, `host:posture` duplicated on every host/session | **ZERO!** (`cap-admin-session` `47 → 10` LOC raw; `astrolabe` `167 → 141` LOC even after adding `auth-stack`, 6-service `obs-hub`, `ntfy`, `fs-btrfs-btrbk`, `niks3-upload`!) |
| **Hardcoded Targets/DevShells in `v2/flake.nix`** | `nixosTargets`, `standaloneTargets`, `equivTargets`, `devShells` hardcoded | **ZERO!** Auto-discovered from `fleet` & `agents/*`: `6` NixOS hosts (`x86_64` & `aarch64`), `3` `mkShellNoCC` `devShells` (`default`, `formal`, `docs`), standalone `git`, `12` closed Superagents |
| **Real Superagents Verified (`aky check`)** | `11 / 11` in `4.19 ms` | **`14 / 14` in `5.59 ms`** (incl. `obs-hub`, `auth-stack`, `dev-default`, `actor-aky-agent-bot`, `fleet`) |
| **AWS Cedar DRT (`aky drt` vs. Lean 4 `aky-oracle`)** | `511 / 511` (`0` divergences) | **`514 / 514` (`14` real + `500` fuzzed, `0` divergences)** |
| **`S1` Rust == Nix Equivalence (`s1-binding-equiv`)** | `10 / 10` hardcoded targets | **`12 / 12` auto-discovered closed Superagents (`0` diffs)** |
| **Adversarial Attack Suite** | `9 / 9` blocked | **`10 / 10` blocked with exact expected diagnostics** (Attack #6 now fires BOTH `split-horizon-disjoint-zones` AND `OverlappingPartitionHandlers`; Attack #10 blocks `actor-aky-agent-bot` from `cap-github-cli`!) |
| **Multi-Instance Offer Key Namespacing (`QA-02`)** | Collided on shared outbound keys | **Verified (`w1:item` & `w2:item` coexist cleanly in Rust & Nix `S1`!)** |
| **Semantic Spacetime $\gamma(3,4)$ Projection (`aky graph`)** | Lean-only (`Aky/Spec/Spacetime.lean`) | **Live Rust `spacetime.rs` mirror**: `nodes=197, edges=449` (`CONTAINS=91, FOLLOWS=153, EXPRESSES=193, NEAR=12`), `Impact cone (obs-victoriametrics) = [obs-parquet-archiver, obs-perses, obs-victoriametrics, obs-vmalert]` |
| **Raw Pure-Primitive Volume (`W2.1`)** | `2,112` LOC / `219` promises (`9.6` LOC/promise) | **`2,728` LOC / `278` promises (`43.3` avg LOC/agent, `9.8` LOC/promise)** — confirming `ERG-L2` (`schemas/promises.toml`) will compress cleanly ~3.3× while leaving the Lean/Rust Layer-0 core 100% pure! |

---

## 7. `W2.2` Formal Capstone (`F-1`–`F-6` Closed) & 4-Layer `Baugr` → `Verft` → `Ivaldi` → `Skidbladnir` Verification

Closing all **6 formal-methods gaps** exposed by [`RES-0025`](../research/RES-0025-architectural-audit-formal-review-and-scope-stratification.md) and organizing `v2/` cleanly into the ratified **4-repo Unix + `hjem`/`rum` + Promise-Theory architecture** (`baugr/` ← `verft/` ← `ivaldi/` ← `skidbladnir/`, enforced by `lib.fileset.toSource` sandbox fences and barrier-free recursive `agents/**` overlay loading) passed **8 / 8 hermetic Nix flake checks**:

| Check / Gate | Exact Empirical Result (`W2.2`) |
| :--- | :--- |
| **`baugr-lean-audit`** (`F-2`, `F-3`, `F-5`, `F-6`) | **54 / 54 Lean 4 theorems** compiled with `0` warnings and **`0 sorryAx`** across cleanly split `Baugr.Theory.*` (12 pure Promise Theory + SST theorems incl. `imposition_never_cooperates` & `siblingFollowsEdges_non_piercing`) ← `Baugr.Engine.*` (42 theorems incl. **Type Soundness Progress & Preservation `valid_agent_tree_resolves_safely`**, **`resolve_parent_scope_non_piercing`**, and **`checkAgentTree_atomic_sound`**!). Dead `HandlerRule` pruned. |
| **`baugr-{fmt,clippy,test}`** (`L0` isolated) | All 3 crates (`baugr-core`, `baugr-cli`, `baugr-doc`) passed `cargo fmt`, `clippy::pedantic --deny warnings`, and `9 / 9` unit tests (including updated zero-domain-string purity guard forbidding `nixos`, `systemd`, `verft`, `ivaldi`, `skidbladnir`, etc. across all 9 `baugr-core` modules). |
| **`baugr-doc-pipe`** (Unix filter) | `baugr --root ivaldi --root skidbladnir graph --json \| baugr-doc --out $out` generated complete `SUMMARY.md`, `index.md`, and node-capped Mermaid `scopes/*.md` with zero Nix dependency inside `baugr-doc`. |
| **`verft-quint-check`** (`F-1`, `F-4`) | **All 4 hardened protocols exhaustively TLC-verified (`0` violations)**: `capability_session` (`122` states / `35` distinct), `lifecycle_recovery` (`56` states / `21` distinct), `conditional_degradation` (`77` states / `18` distinct), and **`triadic_pull_tlc` Safety + Temporal Liveness (`eventuallyHealthyStabilization`)** (**`97,141` states / `33,326` distinct, `0` violations**). **Non-vacuity mechanically proven**: CI asserts TLC **falsifies** `capability_session_naive` (`userspace_drop` leaking on `SIGKILL`, state 2) AND `lifecycle_recovery_naive` (`vaultwarden_only` DR deadlock on VPS catastrophe, state 2)! |
| **`skidbladnir-fleet-and-drt`** (`F-2`, `F-3`, `F-6`) | **`14 / 14` real superagents** (`46` `ivaldi` + `17` `skidbladnir` = `63` agents across organizational folders) verified in **`6.00 ms`**; **DRT `514 / 514` (`0` divergences)** across `checkAgentTree` + **`resolveAgentTree`** + **`projectAgentSST` + `impactCone` + `reverseImpactCone`** + Cedar (`Rust: 31.26 ms`, `Lean 4 oracle: 1,226.56 ms`). |
| **`verft-s1-equiv`** | **`12 / 12` auto-discovered closed root Superagents** diffed `0` bytes between Rust `baugr resolve` and multi-root pure-Nix `verft/lib/realize.nix`, plus `assertNonPiercingNixos` proof checks. |
| **Adversarial Attack Suite** | **`12 / 12` blocked statically with exact diagnostics** (adding **#11**: atomic `actor-gha-ci` unauthorized `secret:claim` blocked by `atomic-auth: UnauthorizedPromise`, and **#12**: unexported interior `Broadcast` offer inside `auth-stack` blocked simultaneously by `UnhandledBroadcastOffer` + `DroppedMandatoryOffer`!). |
| **4-Layer & Cross-Host Cache Isolation** | Mutating `ivaldi/agents/apps/vaultwarden/interior.nix` produced **`0` `.drv` busts** on `baugr` (L0 Rust), `baugr-oracle` (L0 Lean), `verft-quint-check` (L1 Quint), `git` (`W-Std`), and all 5 other hosts (`x240`, `tuf`, `rpi` `aarch64`, `wsl`, `live-iso`)! |
