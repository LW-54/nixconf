---
id: EXP-0010
title: Stage 3C.1 Empirical Torture Test — NATS JetStream WorkQueue, Garage v2 Skewed Intermittent Cluster & git-annex
type: experiment
status: completed
created: 2026-11-25
updated: 2026-11-25
domain: distributed-storage-compute
tags: [experiment, benchmark, stage-3c1, nats, jetstream, garage, git-annex, intermittent-laptops, fault-injection, a-009]
assumptions: [A-009]
summary: Live fault-injection experiment on astrolabe benchmarking NATS JetStream 2.15.2 WorkQueue (16.1-20.8 MiB RSS, 43.8 ms -NAK handoff, 2.45 s crash recovery, 0 duplicates under +WPI heartbeats), Garage v2 2.5.0 under skewed 10G/300G/200G laptop capacities (empirically falsifying intermittent laptop usage: 0/10 PUTs survive 1 sleeping laptop even in degraded mode, 84 GiB stranded), and git-annex 10.20260421 (0 MiB idle RAM, automatic placement & graceful offline reporting).
---

<!-- abstract:start -->
## Executive Abstract

Executed a live empirical fault-injection benchmark on `astrolabe` (`Linux 6.18.60`) against real pinned `nixpkgs` binaries (`nats-server 2.15.2`, `natscli 0.5.1`, `garage 2.5.0`, `git-annex 10.20260421`) to test three Stage `3C.1` (`A-009`) architectures under sudden laptop sleep/unplug faults:
1. **`NATS JetStream 2.15.2` (`DC-NATS-Pull`) — PASSED**: `16.1 MiB` idle / `20.8 MiB` active RSS; clean battery-unplug `-NAK` hands off tasks to another worker in **`43.8 ms`**; hard worker crash recovers automatically via `AckWait` (`2.45 s`, `tries: 2`); long-running tasks exceeding `AckWait` stay exclusively leased via `+WPI` (`InProgress`) heartbeats with **0 duplicate executions**.
2. **`Garage v2 2.5.0` on Skewed Intermittent Laptops (`10G VPS / 300G tuf / 200G x240`, `R=2`) — FALSIFIED FOR SLEEPING LAPTOPS**: `31–38 MiB` RSS/node, **but** (a) zone-matching stranded **`84 GiB` (`30.1%`)** of `tuf`'s 279.4 GiB capacity; (b) killing **just 1 laptop (`x240`)** caused **`PUT 0/10` (`100%` write failure)** in **both `consistent` AND `degraded` modes** (`degraded` relaxes read quorum only, not write quorum $W=2$!); and (c) killing both laptops caused **`GET 0/20` and `PUT 0/10`**. (CRDTs healed cleanly to `GET 20/20` once both woke, proving Garage works strictly for **always-on** server clusters, not sleeping laptops or cloud remotes like `hbox`/`gdrive`.)
3. **`git-annex 10.20260421` — PASSED**: `0 MiB` idle RAM; automatically placed `important/vault.dat` onto `[astrolabe, tuf]` (freeing `x240`) and spilled `media/lecture.mkv` onto `[tuf]`; taking `tuf` offline left `important/vault.dat` 100% accessible from `astrolabe` while `media/lecture.mkv` gracefully reported offline with zero stalls or corruption, recovering immediately on reconnect.
<!-- abstract:end -->

# EXP-0010: Intermittent Fleet Storage & Distributed Batch Compute Fault-Injection Benchmark

## 1. Environment & Methodology
- **Host**: `astrolabe` (`x86_64-linux`, `Linux 6.18.60`, 6 vCPU / 11 GiB RAM).
- **Exact Pinned Binaries** (`nixpkgs 1d06008`):
  - `/nix/store/6g2yisfa1h6vg59maalcvi42rkjksl31-nats-server-2.15.2`
  - `/nix/store/sya7kgar2bqv8q9x336ys4g55zfwaif2-natscli-0.5.1`
  - `/nix/store/20yzhkbicl6rr6ks3bhvpi10fgvcih0p-garage-2.5.0`
  - `/nix/store/aa50492zyil9apyvxd2s2gf0m3nfmmzj-git-annex-10.20260421`
- **Closure Size Baseline**: `nix path-info -Sh /run/current-system` = **`6.9 GiB`** full `astrolabe` closure (~95% upstream `cache.nixos.org`).

---

## 2. Empirical Results

### Test 1 — `NATS JetStream 2.15.2` WorkQueue (`DC-NATS-Pull`)
| Metric / Fault Scenario | Measured Result |
| :--- | :--- |
| Broker Idle RSS (`VmRSS`) | **`16.1 MiB`** |
| Broker Active RSS (WorkQueue + file storage) | **`20.8 MiB`** |
| Fault A — Clean unplug / preemption (`-NAK`) redelivery latency | **`43.8 ms`** (`chunk-2` instantly handed to next worker) |
| Fault B — Hard lid-close / crash (no `Ack`, `AckWait=2s`) | **`2.45 s`** automatic redelivery (`tries: 2`) |
| Fault C — Long task (`3.0 s > 2.0 s AckWait`) with `+WPI` (`InProgress`) heartbeats | **`0` duplicate deliveries** (concurrent worker pulled `chunk-4`) |

