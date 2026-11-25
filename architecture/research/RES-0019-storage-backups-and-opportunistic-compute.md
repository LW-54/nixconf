---
id: RES-0019
title: Stage 3C.1 Research — Storage, Backups (Cloudflare R2 + Hetzner Box), Disk Quotas & Opportunistic Distributed Compute
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: distributed-storage-compute
tags: [research, stage-3c1, storage, backup, restic, rustic, borgmatic, btrbk, squota, syncthing, copyparty, taildrive, rclone, cloudflare-r2, hetzner-box, nix-builders, harmonia, nomad, k3s, incus, ollama, a-009]
assumptions: [A-009]
summary: Wide-spectrum 2025-2026 empirical and theoretical research for Stage 3C.1 (A-009): audits v1 storage/restic/rclone/snapshot/loopback-volume modules, evaluates backup engines against Cloudflare R2 WORM + Hetzner Storage Box, compares Btrfs Linux 6.18 squotas vs loopback ext4 images, surveys P2P sync vs clustered filesystems on intermittent laptops, and analyzes opportunistic Nix remote builders + TUF dGPU inference vs Nomad/K3s/Incus.
---

<!-- abstract:start -->
## Executive Abstract

Evaluates the complete 2025–2026 design space for **Stage `3C.1` (`A-009`: Storage, Backups, Local Disk Quotas, Cross-Device File Sync, and Opportunistic Distributed Compute)** on top of [`ADR-0004`](../adrs/ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md) (`S2+` State-As-Promise), [`ADR-0006`](../adrs/ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md) (Budgeted Capacity & Dynamic Power Conditions), [`ADR-0012`](../adrs/ADR-0012-mesh-fabric-tailscale-dual-ssh-and-split-horizon-tls.md) (Tailscale Mesh), and [`ADR-0013`](../adrs/ADR-0013-gitops-tuf-pull-niks3-r2-governance-and-resilience.md) (Cloudflare R2 consolidation, retiring Backblaze B2 completely).

