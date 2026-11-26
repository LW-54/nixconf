---
id: RES-0024
title: Stage 3D Ground-Up Architectural Synthesis — Jackson Concept Unification, 3-Graph 12×12 DSM, Formal SEI ATAM, Inter-Plane STRIDE/FTA, 10 Real Oversights Closed, Budgets & M1-Sunset Cutover
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: synthesis
tags: [research, stage-3d, architectural-synthesis, jackson-concepts, dsm, atam, stride, fta, fmea, unifications, w2-skeleton, resource-budget, migration, m1-sunset, ergonomics]
assumptions: [A-001, A-002, A-003, A-004, A-005, A-006, A-007, A-008, A-009, A-010, A-011, A-012, A-013]
summary: Thorough ground-up Stage 3D Architectural Synthesis across all 15 accepted ADRs (ADR-0002..ADR-0016) and the actual v2/ formal kernel using four peer-reviewed evaluation frameworks (Daniel Jackson Concept Independence & Unification, Baldwin & Clark 3-graph 12×12 DSM, SEI ATAM Sensitivity/Tradeoff/Risk/Non-Risk analysis, and Shostack STRIDE + FTA/FMEA). Uncovers and closes 10 genuine mathematical, kernel, security, and operational oversights via 7 Deep Unifications (zero domain strings in kernel!), empirically machine-verified by the W2 Full-Platform Pure-Primitive Integration Skeleton (EXP-0015).
---

<!-- abstract:start -->
## Executive Abstract

Conducts a **ground-up, zero-assumption Stage `3D` Architectural Synthesis** across all **15 ratified ADRs ([`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)–[`ADR-0016`](../adrs/ADR-0016-documentation-cli-capability-shells-and-dev-environments.md))** and the live `v2/` Lean 4 / Rust / Quint / Nix kernel, subjecting the integrated platform to **four rigorous peer-reviewed software architecture frameworks** and empirically stress-testing the entire unified platform from scratch on **pure zero-sugar primitives** ([`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)):

1. **10 Genuine Oversights Found & Closed (4 Mathematical/Kernel Bugs + 6 Inter-Plane Operational/Security Hazards)**: Auditing the real `v2/` code exposed fatal integration seams that paper tables missed — including (a) `W1` `Partitioned` overlap crashes whenever `restic`/`btrbk`/`vmalert`/`mdBook` co-subscribed to `state:persist` or `probe`, (b) nested Superagent `resolveTree` stripping `tags` and double-nesting `Broadcast` collections, (c) `aky check` never enforcing Cedar `L3+` policies on principal Superagents during structural verification, (d) `outboundFromExterior` synthetic sinks colliding with scope auth, (e) duplicated `[[principals]]`/`[[resources]]` drift in `policies/default.toml`, (f) coupled `caddy` `zone:public`↔`tailscaled` boot/outage blast radius, (g) Cloudflare R2 14-day Bucket Lock WORM colliding with `restic forget --keep-daily 7 --prune`, (h) impermanent root missing `/persist` declarations for `aky-pull`/`tailscale`/`fluent-bit` & unannounced bootloader rollback loops, (i) `aky with` `SIGKILL` orphaned tmpfs secret leaks, and (j) 3 AM Vaultwarden↔Restic DR secret deadlock!
2. **7 Deep Unifications via Daniel Jackson's *Essence of Software***: Eliminated parallel mechanisms cleanly — **ephemeral capabilities (`ADR-0016`) ARE pure `Agent`s** (retiring separate `capabilities/*.toml`), **doc links ARE `Broadcast` `doc:link` promises** (keeping `AgentManifest` at 7 pure fields), **ONE Cedar `L3+` policy catalog + `AuthBinding` enforces AND compiles all 5 planes**, **symmetric `AttrExpr`-filtered `Broadcast`** unifies all 5 `state:persist` consumers & all 4 `probe` ($\alpha$) consumers with zero overlap, **recursive `fleet` Superagent** unifies cross-host binding across all 6 heterogeneous targets + 5 external stubs, and **split `caddy-public` / `caddy-mesh`** achieves OS-level public/mesh fault & network isolation — all while keeping **ZERO domain strings** in Lean 4 `Aky/Spec/*` or Rust `aky-core/src/*`!
3. **3-Graph 12×12 Baldwin & Clark DSM + Real SEI ATAM + Inter-Plane STRIDE/FTA**: Proves strict lower-triangular acyclicity across Eval/Build, Impermanent Boot, and 3 AM Zero-Infra DR graphs; exposes 4 Sensitivity Points, 4 Tradeoff Points, 4 Residual Risks, and 3 Non-Risks; hardens 8 adversarial & double-fault inter-plane scenarios.
4. **Empirical Fleet Budgets, 6-Wave `M1-Sunset` Cutover & Measured Ergonomics**: Confirms **`−884 MiB` steady (`−1.8+ GiB` peak) RAM saved** on `astrolabe`, **`~89.5 MiB`** on `1 GiB` RPi, **`\$0.26–\$0.68/mo`** R2 cost, and measures real `W2` pure-primitive verbosity empirically (`44` agents, `2,112` lines, `219` raw promises, `9.6` lines/promise) to ground the Layer-1 ergonomics choice (`ERG-L0` vs. `ERG-L1` vs. `ERG-L2`) on hard data.
<!-- abstract:end -->

# RES-0024: Stage 3D Ground-Up Architectural Synthesis

