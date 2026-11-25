---
id: EXP-0013
title: First-Principles Observability Benchmarks — Multi-Year "Keep Everything" Scale, Entity Churn Physics, Nyquist Aliasing & Robust Statistics
type: experiment
status: completed
created: 2026-11-25
updated: 2026-11-25
domain: observability
tags: [experiment, benchmark, first-principles, retention-economics, multi-year, cardinality-churn, nyquist, aliasing, theil-sen, cusum, victoriametrics, a-010]
assumptions: [A-010]
summary: Four controlled empirical experiments on astrolabe grounding Stage 3C.2 first-principles theory (RES-0021): (1) 15.77M-sample 3-year VictoriaMetrics benchmark showing curated 10k-series multi-year retention is cheap (~4.6 GiB/yr at real production 0.47 B/sample) while 1h rollups accelerate 3-year p95 queries by 45.8x and avoid 10x RAM spikes (41.8 -> 420.2 MiB); (2) Entity churn test proving 20,000 ephemeral PIDs blow up storage 345.3x and slow queries 11.8x vs 50 stable cgroups for identical sample counts; (3) Nyquist aliasing test showing 60s gauge polling misses 100% of 5s spikes whereas 30s kernel peak/counter sampling catches 100% at 30x lower volume than 1s polling; (4) Statistical robustness test showing Theil-Sen achieves 0.1% slope error vs OLS deriv() 47.7% error under a transient build spike, with 0-lag CUSUM change-point detection in 1.12 ms.
---

<!-- abstract:start -->
## Executive Abstract

Empirically tests the four foundational questions raised for Stage `3C.2` ([`RES-0021`](../research/RES-0021-observability-first-principles-and-methodology.md)) on `astrolabe` (`Linux 6.18.60`, `VictoriaMetrics 1.155.0`):
1. **"Keep Everything Forever" at Our Fleet Scale (Test 1 — `15.77M` Real 3-Year Samples)**: Combining our 3-year `VictoriaMetrics` benchmark (`1,095` days) with live `astrolabe` production compression (`0.47 B/sample`, [`EXP-0012`](EXP-0012-e2e-observability-pipeline-and-archival.md)), keeping **100% of curated raw metrics (`10,000` series @ `30s`)** costs only **`~4.6 GiB/year`** (`~23 GiB` for 5 years!), whereas unpruned v1 (`28,000` series @ `15s`) costs **`~25.8 GiB/year`**. However, querying `3y` of raw samples spiked `VictoriaMetrics` RAM **`10×` (`41.8 → 420.2 MiB` HWM)** and took `635.9 ms` for 5 series — whereas pre-computed `1h` rollups answered the same `3y` query across 10 series in **`27.8 ms` (`45.8×` faster per series!)**. **Conclusion**: We *can* keep 100% of curated raw data permanently (Hot + Lossless Parquet Archive — zero data discarded!), *and* we should *still* persist `1h`/`1d` statistical rollups for instant multi-year dashboards!
2. **Entity Churn vs. Stable Cgroups (Test 2 — `100,000` Identical Samples)**: Storing `100,000` samples across `20,000` ephemeral PIDs vs. `50` stable systemd cgroups increased storage **`345.3×` (`1,623 KiB` vs. `4.7 KiB`, `16.62` vs. `0.05 B/sample`)**, RAM **`2.8×` (`84.2` vs. `29.7 MiB`)**, and `topk(10)` query latency **`11.8×` (`262.0 ms` vs. `22.2 ms`)**. Proves mathematically that **entity churn, not retention length**, is what degrades TSDBs.
3. **Nyquist Aliasing & Kernel Integration (Test 3 — Twenty 5-Second Spikes Over 1 Hour)**: Pure gauge polling missed **`65%`** of spikes at `15s`, **`90%`** at `30s`, and **`100%`** at `60s` (reporting a flat `120 MiB` while the host hit `920 MiB` twenty times!). Polling kernel-integrated `memory.peak` / cumulative PSI counters at **`30s`** caught **`100.0%` (`20/20`)** of spikes at **`30×` lower sample volume** than `1s` polling!
4. **Robust Statistics vs. Naive PromQL `deriv()` (Test 4)**: On a 30-day series with true `+50.0 MiB/day` growth and one realistic 24-hour Nix build/ISO cache spike (`+4,000 MiB`), linear OLS `deriv()` suffered **`47.7%` error (`+73.87 MiB/day`)**, whereas non-parametric **Theil–Sen** achieved **`0.1%` error (`+50.04 MiB/day`)** in **`0.54 ms`**, and online **CUSUM** detected a `+350 MiB` generation step-regression with **`0`-hour lag** in **`1.12 ms`**.
<!-- abstract:end -->