**Five key empirical & theoretical findings validating `A-009`**:
1. **Eliminate Unnecessary `rclone` Backup Indirection**: v1 routed every `restic` backup through `rclone:` (forcing `rclone-config.service`, obscured templates, and harboring the residual `${self}` cache leak at [`modules/implementations/rclone/mounts.nix:132`](../../modules/implementations/rclone/mounts.nix#L132)). `restic 0.19.1` (native `services.restic` + `services.prometheus.exporters.restic` in pinned `nixpkgs`) talks **native S3** directly to **Cloudflare R2** (with Governance-mode Bucket Locks for ransomware-proof WORM + safe `forget --prune`) and **native SFTP** (tuned to `sftp.connections=3`, `--pack-size 16`) to **Hetzner Storage Box**, while remaining 100% repo-format compatible with **`rustic 0.11.4`** for zero-migration future drop-in speedup.
2. **Replace 518-LOC Loopback Ext4 Manager + 452-LOC Custom Snapshot Script**: Live `astrolabe` runs **Linux `6.18.60`** — far past Linux 6.7's **Btrfs Simple Quotas (`squota`)**, which eliminate legacy `qgroup` backref stalls while preserving CoW snapshots, zstd compression, and dynamic resize. Combined with native **`services.btrbk` (`0.32.7`)**, ~970 LOC of fragile bespoke v1 storage plumbing collapses into clean declarative primitives.
3. **Clustered Filesystems Are Structurally Hostile to Intermittent Laptops**: `Ceph`, `Garage 2.5.0`, and `SeaweedFS 4.48` require stable server quorums/heartbeats; sleeping laptops trigger rebalancing and degraded health. For roaming laptops + `astrolabe` + `rpi`, **Syncthing (`2.1.7`, Tailnet-only)** provides true offline-first P2P sync, **Copyparty (`1.20.26`)** provides a fast web/mobile file hub backed by Hetzner Box automount, and **Tailscale Taildrive** handles ad-hoc remote peeking.
4. **Opportunistic Nix Remote Builders + Conditional GPU Endpoint Outperform Cluster Orchestrators (`A-009` Validated)**: Nix's native `ssh-ng://` remote builders (`nix.buildMachines`) over Tailscale SSH gracefully ignore sleeping/unplugged laptops with zero split-brain state, gated cleanly on the **TUF laptop** by a `/sys/class/power_supply` AC-power + idle check (`ADR-0006` dynamic Condition `C`), optionally paired with Tailnet **`harmonia 3.3.0`** peer caching and a standalone conditional **`ollama`/`llama-cpp`** dGPU OpenAI-compatible API endpoint — avoiding the `NotReady`/eviction churn of `K3s`, `Incus Cluster`, or always-on `Nomad` control planes.
<!-- abstract:end -->

# RES-0019: Storage, Backups, Disk Quotas & Opportunistic Distributed Compute (`A-009`)

---

## 1. On-Disk Audit of v1 Storage & Backup Subsystems

### 1.1 Audited v1 Footprint
- **Storage Providers & Slices** ([`providers.nix`](../../modules/contracts/storage/providers.nix), [`slices.nix`](../../modules/contracts/storage/slices.nix)):
  - `hbox` (Hetzner Storage Box `u711975` — SSH/SFTP/WebDAV/SMB backing `copyparty`, `uchiyomi`, `hbox-backup-host`, `hbox-backup-shared`), `gdrive` (`gdrive`, `gdrive-backup-*`), and `b2` (**now retired by `ADR-0013` in favor of Cloudflare R2**).
- **Backup Engine** ([`restic/jobs.nix`](../../modules/implementations/restic/jobs.nix)):
  - Clean declarative per-service `backup` unit registration (`beforeUnits`, `prepareCommand`, `retention`, `scope = "shared" | "host"`), **but** forced every repository URL through `rclone:` (`rclone.program=...`, `b2-hard-delete = true`, hard dependency on `rclone-config.service`).
- **Host Snapshots** ([`snapshot.nix`](../../modules/features/snapshot.nix), 452 LOC):
  - Takes atomic local read-only Btrfs snapshots of `/persist` and ships them via Restic to `hbox` and `gdrive`.
- **Disk Quota Volumes** ([`cgroups/volumes.nix`](../../modules/implementations/cgroups/volumes.nix), 518 LOC + [`astrolabe/resources.nix`](../../modules/hosts/astrolabe/resources.nix)):
  - Manages 9 loopback `.img` ext4 files (`emergency-headroom 2G`, `caddy-data 256M`, `authelia-data 256M`, `lldap-data 256M`, `vaultwarden-data 512M`, `ntfy-data 256M`, `rclone-cache 25G`, `victorialogs-data 15G`, `victoriametrics-data 25G`) to guarantee telemetry/caches can never exhaust the 100 GiB root disk and crash critical services (`vaultwarden`, `caddy`).
  - *Cost*: 518 LOC of custom `fallocate`/`mkfs.ext4`/loop-mount/resize shell code, sacrifices Btrfs CoW snapshots & zstd compression inside those volumes, and is bare-metal-only (breaks on WSL/ISO).
- **FUSE Mounts & File Hub** ([`rclone/mounts.nix`](../../modules/implementations/rclone/mounts.nix), [`copyparty.nix`](../../modules/features/copyparty.nix)):
  - Copyparty (`12 MiB` RSS) provides an excellent multi-protocol web file hub & `/drop` dead-drop backed by Hetzner Box + optional Google Drive.
  - `rclone/mounts.nix:132` had the `${self}` cache-isolation leak (`DEVENV_ROOT=${self}`), and FUSE mounts hang on roaming laptops when Wi-Fi drops.

### 1.2 Live System & Pinned `nixpkgs` (`1d06008`) Inventory
- **Live `astrolabe` kernel**: **`Linux 6.18.60`** (full Btrfs `squota` support since Linux 6.7!).
- **Pinned `nixpkgs` Packages & Native NixOS Modules**:

| Package | Version | Native NixOS Module? | Role |
| :--- | :---: | :---: | :--- |
| `restic` | `0.19.1` | Yes (`services.restic` + `exporters.restic`) | Battle-tested encrypted deduplicated backups (native S3 + SFTP!) |
| `rustic` | `0.11.4` | No *(CLI/custom unit)* | Fast low-RAM Rust drop-in compatible with `restic` repo format |
| `borgbackup` / `borgmatic` | `1.4.5` / `2.1.7` | Yes (`services.borgmatic` + exporter) | Native SSH backup (great for Hetzner Box; cannot speak native S3/R2!) |
| `kopia` | `0.23.1` | No | Fast S3/SFTP backup with policy engine; non-native NixOS module |
| `btrbk` | `0.32.7` | Yes (`services.btrbk`) | Standard declarative atomic Btrfs snapshot & send/receive manager |
| `syncthing` | `2.1.7` | Yes (`services.syncthing`) | Masterless offline-first P2P file sync |
| `copyparty` | `1.20.26` | Package *(thin unit)* | Lightweight web/WebDAV file hub & resumable upload drop-box |
| `rclone` | `1.75.2` | Package *(mount/sync)* | Cloud FUSE/sync Swiss Army knife (for `gdrive` / Hetzner Copyparty mount) |
| `garage_2` / `seaweedfs` | `2.5.0` / `4.48` | `services.garage` / pkg | Server-only S3/blob clusters (hostile to sleeping laptops) |
| `harmonia` | `3.3.0` | Yes (`services.harmonia`) | Zero-DB Rust Nix binary cache serving local `/nix/store` (LAN/Tailnet peer) |
| `nomad` / `incus` | `1.11.3` / `7.6.0` | Yes | Optional batch scheduler / local VM+container hypervisor |
| `ollama` / `llama-cpp` | `0.40.13` / `0.8.0` | Yes | Local GPU LLM inference servers (TUF hybrid dGPU) |

---

## 2. Dimension 1 — Backup Engine, Multi-Cloud Durability & Local Disk Quotas

### 2.1 Backup Engine Comparison Against Cloudflare R2 (WORM) + Hetzner Storage Box
| Option | Cloudflare R2 (Native S3 + WORM Bucket Locks) | Hetzner Storage Box (`hbox`) | Native NixOS Module & Metrics | Maintenance & Future Escape Hatch |
| :--- | :--- | :--- | :--- | :--- |
| **`BK-ResticNative`** *(Recommended)* — `services.restic` (`0.19.1`) native S3 (R2) + native tuned SFTP (`hbox`) + `services.btrbk` (`0.32.7`) local snapshots | **Native S3 (`s3:https://...`)**, zero `rclone` middleman; Governance-mode R2 Bucket Locks (30–90d) protect packs against ransomware while permitting scheduled `forget --prune` | **Native SFTP** tuned (`-o sftp.connections=3`, `--pack-size 16`) avoiding Hetzner HDD/SSH throttling | **First-class** `services.restic` + `services.prometheus.exporters.restic` + `services.btrbk` | **1 single backup format everywhere**; **100% repo-compatible with `rustic 0.11.4`** (drop-in zero-migration Rust speedup if ever needed!) |
| **`BK-Borg+Restic`** — `borgmatic` (Hetzner SSH) + `restic` (Cloudflare R2) | `restic` native S3 | Native Borg over Hetzner SSH (fastest Hetzner HDD compression/dedup) | Both have native NixOS modules + exporters | **2 backup engines, 2 key/repo formats, 2 restore drills** (`D` maintenance penalty) |
| **`BK-Rustic`** — `rustic 0.11.4` custom systemd units + TOML profiles | Native S3 + native lock-free two-phase prune + cold storage | Native async SFTP | No upstream NixOS module yet (custom unit maintenance) | Still pre-1.0 (`0.11.4`); safer to keep `restic` repo format via `services.restic` and invoke `rustic` selectively where beneficial |
| **`BK-Kopia`** — `kopia 0.23.1` | Native S3 | Native SFTP | No upstream NixOS module | Separate proprietary chunk format; weaker NixOS ecosystem integration |

**State-As-Promise (`ADR-0004` `S2+`) Integration**:
- Any Agent offering a persistent volume with trait `backup:critical` (e.g., `vaultwarden`, `antikythera` bare mirror + GitHub metadata, `lldap`, `authelia`, `niks3` Postgres dump via `prepareCommand`) binds declaratively to **both** `R2` (WORM Governance Lock) and `hbox` (independent cloud provider, defeating Cloudflare account lockout) — plus optional **`rpi`** local home copy when onboarded!
- Any Agent with trait `backup:standard` backs up to `hbox` (cheap bulk capacity), while `Ephemeral` caches (`niks3` R2 binary cache, `rclone-cache`) never waste backup bandwidth.
- **No `rclone` dependency for backups**: `rclone` stays strictly scoped to optional FUSE/WebDAV automounts (`gdrive`, Copyparty's Hetzner mount) with non-blocking systemd `automount` + idle timeout so offline networks never hang boot (`QA-07`) and zero `${self}` references ever exist!

### 2.2 Local Disk Quota Isolation on `astrolabe` (100 GiB Root Disk)
| Option | Protection Against Runaway Telemetry / Caches | CoW Snapshots & Zstd Compression | Complexity & Maintenance |
| :--- | :--- | :---: | :--- |
| **`Q-BtrfsSquota`** *(Recommended)* — Btrfs subvolumes + Linux 6.18 Simple Quotas (`squota`) + 1 small `2 GiB` emergency headroom reserve | **Hard per-subvolume byte limits** (`btrfs qgroup limit 25G ...`) with near-zero CPU overhead (no legacy backref walking!) | **Preserved** (native `btrbk` snapshots + zstd) | Replaces **518 LOC** custom loopback script with tiny declarative subvolume + quota setup |
| **`Q-Hybrid`** — Btrfs `squota` for normal services + thin ext4 loopback `.img` *only* for high-churn caches (`rclone-cache`) | Air-tight block boundary on cache dir | Preserved for all services | Small extra complexity only if `rclone-cache` needs strict non-CoW separation (`chattr +C` already disables CoW on a Btrfs subvolume!) |
| **`Q-Loopback`** *(v1 status quo)* — 9 ext4 `.img` loopback files | Air-tight fixed ceilings | **Lost** on all 9 volumes | 518 LOC custom resize/mount plumbing; rigid |

### 2.3 Cross-Device File Sync & Access (Intermittent Laptops, Tablet, RPi, VPS)
- **Clustered Distributed Filesystems Rejected (`A-009`)**: `Ceph`, `Garage 2.5.0`, and `SeaweedFS 4.48` assume always-on server quorums. Running them on roaming/sleeping laptops causes constant rebalancing, `Degraded` alerts, and split-brain hazards. *(If a future multi-server homelab emerges, `Garage` is the clean lightweight S3 candidate for always-on servers only.)*
- **Clean Composable Three-Role Stack (`FS-Syncthing+Copyparty`)**:
  1. **Offline-First P2P Sync → `Syncthing` (`2.1.7`, `services.syncthing`, Tailnet-only)**: Syncs user documents, notes, projects across `x240`, `zenbook`, `tuf`, `chromebook`, `astrolabe` (always-on relay/anchor), and `rpi` — works 100% offline, reconciles cleanly on reconnect, zero central SPOF!
  2. **Web / Mobile File Hub & Dead-Drop → `Copyparty` (`1.20.26`, `12 MiB` RSS on `astrolabe`)**: Fast web/WebDAV file browser + `/drop` upload inbox over `hbox` automount (and optional `gdrive`), reachable on `zone:mesh` (or Authelia-protected public share links).
  3. **Ad-Hoc On-Demand Peeking → `Tailscale Taildrive`** *(optional, zero daemon overhead)*: Quick Tailnet WebDAV access to another awake machine's folder without syncing full copies to disk.

---

## 3. Dimension 2 — Opportunistic Distributed Compute & Builders (`A-009`)

### 3.1 Physical Constraints of Our Fleet
- **Always-on constrained anchors**: `astrolabe` (6 vCPU / 11 GiB RAM VPS — primary production edge; avoid burning RAM on heavy orchestrators), `rpi` (`aarch64`, low RAM/power, always-on home node).
- **Intermittent high-compute bursts**: **TUF gaming laptop** (strong multi-core `x86_64` CPU + hybrid **discrete GPU** when plugged into AC at home!), plus `x240` / ZenBook Duo.

### 3.2 Contender Comparison for Intermittent Fleet Compute
| Option | Intermittent / Sleeping Laptop Behavior | Value Delivered for `antikythera` | VPS RAM / Ops Complexity |
| :--- | :--- | :--- | :--- |
| **`DC-OpportunisticNix+GPU`** *(Recommended)* — Nix `ssh-ng://` remote builders over Tailscale SSH + AC/idle gate + optional TUF `harmonia` peer cache + standalone conditional `ollama`/`llama-cpp` dGPU endpoint | **100% Graceful (`QA-07`)**: If TUF sleeps or unplugs, Nix transparently falls back locally; Tailnet LLM endpoint simply marks unavailable with zero quorum loss or eviction storms! | **>85% of practical fleet compute value**: offloads heavy local `x86_64` Rust/Lean/Nix builds + local `aarch64` RPi builds + local dGPU LLM inference over Tailscale (`zone:mesh`) | **`0 MiB` extra VPS RAM!** Zero cluster control plane; pure `ADR-0006` conditional promises (`\| power:ac-plugged ∧ host:idle`) |
| **`DC-NomadBatch`** — Everything above **plus** HashiCorp `Nomad 1.11.3` (`astrolabe` server + TUF `batch`-only client) | Good (handles disappearing batch workers better than K3s) | Adds generic arbitrary batch container/binary scheduling across nodes | `~80–150 MiB` RAM on `astrolabe` + Nomad server/ACL/BSL-license maintenance for rare ad-hoc batch jobs |
| **`DC-NixBuildersOnly`** — Strictly Nix `ssh-ng://` remote builders only | 100% Graceful | Fast distributed Nix builds only; leaves TUF dGPU unused by fleet | `0 MiB` RAM; trivial to add `harmonia` + `ollama` later |
| **`DC-K3s` / `DC-IncusCluster`** *(Rejected)* | **Hostile**: `NodeLost` pod evictions, Dqlite quorum loss on sleeping laptops | Overkill for personal fleet + breaks `QA-07` graceful degradation | `500 MiB–1.5 GiB` RAM + high ops burden *(standalone single-node `incus` remains fine for local VMs/sandboxes)* |

---

## 4. Deep Revision — Strict `< 10 GB` R2 Budget, Availability-Weighted Pooled Storage & Heterogeneous Batch Compute

Following user clarification (2026-11-25), we locked **`ST-UnifiedRestic`** with two explicit budget/provider constraints and conducted a deeper second-pass literature & pinned-`nixpkgs` (`1d06008`) survey for **pooled intermittent storage** and **general-purpose distributed batch compute** (e.g., transcribing a large media library / FFmpeg / compute-heavy pipelines across all currently online devices):

### 4.1 Cloudflare R2 `< 10 GB` Free-Tier Budget + `gdrive` Preservation
- **Cloudflare R2 (`< 10 GB` hard target, `\$0.00/mo`)**: Reserved strictly for compact, high-value, zero-egress workloads:
  1. **`BC-Niks3` binary cache** (~`3–6 GB` with strict reference-tracking GC),
  2. **`backup:critical` WORM-locked backups** (`vaultwarden`, `antikythera` Git bundle + metadata JSON, `lldap`, `authelia`, `niks3` Postgres dump — total `< 0.5 GB`!).
  - Enforced by an automated `8 GB` (`80%`) budget alert in `3C.2` observability!
- **Bulk Storage & Backups**: **Hetzner Storage Box (`hbox`)** + **Google Drive (`gdrive` via optional `rclone`)** hold all large `/persist` host snapshots, bulk archives, and media mounts.

### 4.2 Opportunistic Pooled Storage Across Intermittent Devices (Trust / Availability Weighting & Importance / Frequency Prioritization)
Pinned `nixpkgs` verified: `garage_2 2.5.0`, `git-annex 10.20260421`, `juicefs 1.4.1`, `kubo 0.43.1`, `ipfs-cluster 1.1.6`, `tahoe-lafs 1.20.0`, `moosefs 4.59.2`, `seaweedfs 4.48`.

| Contender | Availability Trust Weighting | Importance / Access-Frequency Placement | Intermittent / Sleeping Laptop Behavior | API / Ergonomics | Honest Limits |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`SP-GitAnnex`** *(`git-annex 10.20260421`, Haskell, `0 MiB` idle RAM)* | **Native first-class**: explicit `trusted` / `semitrusted` / `untrusted` repositories (roaming laptops marked `untrusted`/`client` never trick the pool into dropping authoritative copies!) | **Native declarative `wanted` / `groupwanted` rules**: pin `important/*` onto always-on hubs (`astrolabe`/`rpi`/`hbox`), spill bulky/non-critical data (`lackingcopies=1`) across spare disk on online laptops, auto-cache hot/small working files locally and drop cold files cleanly! | **100% Native Intermittent Physics**: zero quorums, zero rebalance storms; sleeping holder cleanly reports *"offline on `tuf`"* until wake; works over Tailscale SSH + S3 + `hbox` + `gdrive`! | File/directory Git-backed pool (`unlocked` files, `aky pool` wrapper); zero always-on daemon RAM | Not a live S3 object server for S3-only apps; steeper native CLI unless wrapped cleanly behind `aky` |
| **`SP-GarageDegraded`** *(`garage_2 2.5.0`, Rust, CRDT metadata, ~30–60 MiB RAM)* | Static manual `capacity` weights + `zone` isolation per node (no dynamic availability trust score) | **None natively**: uniform global `replication_factor` across buckets (no per-file importance or LRU access-frequency tiering) | **CRDT metadata survives splits**, *but* `consistent` mode needs majority quorum (`2/3`) per partition — if 2 laptops sleep, those partitions stall unless switched to `degraded`/`dangerous` (split-brain risk) | **Standard S3 API** (seamless for apps, `rclone`, `JuiceFS`, batch pipelines!) | Poor fit for frequently sleeping laptops as primary storage nodes unless restricted to stable anchors (`astrolabe` + `rpi` + plugged-in home box) |
| **`SP-Hybrid` (`GitAnnex` Fleet Pool + `Garage` Anchor S3)** | Best of both worlds: `git-annex` pools **all intermittent laptops** with native trust & importance rules; optional `Garage` runs ONLY on always-on anchors (`astrolabe` + `rpi`) as S3 scratch/staging for batch compute! | Full `git-annex` declarative importance/access placement across laptops + fast S3 staging for compute workers | Zero quorum stalls on laptops; stable S3 staging on anchors | Unified file pool + S3 API for compute pipelines | Two storage systems to configure (can deploy `git-annex` first and add `Garage` when `rpi` joins!) |
| **`SP-IPFSCluster`** *(`kubo 0.43.1` + `ipfs-cluster 1.1.6`)* | Peer allocation weights | CRDT `replication_factor_min`/`max` per CID + local GC LRU eviction | Tolerates offline peers via CRDT catch-up | Content-addressed CIDs (awkward without MFS/POSIX layer) | Heavy (`150–300 MiB`/node), weak native ACLs, poor POSIX UX |
| **`SP-JuiceFS` / `Tahoe-LAFS` / `MooseFS` / `SeaweedFS`** | `Tahoe` has zero-trust shares; `JuiceFS` has great client LRU | `JuiceFS` clients cache hot blocks via local SSD LRU, **but laptops cannot donate storage back to the pool!** | `MooseFS`/`SeaweedFS`/`Tahoe` trigger repair/rebalance churn on sleeping laptops | Mixed | Disqualified for intermittent storage-donating laptops |

> **Promise Theory Opportunity (`E3` + `git-annex`)**: Because `E3` observability tracks each host's real-time uptime/availability $T_{\text{avail}}(h)$, a tiny policy loop (or `aky pool sync`) can automatically adjust `git-annex` group membership / `wanted` quotas and surface per-dataset availability & access heat without fighting a distributed consensus protocol!

### 4.3 Automatic Resource-Aware Distributed Batch Compute Across All Online Devices
Pinned `nixpkgs` verified: `nats-server 2.15.2` (native `services.nats`), `nomad 1.11.3` (native `services.nomad`), `htcondor 24.2.2` (no NixOS service module), `slurm 26-05-5-1`, `pueue 4.0.4` (`bacalhau` missing from `nixpkgs`).

| Contender | Idle RAM (`astrolabe` / Laptop) | Heterogeneous Resource Matching (TUF dGPU vs `x240`/`astrolabe` CPU vs `rpi` ARM64) | Sleeping / Battery Laptop Behavior | Workload Generality (Whisper / FFmpeg / Arbitrary CLI) | Operational Complexity & License |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **`DC-NATS-Pull`** *(Recommended)* — **`services.nats` (`2.15.2`, JetStream)** on `astrolabe` + thin pull worker (`aky worker` in `crates/aky-cli`) on every host + native `nix.buildMachines` for Nix builds | **`~30 MiB`** on `astrolabe`; **`~5 MiB`** on laptops *(zero C-state polling drain!)* | **Autonomous Pull Self-Matching (Promise Theory!)**: Each online host pulls from capability-matched subjects (`jobs.gpu`, `jobs.cpu`, `jobs.any`) strictly when `power:ac-plugged ∧ host:idle ∧ thermal:nominal`. A fast TUF RTX dGPU naturally drains 20× more Whisper chunks than a slow CPU without fragile central bin-packing heuristics! | **Built for intermittent edge**: Lid closes or AC unplugs → worker `NAK`s cleanly (or `AckWait` expires) → exact chunk auto-requeues onto another online host with **zero eviction storms or dead-node cleanup**! | **100% Universal**: Executes any reproducible Nix flake app/binary (`whisper-cpp`, `faster-whisper`, `ffmpeg`, Python, Rust) with zero Docker daemon required! | Ultra-clean, Apache-2.0 FOSS, `aky batch {submit,status,cancel}` + `--json` for AI agents (`QA-10`) + Prometheus metrics for `3C.2` |
| **`DC-Nomad`** — **HashiCorp `Nomad 1.11.3`** (`services.nomad` server on `astrolabe` + clients on all hosts w/ `exec`/`raw_exec` + `nvml` GPU fingerprinting) + `nix.buildMachines` | `~70–110 MiB` on `astrolabe`; `~50 MiB` on laptops *(requires tuning `collection_interval` to protect laptop battery C-states!)* | **Full off-the-shelf scheduler**: Native `nvml` GPU/CPU/RAM fingerprinting, HCL parameterized batch jobs, built-in Web UI (`zone:mesh`) showing live fleet utilization | Good with scripting: requires AC/battery hook running `nomad node drain` + tuned `node_gc_threshold` so sleeping laptops don't stall allocations | **Universal** (binaries, Nix closures, containers, cron batch, long-running services) | Battle-tested off-the-shelf scheduler + Web UI, **but** higher RAM, HCL boilerplate, laptop C-state tuning, and **HashiCorp BSL license** |
| **`DC-HTCondor`** — **`htcondor 24.2.2`** | `~100–200 MiB` | Unmatched academic ClassAds + keyboard-idle preemption & checkpointing | Gold-standard desktop scavenging | Universal | High ops complexity (`D` penalty), no upstream NixOS service module |
| **`DC-Ray` / `DC-Dask`** | `~300–600 MiB` | Great Python/ML GPU scheduling | **Fragile on sleeping Wi-Fi laptops** (TCP heartbeat drops crash active task graphs) | Python-only | Poor fit for intermittent laptops & arbitrary CLI workloads |

> **Shared Storage Bridge**: Notice how cleanly **`DC-NATS-Pull`** (or **`DC-Nomad`**) composes with **`SP-GitAnnex`** / **`hbox`** / **`Garage`**: a batch Whisper transcription job simply passes each file's reference/path (from Hetzner Box, `git-annex`, or `Garage` staging), workers pull the audio locally, transcribe on GPU/CPU, write `<file>.srt/.json` atomically back, and `Ack` the chunk!

