---
id: ADR-0014
title: Adopt Stage 3C.1 Storage, Backups (Restic R2/Hbox/Gdrive + Btrfs Squotas), Pooled Intermittent Storage (git-annex + Harmonia) & Opportunistic Batch Compute (DC-NATS-Pull)
type: adr
status: accepted
created: 2026-11-25
updated: 2026-11-25
domain: distributed-storage-compute
tags: [adr, stage-3c1, storage, backup, restic, btrbk, squota, cloudflare-r2, hetzner-box, gdrive, git-annex, harmonia, syncthing, copyparty, nats, jetstream, nix-builders, lid-closed, a-009]
rfd: null
assumptions: [A-009]
supersedes: null
superseded_by: null
summary: Ratifies Stage 3C.1 (A-009) incorporating all 6 adversarial compliance-review refinements: ST-UnifiedRestic (native S3 R2 <$2/mo w/ prefix-scoped Governance WORM, native tuned SFTP hbox, optional gdrive, home-laptop restic-rest-server, btrbk + Btrfs squota isolated in btrfs-storage substrate), SP-GitAnnex + workstation Harmonia peer cache + Copyparty + optional Syncthing, and sandboxed DC-NATS-Pull (services.nats JetStream + allowlisted/signed Nix task closures + worker/submitter RBAC) + nix.buildMachines + universal AC lid-closed mode w/ session lock, battery hysteresis, thermal watchdog, and metered-link byte quotas.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3C.1`** (`A-009`: Storage, Backups, Local Disk Quotas, Opportunistic Pooled Fleet Storage, and Distributed Batch Compute) on top of [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md) (`S2+`), [`ADR-0006`](ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md) (Budgeted Capacity & Dynamic Physical Conditions), [`ADR-0010`](ADR-0010-open-orthogonal-substrate-composition-impermanence-and-hjem.md) (Orthogonal Substrates), [`ADR-0012`](ADR-0012-mesh-fabric-tailscale-dual-ssh-and-split-horizon-tls.md) (Tailscale Mesh), and [`ADR-0013`](ADR-0013-gitops-tuf-pull-niks3-r2-governance-and-resilience.md) (`BC-Niks3` on Cloudflare R2), validated empirically by [`EXP-0010`](../experiments/EXP-0010-intermittent-storage-and-nats-compute-torture-test.md) and hardened by a 6-point adversarial compliance review:
1. **Backups, Quotas & R2 Cost Envelope (`ST-UnifiedRestic`)**: Sealed `services.restic` (`0.19.1`, 100% compatible with `rustic 0.11.4` drop-in) speaking **native S3** to Cloudflare R2 (prefix-scoped Governance WORM on `/data/` & `/snapshots/` leaving `/locks/` unlocked; crash-consistent DB `prepareCommand`s; **`< \$2/mo` cost-value envelope** with `niks3` GC targeting ~25–50 GB [`\$0.22–\$0.60/mo`], warn alert at `80 GB`, aggressive GC cap at `120 GB`), **native tuned SFTP** (`sftp.connections=3`, `--pack-size 16`) to **Hetzner Storage Box (`hbox`)**, optional **`gdrive`** via `rclone` (zero `${self}` leaks), and optional append-only **`restic-rest-server`** on plugged-in home laptops/`rpi`. Native `services.btrbk` (`0.32.7`) + Linux 6.18 **Btrfs Simple Quotas (`squota`)** replace ~970 LOC of custom v1 loopback/snapshot plumbing and live strictly inside the `btrfs-storage` Substrate Agent.
2. **Pooled Intermittent Storage & Warm Cache (`SP-GitAnnex + Harmonia`)**: **`git-annex` (`10.20260421`, `0 MiB` idle RAM)** unifies spare storage across VPS (`10 GB`), `hbox` (`100+ GB` native SFTP), client-side-encrypted `gdrive` (`TB`), and dynamically resizable laptops (`100 GB–1 TB+`) for large immutable/archive/media libraries with zero quorum stalls (`Garage v2` falsified for sleeping laptops by `EXP-0010`: `PUT 0/10` on 1 sleeping node even in `degraded` mode!). Paired with optional `Syncthing` (small live working notes), `Copyparty` (web/WebDAV file hub), and **workstation-scoped `harmonia 3.3.0`** peer `/nix/store` caching (never trusted by production `astrolabe`!).
3. **Opportunistic Distributed Batch Compute (`DC-NATS-Pull` + `nix.buildMachines` + Universal AC Lid-Closed Mode)**: **`services.nats` (`2.15.2` JetStream, `16–21 MiB` RSS)** on `astrolabe` + low-priority sandboxed **`aky worker`** pull daemons (`43.8 ms` `-NAK` unplug handoff, `+WPI` long-job heartbeats, allowlisted/signed Nix flake closures only — zero arbitrary shell RCE, strict `submitter` vs `worker` NATS RBAC!) + workstation `nix.buildMachines`. Universal AC lid-closed mode (`HandleLidSwitchExternalPower = "ignore"`) works on home, hotel, café, and hotspot networks, guarded by mandatory lid-close `loginctl lock-sessions`, battery hysteresis (`≥ 35%` start / `< 25%` pause), thermal watchdog (`> 80 °C` worker pause / `> 90 °C` suspend), and metered-link data quotas.
<!-- abstract:end -->

# ADR-0014: Storage, Backups (`ST-UnifiedRestic`), Intermittent Pooled Storage (`SP-GitAnnex`) & Opportunistic Batch Compute (`DC-NATS-Pull`)

---

## 1. Empirical & Theoretical Grounding
Research ([`RES-0019`](../research/RES-0019-storage-backups-and-opportunistic-compute.md)) and live fault-injection testing on `astrolabe` ([`EXP-0010`](../experiments/EXP-0010-intermittent-storage-and-nats-compute-torture-test.md)) established four hard physical facts:
1. **Quorum Hash Rings Fail on Sleeping Laptops**: Live `Garage 2.5.0` testing proved that even with `consistency_mode = "degraded"` (which relaxes read quorum only, not write quorum $W=2$), a single sleeping laptop breaks **`100%` of S3 writes (`PUT 0/10`)**, skewed capacities strand `30%` of space (`84 GiB` on `tuf`), and dumb cloud storage (`hbox`, `gdrive`) cannot run daemons.
2. **`git-annex` Natively Solves Heterogeneous Intermittent Pooling**: Live `git-annex 10.20260421` testing passed at `0 MiB` idle RAM, unifying VPS + `hbox` (native SFTP) + encrypted `gdrive` + dynamically resizable laptops with zero rebalance storms and graceful offline reporting.
3. **Cloudflare R2 Pricing Makes 25–50 GB Binary Caching Trivially Cheap**: At `10 GB` free + `\$0.015/GB-mo` + `\$0.00` egress (and personal CI using `< 5%` of free Class A/B ops), `25–50 GB` of CDN-accelerated `BC-Niks3` cache + `< 0.5 GB` WORM critical backups costs **`\$0.22–\$0.60/mo`** (48–130× cheaper than Cachix paid) while avoiding mechanical-HDD random-I/O stalls on Hetzner Storage Boxes.
4. **Pull-Based NATS JetStream Outperforms Push Orchestrators on Intermittent Hardware**: Live `nats-server 2.15.2` testing measured `16.1 MiB` idle / `20.8 MiB` active RSS, `43.8 ms` clean unplug `-NAK` handoff, `2.45 s` crash redelivery, and `0` duplicate runs on long jobs under `+WPI` heartbeats.

---

## 2. Decision Outcome

### 2.1 Unified Backups, R2 Cost Envelope & Disk Quotas (`ST-UnifiedRestic`)
- **Backup Engine**: Sealed `services.restic` (`0.19.1` + `services.prometheus.exporters.restic`), 100% repo-format compatible with `rustic 0.11.4` for zero-migration future drop-in speedups. Driven declaratively by `S2+` Agent state traits:
  - **`backup:critical`** (`vaultwarden`, `antikythera` bare mirror + GitHub metadata JSON, `lldap`, `authelia`, `niks3` Postgres dump via crash-consistent `prepareCommand`s like `sqlite3 .backup` / `pg_dump`): Ships to **Cloudflare R2** (native S3 `s3:https://...`, zero `rclone` middleman; **prefix-scoped Governance WORM Bucket Locks** on `/data/` and `/snapshots/` leaving `/locks/` unlocked so `restic` lock cleanup & `forget --prune` never fail!) **AND** **Hetzner Storage Box (`hbox`)** (native SFTP tuned to `-o sftp.connections=3 --pack-size 16`) **AND** optional plugged-in home laptop/`rpi` append-only **`services.restic-rest-server`**!
  - **`backup:standard` / bulk host snapshots**: Ships to **`hbox`** + **`gdrive`** (via optional `rclone`, zero `${self}` leaks, non-blocking systemd automounts).