> **Governing Priority Order** ([`CHARTER.md`](../CHARTER.md)): **Operational Reliability (`B`) > Capability Richness (`E`) > Low Maintenance & Dependency Risk (`D`) > Mathematical Elegance (`A`, reconciling the above) > Iteration Speed (`C`)**.
> **Verification Evidence**: Every mathematical upgrade, unification, and negative security property in this report is machine-proved and empirically verified in [`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md).

---

## 1. Ten Real Oversights Discovered by Ground-Up Kernel & Cross-Plane Audit

Inspecting the actual `W1` formal kernel (`v2/formal/lean/Aky/`, `v2/crates/aky-core/`, `v2/lib/realize.nix`, `v2/formal/quint/`) and composing all 15 ADRs simultaneously uncovered **10 genuine defects** that would have caused Phase 4 failures or forced architectural hacks:

| # | Layer / Seam | Real Oversight Discovered | Exact Root Cause | Rigorous Ground-Up Resolution (Verified in `W2` / `EXP-0015`) |
| :---: | :--- | :--- | :--- | :--- |
| **O-1** | **Formal Kernel (`Binding.lean` / `binding.rs`)** | **Multi-Consumer `state:persist` & `probe` Collision Crash** | `W1` modeled `state:persist` as `Partitioned` (`handler_count ≤ 1`). Adding `restic-backup` (`ADR-0014`), `btrbk`, `VictoriaMetrics` (`ADR-0015`), or `mdBook` (`ADR-0016`) alongside `storage-ephemeral` immediately threw `OverlappingPartitionHandlers`! | Upgraded `Cardinality::Broadcast` symmetrically with `AttrExpr` `selector` filtering, unique `(ptype, key)` collision guard, and mandatory offer coverage (`≥ 1` concurrent subscribers, zero overlap conflict!). Proved `broadcast_subscriber_non_interference` in Lean 4 (`0 sorryAx`). |
| **O-2** | **Recursive Resolver (`fleet.rs` / `realize.nix`)** | **Nested Superagent `tags` Stripping & Double-Nesting** | `W1`'s `resolveTree` passed flat `inboundBound` maps into nested Superagents with `tags = []`, breaking `AttrExpr` selectors and double-nesting `Broadcast`/`Partitioned` maps across `fleet` → host → stack! | Replaced flat `inboundBound` forwarding with lossless `inboundStructured` (`key → [ScopeOffer]`) in both Rust `fleet.rs` and Nix `lib/realize.nix`, preserving `(ptype, key, kind, tags, value)` across arbitrary depth (`10/10` targets bit-for-bit `S1`-equivalent!). |
| **O-3** | **Security / Verification (`verify_fleet` / `checkAgentTree`)** | **`aky check` Never Enforced Cedar `L3+` Policies!** | `W1`'s `verify_fleet` verified `Agency`/`Binding`/`Invariants` but never called `authority::authorize()`. Wiring `vaultwarden-master` onto roaming `x240` or `cap-sops-root` into an AI session printed `[PASS]`! Plus `policies/default.toml` duplicated stale `[[principals]]`/`[[resources]]` (including retired `attic-cache-key`). | Added 5-field usage-agnostic `AuthBinding` directly into `Aky.Spec.checkAgentTree` + `aky-core::fleet::verify_fleet` (proved `scope_auth_sound` & `scope_auth_forbid_blocks_promise` in Lean 4!), tag-preserving `-b` forwarding (`hasBackingUse`), and auto-derived SSOT principals/resources directly from `agents/*.toml` (`aky project`). |
| **O-4** | **Kernel Boundary Plumbing (`checkAgentTree`)** | **Synthetic `outboundFromExterior` Sink Triggering False Auth Denials** | Caught *empirically* when first running `W2`: running `isScopeAuthValid` over `scopePs` (which included untagged synthetic `outbound:bcast:*` sinks) falsely denied `astrolabe`'s exported `mesh:service`! | Scoped `isScopeAuthValid` strictly to real interior child promises (`intPs`) in Lean 4 & Rust — mathematically exact and preserves `checkAgentTree_substitution_invariant`. |
| **O-5** | **Concept Redundancy (`ADR-0016` × `ADR-0002`)** | **Parallel `capabilities/*.toml` DAG Resolver & Extra `[doc.links]` Schema** | `ADR-0016` invented a second mini-resolver (`requires`/`conflicts`/`provides`) for `aky with` and an 8th field `[doc.links]` on `AgentManifest`, duplicating Fractal Uniform Agency. | **Unifications 1 & 7**: Ephemeral capabilities ARE ordinary `Agent`s (`requires` = `-b`, `provides` = `+b`, `conflicts` = `Exclusive` `slot:*` + `trust:posture` `Broadcast` selector, AI ban = Cedar `AuthBinding`); doc links ARE `Broadcast` `+doc:link` promises. `AgentManifest` stays strictly 7 pure fields! |
| **O-6** | **Network Fault Isolation (`ADR-0012` Caddy)** | **Coupled `zone:public` ↔ `tailscaled` Startup/Failure Blast Radius** | A single `caddy` process binding `*.ts.net` on `tailscale0` risks failing/stalling public `vault.adje.app` if `tailscaled` is slow/down (`wait-online=false`), and increases config blast radius between public internet and private dashboards. | **Unification 6**: Split into `caddy-public` (`Partitioned` `selector = atom("zone:public")`, ZERO `tailscaled` dep, binds `:443`) and `caddy-mesh` (`Partitioned` `selector = atom("zone:mesh")`, binds strictly `tailscale0` IP, `After=tailscaled.service` + `FreeBind=true`) + `split-horizon-disjoint-zones` `PromiseInvariant`. |
| **O-7** | **Storage / WORM (`ADR-0014` R2 × Restic)** | **R2 14-Day Bucket Lock WORM Breaking Daily `restic forget --prune`** | Cloudflare R2 Bucket Locks block deletion of any locked object; running `restic forget --keep-daily 7 --prune` against a 14-day lock returns `403 AccessDenied` daily. Also sharing one bucket between public CDN cache and backups risks misconfiguration. | Separated buckets (`antikythera-cache` public CDN, unlocked for `niks3` GC; `antikythera-backups` private, 14-day prefix Bucket Lock on `snapshots/` & `data/`) and locked hard assertion `keepDaily (21) > wormLockDays (14)` in `backup-restic/interior.nix`. |
| **O-8** | **Impermanent Root & TUF Pull (`ADR-0010` × `ADR-0013` × `ADR-0015`)** | **Unpersisted Control-Plane State & Infinite Bootloader Rollback Loop** | Losing `/var/lib/aky-pull`, `/var/lib/tailscale`, or `/var/lib/fluent-bit` on impermanent reboot silently destroys TUF `max_seen_epoch`, node identity, or pre-crash WAL chunks; without persisted `failedEpochs`, `systemd-boot` rollback could loop on the broken epoch. | Mandatory `Broadcast` `state:persist` (`survives-reboot`) declared on ALL 11 `astrolabe` state volumes (incl. `sops-nix [early-boot]`, `aky-pull`, `tailscale`, `fluent-bit`, `nats`, `postgresql`); verified `failedEpochs` + `rollbackAlert` + `niks3` write-server independence in `triadic_pull.qnt`. |
| **O-9** | **Ephemeral Security (`ADR-0016` `aky with`)** | **`SIGKILL` Orphaned Tmpfs Secret & `ssh-agent` Leak** | Userspace Rust `Drop` cleanup never executes on `SIGKILL` (`kill -9`) or OOM-kill, leaving decrypted secrets sitting in `/run/user/$UID`. | Execute `aky with` child inside isolated Linux user+mount namespace (`unshare(CLONE_NEWUSER | CLONE_NEWNS)` + private `tmpfs`) + `PR_SET_PDEATHSIG(SIGKILL)` on scoped `ssh-agent`; verified zero host residue on `SIGKILL` exhaustively via TLC in new `capability_session.qnt`! |
| **O-10** | **3 AM Disaster Recovery (`ADR-0011` × `ADR-0014`)** | **Vaultwarden ↔ Restic Recovery Secret Circularity & DuckDB Archive OOM/PII** | If `astrolabe` (hosting Vaultwarden) dies at 3 AM, you cannot open Vaultwarden to retrieve the Restic password needed to restore Vaultwarden! Also unconstrained monthly DuckDB Parquet exports risk OOM or freezing leaked error-line tokens. | Encrypt `secrets/recovery.sops.yaml` (Restic password, `hbox` SFTP key, R2 recovery creds) to the offline cold break-glass `age` key directly inside every laptop's Git clone + Codeberg mirror (`0` Vaultwarden/GitHub dependency!). Cap DuckDB archival at `MemoryMax=768M` / `memory_limit='512MB'` with deterministic pre-redaction regex filter. |

---

## 2. First-Principles Promise Theory Derivation & Daniel Jackson Concept Unification (`W2.1`)

Applying **Burgess & Bergstra's Promise Theory Axioms** (*Autonomy*: an agent promises strictly about its own behavior, never emitting ghost offers on behalf of children; *Polarity Symmetry*: declaring owners emit `+b` claims/state/probes while independent caretakers/assessors/realizers subscribe via `-b`) together with **Daniel Jackson's *The Essence of Software*** (Concept Independence, non-redundancy) and **Ousterhout Deep Modules**, we unified all 15 ADRs explicitly onto our minimal formal building blocks (`Agent`, `Promise`, `B3 Cardinality`, `AttrExpr`, `Cedar L3+`, `AuthBinding`, `PromiseInvariant`, `SST γ(3,4)`):

### 2.1 The 9 Pure Promise-Theory Interaction Archetypes (Domain-Free!)
1. **Finite Physical Endowment** (`ram`, `squota`) → Locality `+b` / Workload `-b` (`Budgeted` + priority-0 survival).
2. **Substrate Capability** (`secrets:runtime`, `mesh:transport`, `storage:durable`, `auth:oidc`, `notify:sink`, `backup:provider`) → Provider `+b` / Consumer `-b` (`Exclusive` or `Broadcast`).
3. **Owned Durable State (`S2+`)** (`state:persist`) → State owner `+b` (`Broadcast` + open traits) / ALL independent caretakers (`fs-impermanence`, `fs-btrfs-btrbk`, `backup-restic`, `obs-perses`, `docs-mdbook`) observe via orthogonal `AttrExpr` `-b` selectors.
4. **Self-Assessment Probes ($\alpha$, `C7`)** (`probe`) → Service owner `+b` (`Broadcast`) / ALL independent assessors (`gitops-aky-pull` `critical`, `obs-fluent-node`, `obs-vmalert`, `obs-perses`, QEMU `vm-*`) observe concurrently.
5. **Security & Role Claims (`L3+`)** (`secret:claim`, `cap:claim`, `nats:claim`, `obs:scope`) → Claiming agent declares `+b` (`Broadcast`) / ONE realizer (`trust-sops`, `cap-runtime`) materializes it AND **Cedar `AuthBinding`** audits it against the enclosing Principal Superagent's `attributes` — **zero ghost `[[internal_promises]]` on hosts or capability sessions** (`cap-admin-session` dropped from `47` → `10` lines raw!).
6. **Disjoint Exclusive Ownership** (`http:route`, `slot:ssh-agent`) → Endpoint `+b` (`Partitioned` or `Exclusive`) / Disjoint owner `-b` (`caddy-public` `zone:public` vs. `caddy-mesh` `zone:mesh` — overlap triggers BOTH `split-horizon-disjoint-zones` AND `OverlappingPartitionHandlers`!).
7. **Conditional Opportunistic Offering ($+b \mid C$)** (`compute:batch`) → Donor `+b` (`Soft` + complete `SoftContract`) / Never blocks Hard survival paths.
8. **Host & Session Admission (`admit-agent`)** (`agent:class`) → Restricted agent declares `+b` (`class:workstation-cache`, `class:compute-worker`) / Enclosing Principal's single `attributes` SSOT audited by Cedar `AuthBinding` (**eliminating duplicated `host:posture` completely!**).
9. **Epistemic Links (`γ(3,4)` `NEAR` / `EXPRESSES`)** (`doc:link`, `attributes`) → Projected purely by [`spacetime.rs`](../../v2/crates/aky-core/src/spacetime.rs) (`aky graph --impact <node>`) with zero operational dependency pollution.

### 2.2 The 7 Deep Unifications & Fractal Refinements Verified in `W2.1`
1. **Unification 1 — Ephemeral Capabilities & Stratified DevShells ARE Pure `Agent`s (`ADR-0016` Amendment)**: Retires `capabilities/*.toml` AND hand-written `flake.nix` `devShells`. `cap-{runtime,sops-root,github-cli,r2-admin,breakglass,obs-mcp}` and `dev-{rust,nix,docs,formal,default}` are ordinary `Agent`s (`pkgs.mkShellNoCC` auto-discovered from `dev:shell`).
2. **Unification 2 — Single Cedar `L3+` Truth Enforces & Projects ALL 6 Planes**: One [`policies/default.toml`](../../v2/policies/default.toml) + `[[auth_bindings]]` enforces structurally during `aky check` AND projects via `aky project`: (1) `.sops.yaml` (`read-secret`), (2) Tailscale `policy.hujson` (`mesh-connect`), (3) NATS RBAC (`nats-queue`), (4) Biscuit read-only MCP (`obs-query`), (5) `aky with` guards + `mode:online`/`mode:offline` exclusion (`assume-capability`), and (6) host-class placement (`admit-agent`).
3. **Unification 3 — Orthogonal Substrates + Decomposed Domain Superagents (`obs-hub` & `auth-stack`)**: Strictly separates `target-nixos-{efi,rpi,wsl,iso}` (arch/boot/OS) from `fs-{impermanence,btrfs-btrbk,luks-disk,simple-disk}`; decomposes `obs-hub` into 6 swappable atomic Agents (`victoriametrics`, `victorialogs`, `victoriatraces`, `vmalert`, `perses`, `parquet-archiver`) hiding internal loopback APIs behind `Σ`; decomposes `auth-stack` (`auth-lldap` + `auth-authelia`) hiding internal LDAP `3890` behind `Σ`; adds `notify-ntfy` + first-class `actor-gha-ci` & `actor-aky-agent-bot` inside `fleet`.
4. **Unification 4 — Multi-Consumer `Broadcast` `state:persist` & `probe` ($\alpha$)**: Symmetric `AttrExpr`-filtered `Broadcast` cleanly feeds all 5 state consumers and all 4 probe consumers concurrently without overlap.
5. **Unification 5 — Recursive `fleet` Superagent + Zero-Hardcoding `flake.nix` Auto-Discovery**: [`v2/lib/realize.nix`](../../v2/lib/realize.nix) auto-discovers ALL 6 NixOS hosts (`nixosConfigurations`), ALL standalone `W-Std` packages, ALL `pkgs.mkShellNoCC` `devShells`, and ALL 12 closed root Superagents for `S1` equivalence directly from `agents/*/agent.toml` — adding a new host requires **0 edits to `flake.nix`**.
6. **Unification 6 — Split `caddy-public` (`zone:public`) vs. `caddy-mesh` (`zone:mesh`)**: Symmetric host-level ingress routers giving hard OS-level process/socket isolation.
7. **Unification 7 — Multi-Instance Offer Key Namespacing (`QA-02`) + Pure `spacetime.rs` $\gamma(3,4)$ Spine**: `ChildRef.instance` automatically namespaces outbound offer keys (`"{instance}:{key}"`) for zero-collision multi-instance composition, and [`spacetime.rs`](../../v2/crates/aky-core/src/spacetime.rs) mirrors [`Aky/Spec/Spacetime.lean`](../../v2/formal/lean/Aky/Spec/Spacetime.lean) 1:1 (`aky graph --impact`).

> **Why Transparent Profiles (`P-Dual`, `profiles/*.toml`) Stay**: Checked explicitly under Jackson's necessity test — `base-server` (10 agents) and `base-workstation` (9 agents) factor shared host substrates without forcing 15+ pass-through boundary declarations per host, and are proved operadically associative in Lean 4 (`flattenScope_append`, `profile_nesting_invariant`).

---

## 3. Baldwin & Clark 12×12 Design Structure Matrices (3 Orthogonal Graphs)

Architecture modules:
`M1` Pure Kernel (`Aky/Spec`+`aky-core`+`policies`) | `M2` Nix Realizer (`lib/realize.nix`+Substrates) | `M3` Trust (`sops-nix`+Break-Glass) | `M4a` `caddy-public` | `M4b` `tailscaled`+`caddy-mesh` | `M5a` R2 Public CDN (`cache.adje.app`) | `M5b` `P-AkyPull`+`niks3` Write/GC | `M6` Storage (`impermanence`+`btrbk`+`restic`) | `M7` Sync & Compute (`git-annex`+`NATS`+`tuf`) | `M8` Core Services (`Vaultwarden` etc.) | `M9` Obs (`COL-FluentNode`+`VictoriaStack`+`Perses`+`DuckDB`) | `M10` Capabilities & Docs (`aky with`+`mdBook`).

### 3.1 Graph A — Eval / Build-Time DSM (Strictly Lower-Triangular → 0 Cycles, 0 Cross-Host Cache Busts!)
- **Topological Order**: `M1` → `M2` → `{M3, M4a, M4b, M5a, M5b, M6, M7, M8, M9}` (parallel independent leaves communicating ONLY via `Π_ext` TOML) → `M10` (`mdBook` reads `M1` out-of-Git, ZERO reverse edge into NixOS host closures!).
- **Key Acyclicity Proof**: Editing `M10` prose docs (`0` host `.drv` changes) or editing `M8` `vaultwarden/interior.nix` (`0` changes to `x240`/`tuf`/`rpi`/`wsl`/`live-iso`/`git`, verified empirically in `EXP-0015`).

### 3.2 Graph B — Runtime / Impermanent Boot-Time DSM on `astrolabe` (Strictly Lower-Triangular → 0 Deadlocks!)
1. **Stratum 0 (`initrd`)**: `M6a` (`/persist` Btrfs `neededForBoot=true` + `squota`).
2. **Stratum 1 (Early Activation)**: `M6b` (`impermanence` bind-mounts all 11 `/persist` dirs incl. `sops-nix`, `aky-pull`, `tailscale`, `fluent-bit`) → `M3` (`sops-install-secrets` decrypts using `/persist/var/lib/sops-nix/key.txt`).
3. **Stratum 2 (Decoupled Network & Emergency Access)**: `sshd` (baked break-glass key, ZERO dep on `tailscaled`!) + `M4a` (`caddy-public` `:443`, ZERO dep on `tailscaled`!) + `M4b-1` (`tailscaled`, `wait-online=false`).
4. **Stratum 3 (`multi-user.target`)**: `M4b-2` (`caddy-mesh` `After=tailscaled.service` + `FreeBind=true`) + `M8` (Core Services) + `M7` (`nats`) + `M9b` (`VictoriaStack` + `Perses`) + `M5b-2` (`niks3` write server + Postgres).
5. **Stratum 4 (Async Timers & Buffered Edge)**: `M9a` (`fluent-bit` disk-WAL buffered — survives hub outage), `M5b-1` (`aky-pull.timer` — pulls directly from `M5a` Cloudflare R2 CDN, **ZERO dependency on local `niks3` write server!**), `M6c` (`restic`/`btrbk`), `M9c` (`DuckDB` monthly Parquet).

### 3.3 Graph C — 3 AM Genesis / Zero-Infra Disaster-Recovery DSM (Simultaneous `astrolabe` + GitHub Loss!)
1. **Stratum 0 (Offline Physical Custody)**: Cold break-glass USB/paper (`age` root key + SSH break-glass key — **ZERO Vaultwarden dependency**).
2. **Stratum 1 (Offline Repo + Decrypted Recovery Creds)**: Local workstation Git clone (`x240`/`tuf`) or Codeberg mirror → offline `age` key decrypts `secrets/recovery.sops.yaml` (Restic repo password + `hbox` SFTP key + R2 recovery creds).
3. **Stratum 2 (Bare-Metal Provisioning)**: Untrusted `live-iso` (zero prod secrets) formats Btrfs + `/persist`, generates fresh host key, human verifies custody, laptop pushes closure via `aky deploy --push` (using `M5a` R2 CDN if up or local store if R2 is also down!).
4. **Stratum 3 (Data Resurrection)**: `restic restore` from R2 `antikythera-backups` OR `hbox` SFTP restores `/persist/var/lib/*` → `astrolabe` boots into full healthy operation (`lifecycle_recovery.qnt` TLC-verified!).

---

## 4. Formal SEI ATAM Evaluation (Sensitivity Points, Tradeoff Points, Risks & Non-Risks)

Weighted by Charter Priority **`B > E > D > A > C`**:

### 4.1 Sensitivity Points (`SP-*`)
- **`SP-1` (`S1` Dual-Evaluator Fidelity — `aky-core` vs. `lib/realize.nix`)**: Any semantic drift between Rust `fleet.rs` and Nix `lib/realize.nix` undermines static verification (`QA-04`). *Control*: Hard CI gate `s1-binding-equiv` diffs `aky resolve` vs. `realized.resolvedBindings` bit-for-bit across all 10 targets!
- **`SP-2` (`Broadcast` `AttrExpr` Selector Scope on `backup-restic`)**: Over-broad tags on large TSDB/annex stores would push R2 storage past `< \$2/mo` (`QA-07`). *Control*: Explicit opt-in tag `backup-required` (verified in `EXP-0015`: `astrolabe` Restic backs up strictly the 5 critical paths, excluding `victoriametrics` & `git-annex`, which archive separately via DuckDB Parquet & `hbox`!).
- **`SP-3` (`astrolabe` `/persist` Completeness)**: Omitting any control-plane state dir (`aky-pull`, `tailscale`, `fluent-bit`, `sops-nix`) loses state on impermanent reboot (`QA-06`). *Control*: Mandatory `Broadcast` `state:persist` + Phase 4 Wave 1 QEMU impermanent reboot test!
- **`SP-4` (`R2` Bucket Lock vs. `restic forget` Window)**: `keepDaily ≤ wormLockDays` breaks daily pruning (`QA-07`). *Control*: Build-time `assert keepDaily > wormLockDays` (`21 > 14`) inside `backup-restic/interior.nix`.

### 4.2 Tradeoff Points (`TP-*`)
- **`TP-1` (Split `caddy-public` + `caddy-mesh` vs. Single Caddy)**: Trades `+~30 MiB` steady RAM on an 11 GiB VPS (`QA-07` negligible) for **hard OS-level process & socket isolation** decoupling public HTTPS uptime from `tailscaled` (`B` Reliability & `QA-04` major win!).
- **`TP-2` (Raw Zero-Sugar `ERG-L0` vs. Layer-1 Data-Driven Desugaring `ERG-L2`)**: Pure primitives (`ERG-L0`) maximize WYSIWYG mathematical transparency (`QA-01`, `QA-04`) at `9.6` lines/promise (`2,112` lines across `44` `W2` agents — `astrolabe` `167` lines, `vaultwarden` `100` lines). Layer-1 `ERG-L2` (`schemas/promises.toml`) cuts authoring boilerplate `~3×` with zero domain strings in Rust/Lean, trading `+~120 LOC` of total deterministic desugarer verified by `S1` Rust==Nix equality (`TP-2` decision fork presented to user below).
- **`TP-3` (`Fluent Bit` `storage.sync full` vs. SD-Card Wear on RPi)**: `fsync` per chunk delivers `100%` `SIGKILL` survival on NVMe (`astrolabe`/`x240`, `EXP-0012`), whereas on SD-card RPi we trade down to `storage.sync normal` + `5s` flush to protect SD endurance (`QA-07`).
- **`TP-4` (`P-AkyPull` 5-min Pull Cadence vs. Instant Push)**: Autonomous pull eliminates inbound CI SSH root (`B` Reliability, `QA-04`) at up to 5 min latency (`C`), mitigated by retaining serialized `L3+` human `aky deploy --push` (`triadic_pull.qnt`).

### 4.3 Residual Risks (`R-*`) & Non-Risks (`NR-*`)
- **Risks**:
  - **`R-1` (`niks3` Upstream Velocity)**: Mitigated because R2 read path (`cache.adje.app`) is standard static Nix binary cache (`.narinfo` + `.nar`) — zero lock-in!
  - **`R-2` (`Perses 0.54` LogsQL Native Plugin Depth)**: Mitigated because `VictoriaLogs` bundles its own `0 MiB`-extra built-in LogsQL Web UI (`logs.astrolabe.<tailnet>.ts.net`), linked seamlessly from Perses!
  - **`R-3` (`A-006` Offline Boot & `A-008` Real Boot-Counting QEMU Verification)**: Formally model-checked in Quint/TLC; awaiting real KVM kernel verification in Phase 4 Wave 1 (`ASSUMPTIONS.md`: `experimenting`).
  - **`R-4` (SQLite/PostgreSQL Live Backup Quiescing)**: Mitigated by mandatory `prepare_cmd` (`sqlite3-backup`, `pg_dump`) inside `state:persist` payloads executed prior to `restic backup`.
- **Non-Risks**: **`NR-1`** Fleet RAM (`~1,004 MiB / 11,264 MiB` on `astrolabe`, `~89.5 MiB / 1,024 MiB` on RPi — `> 10 GiB` VPS headroom), **`NR-2`** R2 monthly bill (`\$0.26–\$0.68/mo`, `80 GB` alert / `120 GB` hard GC cap), **`NR-3`** Verifier latency/correctness (`4.19 ms` full `W2` check, `511/511` DRT `0` divergences, `47/47` Lean 4 theorems `0 sorryAx`).

---

## 5. Unified Shostack STRIDE + Fault Tree Analysis (8 Inter-Plane Scenarios)

| # | Inter-Plane Threat / Double-Fault Scenario | STRIDE / FTA | Defense-in-Depth Walls (Mechanically Enforced) | Verified In |
| :---: | :--- | :---: | :--- | :--- |
| **1** | Compromised `aky-agent[bot]` attempts secret read, `aky with`, or direct push to `main`/`calibrated`. | **E / I** | GitHub Ruleset (PR-only) + Cedar `forbid` on `read-secret` & `assume-capability` (`aky check`!) + read-only Biscuit MCP + `gitleaks`/`dix`. | `EXP-0015` Attack #2, `Aky.Thm` |
| **2** | Stolen roaming laptop (`x240`/`tuf`) asleep or awake. | **I / S / T** | LUKS2+TPM2-PIN+Lanzaboote + lid-close lock + zero prod vault/cache-write secrets (`forbid-roaming-ephemeral-or-ai-prod-vault`) + `aky blast-radius` rotation list. | `EXP-0015` Attack #1, `lifecycle_recovery.qnt` |
| **3** | Compromised `tuf` compute donor returns poisoned build or attempts NATS submission. | **T / E** | Cedar `forbid-compute-worker-from-submitting-or-hub` + `astrolabe` `forbid`s workstation `harmonia` (`cache-harmonia-dev` selector `workstation \ prod`) + prod trusts ONLY CI `niks3` signing key. | `EXP-0015` Attacks #4 & #9 |
| **4** | Compromised mirror or supply-chain downgrade/freeze. | **T / R / D** | TUF signed Snapshot Manifest + persisted `/persist/var/lib/aky-pull` `max_seen_epoch` + `E3` staleness freeze alert + Codeberg mirror. | `triadic_pull.qnt` |
| **5** | Bad `nixpkgs` breaks `tailscaled` or `caddy` on `astrolabe`. | **D** | Local $\alpha$ critical probes (`caddy-public`, `tailscale-alive`, `vaultwarden-alive`) auto-rollback + `systemd-boot.bootCounting` + `failedEpochs` loop suppression + decoupled `caddy-public` & public `sshd`. | `triadic_pull.qnt`, Unification 6 |
| **6** | Simultaneous `astrolabe` NVMe loss + GitHub outage at 3 AM. | **D** *(Double Fault)* | Offline cold `age` key decrypts `secrets/recovery.sops.yaml` from local laptop clone / Codeberg → `restic restore` from R2/`hbox` → `aky deploy --push` + R2 CDN (`0` GitHub/Vaultwarden dep). | `lifecycle_recovery.qnt`, DSM Graph C |
| **7** | Compromised `astrolabe` root / ransomware tries to wipe backups. | **T / D** | Private `antikythera-backups` R2 14-day Bucket Lock WORM (`keepDaily 21 > 14`) + independent `hbox` SFTP + home-laptop pull backups (`3-2-1-1-0`). | `ADR-0014`, `backup-restic` assert |
| **8** | Log/TSDB disk storm, DuckDB OOM/PII leak, or `aky with` `SIGKILL`. | **D / I** | Linux 6.18 Btrfs `squota` (`20 GiB` obs, `10 GiB` annex, `2 GiB` reserve) + DuckDB `MemoryMax=768M` & regex pre-redaction + `CLONE_NEWNS` kernel tmpfs auto-wipe & `PR_SET_PDEATHSIG`. | `capability_session.qnt` (TLC), `EXP-0012` |

---

## 6. Empirically Verified Fleet Resource, Disk & Cost Budget

Measured live via `systemctl show` on `astrolabe` (`2026-11-25`, Linux `6.18.60`, `6 vCPU / 11,264 MiB RAM / 100 GiB NVMe`, `52 GiB` used / `48 GiB` free) and `EXP-0010`–`EXP-0012`:

| Subsystem / Unit | v1 Live Steady (`MiB`) | v2 Target Steady (`MiB`) | Delta (`MiB`) | Notes |
| :--- | ---: | ---: | ---: | :--- |
| **Core Public & Auth Services** (`caddy-public 97.9`, `vaultwarden 71.6`, `ntfy 69.9`, `authelia 36.0`, `copyparty 11.5`, `sshd 11.5`, `lldap 7.9`, `ttyd 5.7`) | `312.0` | `312.0` | `0.0` | `caddy-public` decoupled from `tailscaled` (`Unification 6`) |
| **Private Mesh Proxy (`caddy-mesh`)** | `0.0` | **`~32.0`** | **`+32.0`** | Hard process/socket isolation strictly on `tailscale0` (`TP-1`) |
| **Binary Cache & GitOps** | `151.1` *(atticd `77.7` + cachix `73.4`)* | **`~65.0`** *(`niks3` write/GC + Postgres; `aky-pull` `0` idle)* | **`−86.1`** | Peak drops `−800+ MiB`; reads bypass via R2 CDN (`\$0` egress) |
| **Mesh & Distributed Compute** | `0.0` | **`~65.8`** *(`tailscaled ~45` + `nats 20.8`; `git-annex 0` idle)* | **`+65.8`** | WireGuard mesh + JetStream batch compute (`ADR-0012`, `ADR-0014`) |
| **Observability Edge Collector** | `558.0` *(alloy; peak `810.7`!)* | **`44.5`** *(`fluent-bit 21.0` + `node_exporter 23.5`)* | **`−513.5`** | **`12.6×` lighter**, `100%` `SIGKILL`-safe + native cgroups v2 PSI |
| **Observability DBs + Alerts** | `427.3` *(`VM 232.7` + `VL 96.8` + `alerts 97.8`)* | **`~395–445`** *(pruned `VM` + `VL` + **`VT 17.5`** + `alerts 97.8`)* | **`~−10`** | Adds 3rd signal (`VictoriaTraces`) while pruning `65%` unused series |
| **Observability UI + Docs** | `458.1` *(grafana; peak `542.2`)* | **`89.9`** *(`perses 0.54`; static `mdBook` `0` RAM)* | **`−368.2`** | **`5.1×` lighter**, 64 built-in plugins + `0 MiB` static Tailnet docs |
| **TOTAL `astrolabe` Platform + Core** | **`1,906.5 MiB`** *(peak `> 3.8 GiB`)* | **`~1,004–1,054 MiB`** | **`−852 to −902 MiB`!** | **`~9.1%` of `11,264 MiB` VPS RAM → `> 10.2 GiB` free headroom!!** |

- **1 GiB Raspberry Pi (`aarch64`)**: `tailscaled` (`~45`) + `COL-FluentNode` (`44.5`) + `aky-pull` (`0` idle) = **`~89.5 MiB`** (**`8.7%`** of `1,024 MiB` RAM; `109 MiB` statically budgeted in `W2` `rpi/agent.toml`!).
- **Cloudflare R2 Monthly Cost**: `antikythera-cache` (`25–50 GB`) + `antikythera-backups` WORM (`2–5 GB`) + Parquet compact mirror (`< 0.2 GB`) = **`27–55 GB`** → **`\$0.26–\$0.68 / month`** (`< \$2/mo` budget, `\$0` egress, `80 GB` alert, `120 GB` hard GC cap).

---

## 7. Concrete 6-Wave `M1-Sunset` Zero-Carry-Forward Cutover Plan

| Wave | Scope & Target | Concrete Steps | Rollback / Safety Gate |
| :---: | :--- | :--- | :--- |
| **0** | **External Plane Prep** *(Zero prod impact)* | Create `LW-54/antikythera` + Codeberg mirror; provision separate R2 buckets (`antikythera-cache` public CDN + `antikythera-backups` private w/ 14d Bucket Lock on `snapshots/` & `data/`); register `aky-agent[bot]` & `aky-ops[bot]` GitHub Apps + Rulesets; generate offline cold break-glass `age` + SSH keys & encrypt `secrets/recovery.sops.yaml`; commit `policy.hujson`. | Zero production hosts touched. |
| **1** | **Phase 4 Build & KVM QEMU Gates** | Build full `v2/` Rust workspace (`aky-core`, `aky-cli`, `aky-prof`), Cedar 5-plane `aky project` compilers, `P-AkyPull`, `aky with` (`CLONE_NEWNS`), `aky doc` + `mdBook`, and all real host/service agents. Run hermetic CI + **QEMU VM tests** (`vm-x240`, `vm-astrolabe`) verifying impermanent reboot persistence, Vaultwarden, split `caddy-public`/`caddy-mesh`, `niks3`, `NATS`, `VictoriaStack`+`Perses`, `COL-FluentNode` `SIGKILL`, **`A-006` offline boot**, and **`A-008` `P-AkyPull` boot-counting rollback**! | 100% green CI + KVM QEMU required before real hardware. |
| **2** | **`x240` Canary Cutover** *(48–72h soak)* | Fresh `restic` backup; activate v2 via `aky switch` (retaining v1 generation in `systemd-boot`); verify LUKS2+TPM2-PIN+Lanzaboote, Tailscale `zone:mesh`, `COL-FluentNode`, `git-annex`, `aky with`, `nix-direnv`, lid-closed AC mode, and 1 full `P-AkyPull` cycle. | Instant 1-reboot `systemd-boot` rollback to v1. |
| **3** | **`astrolabe` Pre-Flight Backup & Restore Drill** | Fresh verified Restic backups of Vaultwarden, Authelia, LLDAP, Copyparty, ntfy, Caddy ACME, and VictoriaMetrics/Logs to **both `hbox` and R2**; execute live restore drill into local VM using ONLY the cold break-glass `age` key + `secrets/recovery.sops.yaml`; confirm 1:1 `/persist/var/lib/*` path mapping (zero data loss of Vaultwarden or existing 917M VM rows!). | Cutover blocked until cold restore drill succeeds. |
| **4** | **`astrolabe` Atomic Live Cutover** | Push `astrolabe` v2 closure to R2 `antikythera-cache`; run `aky switch --test` → $\alpha$ critical probes (`caddy-public`, `tailscale-alive`, `vaultwarden-alive`) → `boot` with `systemd-boot.bootCounting`; verify existing `VictoriaMetrics` history in `Perses` over `*.ts.net`, verify `docs.<tailnet>.ts.net`, verify `P-AkyPull` timer + first WORM backup. | Auto-rollback on failed $\alpha$ probe; 1-reboot bootloader fallback to v1. |
| **5** | **7-Day Soak & `M1-Sunset` 100% Legacy Deletion** | After 7 clean days (green Weekly Digest, green `P-AkyPull`, verified R2 restore): permanently delete 100% of v1 legacy (`primitives/`, `modules/`, `meta/`, `.tack/`, 168 committed `docs/`, Attic, Cachix, B2, Alloy, Grafana, static deploy key, `flake-parts`), promote `v2/` to root of `LW-54/antikythera` `main`, archive `v1-final` signed Git tag. | Signed `v1-final` Git tag + R2/`hbox` backups archived. |

---

## 8. Empirically Grounded Ergonomics & Factorization Decision (`ERG-L0` vs. `ERG-L1` vs. `ERG-L2`)

Having built and verified the **entire 15-ADR `W2` platform on 100% raw zero-sugar primitives first** ([`EXP-0015`](../experiments/EXP-0015-w2-full-platform-pure-primitive-integration-skeleton.md)), we now have **exact empirical friction measurements** rather than guesses:
- **Raw `W2` Scale**: **`44` agent files** (incl. 6 hosts, `fleet`, `web-stack`, 8 capability agents/sessions, 5 external stubs, 10+ service/substrate agents) = **`2,112` lines** / **`219` raw promises** → **`48.0` avg lines/agent**, **`9.6` avg lines/promise** (`astrolabe` `167` lines, `web-stack` `118` lines, `vaultwarden` `100` lines, `x240` `94` lines, `tuf` `93` lines).
- **Root Cause of Boilerplate**: 80%+ of those `9.6` lines/promise are mechanical repetition of `(key = ptype, mandatory = true, polarity, cardinality)` — ZERO conceptual complexity, purely syntactic verbosity!

| Option | Mechanism | `vaultwarden` (`100` LOC raw) | Domain Strings in Rust/Lean? | Trade-Off (`TP-2`) |
| :--- | :--- | ---: | :---: | :--- |
| **`ERG-L0`** — **Raw Zero-Sugar Forever** | Keep `W2`'s exact raw `[[promises]]` everywhere; factor only via `P-Dual` `profiles/*.toml`. | `100` LOC | **ZERO** | Maximum WYSIWYG purity, zero desugarer code, but `~2,100+` LOC of mechanical repetition for ~40 agents. |
| **`ERG-L1`** — **Pure Structural Shorthand** | Default `key = ptype`, `mandatory = true`, `cardinality = "exclusive"` + `use = [...]` list (no registry). | `~48` LOC (`2.1×` shorter) | **ZERO** | Tiny desugarer (`~40 LOC`), no schema registry, cannot default `state:persist`/`probe` → `broadcast` or catch `ptype` typos statically. |
| **`ERG-L2`** *(Recommended)* — **Data-Driven `schemas/promises.toml` Layer-1 Total Desugaring** | Pure user-space data registry (`schemas/promises.toml`) declaring per-`ptype` defaults (`cardinality`, `polarity`, `key_from_payload`, docs) + clean `[use.*]`/`[offer.*]` TOML shorthand desugaring **100% totally into Layer-0 pure IR** verified by `S1` Rust==Nix equality & inspectable via `aky resolve --desugar`! | **`~30` LOC (`3.3×` shorter!)** | **ZERO!** | Cuts fleet manifest LOC `~3×`, catches `ptype` typos in `2 ms`, auto-generates Promise Catalog in `mdBook`, leaves Lean 4 & `aky-core` 100% untouched! |