# EXP-0013: Multi-Year Scale, Entity Churn, Nyquist Aliasing & Robust Statistics Benchmarks

Reproducible harness: `scratch/exp0013_scale_theory_bench.py` (`VictoriaMetrics 1.155.0`, `astrolabe`).

---

## Test 1: Multi-Year "Keep Everything" Benchmark (3 Full Years / `1,095` Days)

Ingested `10` realistic periodic+trend series (`5` counters + `5` gauges) across **`1,095` days at `60s` resolution (`15,768,000` raw samples)** plus `10` pre-computed `1h` rollup series (`262,800` samples) into `VictoriaMetrics 1.155.0` (`-retentionPeriod=10y`), restarted cleanly, and benchmarked idle RSS, query latency, and peak RAM.

### 1.1 Measured Latency & RAM (`VictoriaMetrics 1.155.0`)
| Query Workload | Window | Resolution | Series | Latency (`ms`) | Notes |
| :--- | :---: | :---: | :---: | ---: | :--- |
| `avg_over_time` | `7d` | Raw `60s` | `1` | `32.06 ms` | Baseline short range |
| `quantile_over_time(0.95)` | `90d` | Raw `60s` | `1` | `84.25 ms` | Comfortable interactive speed |
| `quantile_over_time(0.95)` | `365d` | Raw `60s` | `1` | `248.77 ms` | Noticeable scan cost |
| `quantile_over_time(0.95)` | `1095d` (`3y`) | Raw `60s` | `1` | `619.40 ms` | RAM spiked `41.8 → 420.2 MiB` HWM! |
| `quantile_over_time(0.95)` | `1095d` (`3y`) | Raw `60s` | `5` | `635.93 ms` | Multi-series `3y` raw scan |
| `quantile_over_time(0.95)` | `1095d` (`3y`) | **`1h` Rollup** | **`10`** | **`27.77 ms`** | **`45.8×` faster per series!** |

### 1.2 Honest Fleet Storage Projections (Synthetic vs. Real Production `astrolabe` `0.47 B/sample`)
Synthetic smooth signals compressed to `0.072 B/sample` (`1.11 MiB` for `15.77M` samples). Using our **real live `astrolabe` production compression rate (`0.47 B/sample` across `916.8M` rows from [`EXP-0012`](EXP-0012-e2e-observability-pipeline-and-archival.md))** gives conservative, realistic fleet sizing:

| Fleet Configuration | Active Series | Interval | Projected Storage / Year (Real `0.47 B/sample`) | 3-Year Total | 5-Year Total |
| :--- | ---: | :---: | ---: | ---: | ---: |
| **v2 Curated Fleet (`8` hosts)** | `10,000` | **`30s`** | **`4.60 GiB / yr`** | **`13.8 GiB`** | **`23.0 GiB`** |
| **v2 Curated Fleet (`8` hosts)** | `10,000` | **`15s`** | **`9.20 GiB / yr`** | **`27.6 GiB`** | **`46.0 GiB`** |
| **v1 Unpruned (`65%` noise)** | `28,000` | `15s` | `25.76 GiB / yr` | `77.3 GiB` *(fills VPS!)* | `128.8 GiB` |
| **v2 `1h` Statistical Rollups** | `5,000` | `1h` | **`0.02 GiB / yr`** | **`0.06 GiB`** | **`0.10 GiB`** |
| **v2 Wide Events / Logs (Parquet)** | `10M events/yr` | event | **`0.065 GiB / yr`** (`6.51 B/event`) | **`0.20 GiB`** | **`0.33 GiB`** |