- **Cloudflare R2 `< \$2/mo` Cost-Value Envelope**: `BC-Niks3` GC targets optimal cost-value (~14–30d retention, naturally ~`25–50 GB` = `\$0.22–\$0.60/mo`) + `< 0.5 GB` critical WORM backups, guarded by VictoriaMetrics alerts (`80 GB` [`\$1.05/mo`] warning; `120 GB` [`\$1.65/mo`] critical + aggressive GC trigger, strictly `< \$2.00/mo`).
- **Substrate-Isolated Local Snapshots & Disk Quotas**: Native **`services.btrbk` (`0.32.7`)** + **Linux 6.18 Btrfs Simple Quotas (`squota`)** + `2 GiB` emergency headroom reserve replace ~970 LOC of custom v1 loopback/snapshot code and live **strictly inside the `btrfs-storage` Substrate Agent** so non-Btrfs hosts (`wsl`, `rpi` ext4) and ephemeral `live-iso` compose cleanly (`ADR-0010` / `QA-03`).

### 2.2 Opportunistic Pooled Fleet Storage & Warm Peer Cache (`SP-GitAnnex + Harmonia`)
- **Clear Three-Workload Separation** (eliminating conflict/misuse hazards):
  1. **Large Non-Critical Pooled Storage (`git-annex 10.20260421`, `0 MiB` idle RAM)**: Unifies VPS (`10 GB` NVMe), `hbox` (`100+ GB` native SFTP), **client-side encrypted `gdrive`** (`TB` via `rclone` special remote — Google never sees plaintext!), and dynamically resizable laptop pools (`100 GB–1 TB+`) for large immutable/archive/media libraries (e.g., media libraries for transcription, datasets, ISOs).
  2. **Small Live Bidirectional Working Sync**: Optional **`services.syncthing` (`2.1.7`, Tailnet-only)** for frequently edited docs/notes needing instant offline edits.
  3. **Web/Mobile File Hub**: **`Copyparty` (`1.20.26`, `12 MiB` RSS)** on `astrolabe` (Hetzner Box automount + optional `gdrive`, `zone:mesh` or Authelia-protected shares).