### Test 2 — `Garage v2 2.5.0` Skewed Intermittent Cluster (`10G` / `300G` / `200G`, `R=2`, 64 KiB Blobs)
*(Note: Initial run with 6-byte payloads hit Garage's metadata inline optimization, masking block loss; corrected to 64 KiB payloads to measure real data-block placement!)*

| Node | Assigned Capacity | Garage Usable Capacity | Measured RSS |
| :--- | :---: | :---: | ---: |
| `astrolabe` (VPS) | `9.3 GiB` | `9.2 GiB` (`98.4%`) | `37.6 MiB` |
| `x240` (Laptop 1) | `186.3 GiB` | `186.3 GiB` (`100.0%`) | `33.4 MiB` |
| `tuf` (Laptop 2) | `279.4 GiB` | **`195.4 GiB` (`69.9%` — `84 GiB` stranded!)** | `31.4 MiB` |

| Fault Scenario (`64 KiB` Blobs, `R=2`) | `consistent` Mode | `degraded` Mode |
| :--- | :--- | :--- |
| All 3 nodes online | `PUT 20/20` | `PUT 20/20` |
| **1 laptop sleeps** (`x240` `SIGKILL`) | `GET 19/20`, **`PUT 0/10`** | `GET 19/20`, **`PUT 0/10`** |
| **2 laptops sleep** (only `10G` VPS online) | **`GET 0/20`**, **`PUT 0/10`** | **`GET 0/20`**, **`PUT 0/10`** |
| Both laptops wake back up | **`GET 20/20`** *(CRDT healed)* | **`GET 20/20`** *(CRDT healed)* |

> **Critical Discovery**: Because `astrolabe` (`10G`) is tiny relative to `tuf` (`300G`) + `x240` (`200G`), `~95%` of partitions land on `{tuf, x240}`. Under `R=2`, **write quorum is $W=2$ in BOTH `consistent` and `degraded` modes** (`degraded` relaxes read quorum only). Thus a single sleeping laptop breaks 100% of S3 writes (`PUT 0/10`). Garage v2 is therefore **strictly suited to always-on server anchors**, NOT intermittent laptops or dumb cloud remotes (`hbox`, `gdrive`).

### Test 3 — `git-annex 10.20260421` Trust Levels + `wanted` Placement + Offline Laptop
| Check | Measured Result |
| :--- | :--- |
| Idle RAM | **`0 MiB`** (pure CLI / event-or-timer synced) |
| Auto-placement (`important/*` wanted by `astrolabe`, `*` by `tuf`, `hot/*` by `x240`) | `important/vault.dat` → `[astrolabe, tuf]`; `media/lecture.mkv` → `[tuf]` (`x240` space freed!) |
| Trust-safety check (when both `tuf` & `x240` marked `untrusted`) | `git-annex` **refused** to drop last copy until a `semitrusted` holder confirmed receipt! |
| Fault — `tuf` taken offline (`mv`) | `get important/vault.dat` → **`rc=0`** (fetched from `astrolabe`); `get media/lecture.mkv` → **`rc=1`** (clean offline notice, zero corruption/stalls) |
| Recovery — `tuf` returns online | `get media/lecture.mkv` → **`rc=0`** (instant retrieval) |

## 3. Architectural Conclusions
1. **`DC-NATS-Pull` is empirically validated**: `20.8 MiB` active RAM, `43.8 ms` clean preemption handoff, zero duplicate long-running jobs under `+WPI` heartbeats, and automatic crash recovery.
2. **Intermittent Laptop Storage Pooling MUST NOT use Quorum S3 Rings (`Garage`)**: `Garage` fails writes (`0/10`) the instant 1 laptop sleeps, strands `30%` of skewed capacity, and cannot include `hbox`/`gdrive`. **`git-annex`** natively pools `10 GB VPS` + `100 GB hbox` + `gdrive` + `100–500 GB` dynamically resizable laptops at `0 MiB` idle RAM with zero quorum stalls.
3. **Binary Cache > 10 GB Strategy**: `niks3` requires an *always-on* S3 endpoint for 24/7 GitHub Actions CI — best served by **`BC-Niks3` on Cloudflare R2** (hot active closures `< 10 GB` free tier, or `\$0.015/GB/mo` above 10 GB) paired with **Tailnet `harmonia` peer caching** across every plugged-in laptop/VPS (zero extra disk, serving 100s of GB of existing `/nix/store` closures at LAN speed) + optional `restic-rest-server` on plugged-in home laptops for extra free backup copies!