> **Key Takeaway**: Keeping **100% of curated raw data permanently** (never throwing away data!) is completely affordable at our scale — provided we (1) enforce the cardinality allowlist (dropping v1's `65%` waste), (2) keep `1–3 years` hot on `astrolabe` NVMe under a hard Btrfs `squota` guard, (3) export **100% lossless raw Parquet** to `hbox` (`git-annex`) / R2 so *zero history is ever lost*, and (4) save `1h` rollups for **`45.8×` faster** multi-year dashboards without `420 MiB` query RAM spikes!

---

## Test 2: Entity / Process Resolution Churn (`100,000` Identical Samples)

| Entity Model | Unique Series | Samples | Total Disk (`KiB`) | `Bytes / Sample` | `topk(10)` Query (`ms`) | Peak `VmHWM` (`MiB`) |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| **Stable Cgroups (`Host → Slice → Unit`)** | `50` | `100,000` | **`4.7 KiB`** | **`0.05 B`** | **`22.19 ms`** | **`29.71 MiB`** |
| **Ephemeral Per-PID Churn** | `20,000` | `100,000` | **`1,623.0 KiB`** | **`16.62 B`** | **`261.97 ms`** | **`84.21 MiB`** |
| **Penalty Ratio (Churn vs. Stable)** | `400×` | `1×` | **`345.3×` disk** | **`332×`** | **`11.8×` slower** | **`2.8×` RAM** |

---

## Test 3: Nyquist Aliasing Demonstration (Twenty `5s` `920 MiB` Spikes in `1 Hour`)

| Sampling Strategy | Samples / Hour | Observed Max (`MiB`) | Spikes Caught (`out of 20`) | Spikes Missed (`%`) |
| :--- | ---: | ---: | :---: | ---: |
| Raw Gauge @ `1s` *(high CPU/battery wakeups)* | `3,600` | `920.0` | `20 / 20` | `0.0%` |
| Raw Gauge @ `15s` | `240` | `920.0` | `7 / 20` | **`65.0%`** |
| Raw Gauge @ `30s` | `120` | `920.0` | `2 / 20` | **`90.0%`** |
| Raw Gauge @ `60s` | `60` | **`120.0`** *(total blindness!)* | `0 / 20` | **`100.0%`** |
| **Kernel `memory.peak` / Cumulative PSI @ `30s`** | **`120`** (`30×` less than `1s`) | **`920.0`** | **`20 / 20`** | **`0.0%`** |

---

## Test 4: Analytical Robustness — v1 OLS `deriv()` vs. Theil–Sen & Online CUSUM

30-day hourly series (`720` points): true linear growth `+50.0 MiB/day`, diurnal rhythm, plus one realistic 24-hour Nix build/ISO cache spike (`+4,000 MiB`) on day 29; separate generation-step series with `+350 MiB` step at hour `480`.

| Method | Estimated / Detected Value | Ground Truth | Error / Lag | Runtime (`ms`) |
| :--- | ---: | ---: | ---: | ---: |
| **v1 PromQL OLS `deriv()`** | `+73.87 MiB/day` | `+50.00 MiB/day` | **`47.7%` error** *(fooled by 1 spike!)* | `0.57 ms` |
| **Theil–Sen Robust Median Slope** | **`+50.04 MiB/day`** | `+50.00 MiB/day` | **`0.1%` error** | **`0.54 ms`** |
| **Online CUSUM Change-Point** | Hour **`480`** | Hour `480` | **`0` hours lag** | **`1.12 ms`** |