- **Workstation-Scoped `harmonia 3.3.0` Warm Peer Cache (`L3+` Enforced)**: Plugged-in workstations (`tuf`, `x240`, `zenbook`) and `rpi` expose their existing `/nix/store` read-only via `harmonia` (`~15 MiB` RAM, `0` extra disk) over Tailnet (`zone:mesh`) for instant gigabit LAN cache hits among dev devices. **Production `astrolabe` NEVER trusts laptop `harmonia` signing keys** — it pulls exclusively from `cache.nixos.org` + calibrated `BC-Niks3` R2.

### 2.3 Opportunistic Distributed Batch Compute (`DC-NATS-Pull`) & Universal AC Lid-Closed Mode
- **Broker & Pull Workers**: **`services.nats` (`2.15.2` JetStream, `~20 MiB` RSS)** on `astrolabe` (Tailnet-only `zone:mesh`, file-backed `WorkQueue` stream `jobs.>`) + lightweight **`aky worker`** pull daemons (`~5 MiB` RAM) on fleet hosts pulling from capability-matched subjects (`jobs.gpu`, `jobs.cpu.x86_64`, `jobs.arm64`, `jobs.any`).
- **Execution Reliability & Desktop Ergonomics**:
  - Long-running tasks (e.g., 20-min Whisper/FFmpeg chunks) maintain leases via `+WPI` heartbeats (`0` duplicates); clean preemption sends `-NAK` (`43.8 ms` handoff); hard crashes recover automatically via `AckWait`; results commit atomically (`.part` → rename → `+ACK`).
  - Workers run in low-priority cgroups (`Nice=19`, `CPUWeight=20`, `IOWeight=20`, bounded `MemoryHigh`) so interactive desktop workloads never lag.
- **Hard `L3+` Security Boundaries (Closed in Compliance Review!)**:
  1. **Allowlisted / Signed Nix Flake Closures Only**: `aky worker` executes *only* pinned task closures declared in calibrated `LW-54/antikythera` (or signed by `role:human-root` / Biscuit token) — **never arbitrary shell strings from NATS messages** (defeating fleet-wide RCE worms!).
  2. **Unprivileged Worker Sandbox**: `aky-worker.service` runs under a dedicated unprivileged user with `ProtectSystem=strict`, `NoNewPrivileges=true`, `PrivateTmp=true`, `InaccessiblePaths` hiding `/home`, `/run/secrets`, `/var/lib/vaultwarden`, `/var/lib/sops-nix`, and `/persist`, writable strictly to an isolated scratch/output directory.
  3. **Strict NATS RBAC (`submitter` vs `worker`)**: Only authorized human workstations hold `submitter` credentials (never AI agent sandboxes or worker-only nodes); `worker` credentials can strictly pull & ack/nak, never enqueue new jobs.
- **Workstation Nix Remote Builders**: Native `nix.buildMachines` (`ssh-ng://` over Tailscale SSH with SSH `command=` restriction and AC/battery/thermal gate) shared strictly among trusted workstations & `rpi` — **never exposing `trusted-users` remote builds on production `astrolabe`**.
- **Universal AC Lid-Closed Home/Travel Mode + Dynamic Conditions**:
  - `HandleLidSwitch = "suspend"` (battery) + `HandleLidSwitchExternalPower = "ignore"` (AC — works at home, hotels, cafés, and hotspots!).
  - **Mandatory Physical Security Lock**: Lid-close hook **always** runs `loginctl lock-sessions` even when staying awake on AC; unplugging AC while lid-closed triggers immediate `suspend` via `systemd-logind`.
  - **Thermal Watchdog (`aky-thermal-guard`)**: Pauses workers (`-NAK`) at `> 80 °C`; forces `systemctl suspend` at `> 90 °C` while lid closed (physically preventing overheating inside a bag!).
  - **Dynamic Compute/Sync Condition (Battery Hysteresis + Metered Data Quota)**:
    - Heavy compute & bulk transfers require: `AC online ∧ battery ≥ 35% (pause < 25%) ∧ temp < 80 °C`.
    - On **metered links (hotspots)**: SSH & light tasks continue working normally within a configurable metered byte quota (e.g., max `50 MB`/job, `250 MB/day` default unless `--allow-metered` is passed), deferring multi-GB media shuffles/snapshots until unmetered.

---

## 3. Compliance-Review Self-Audit Summary (6 Gaps Closed Prior to Ratification)
1. **NATS Fleet-Wide RCE Defense (`ADR-0004` `L3+`)**: Closed via allowlisted/signed Nix closures + strict `aky-worker` systemd sandbox + `submitter`/`worker` NATS RBAC.
2. **Lid-Closed Unlocked-Screen Exposure (`ADR-0011`)**: Closed via mandatory lid-close `loginctl lock-sessions` + AC-unplug immediate suspend + `90 °C` thermal suspend.
3. **Production `astrolabe` Trust Boundary (`ADR-0004` `L3+`)**: Closed by barring roaming laptop `harmonia` keys and `trusted-users` `nix.buildMachines` from `astrolabe`.
4. **R2 WORM Lock vs. Restic `/locks/` Clash (`ADR-0013`)**: Closed via prefix-scoped R2 Governance Locks on `/data/` & `/snapshots/` only + crash-consistent DB `prepareCommand`s.
5. **Non-Btrfs & Ephemeral Substrate Portability (`ADR-0010` / `QA-03`)**: Closed by isolating `btrbk` & `squota` inside `btrfs-storage` substrate and disabling persistence/workers on `live-iso`.
6. **Mutable vs. Immutable Storage Clarity & Cloud Encryption (`ADR-0004` `S2+`)**: Closed by separating `git-annex` (immutable/media + client-encrypted `gdrive`) from `Syncthing` (live notes) and `restic` (mutable service backups), plus metered-hotspot byte quotas.

## 4. Links
- Realizes: [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md), [`ADR-0006`](ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md), [`ADR-0010`](ADR-0010-open-orthogonal-substrate-composition-impermanence-and-hjem.md)
- Research & Live Tests: [`RES-0019`](../research/RES-0019-storage-backups-and-opportunistic-compute.md), [`EXP-0010`](../experiments/EXP-0010-intermittent-storage-and-nats-compute-torture-test.md)
- Integrates with: [`ADR-0011`](ADR-0011-trust-plane-sops-cedar-custody-and-pragmatic-capabilities.md), [`ADR-0012`](ADR-0012-mesh-fabric-tailscale-dual-ssh-and-split-horizon-tls.md), [`ADR-0013`](ADR-0013-gitops-tuf-pull-niks3-r2-governance-and-resilience.md)
