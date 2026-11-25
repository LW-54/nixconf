---
id: RES-0021
title: First-Principles Foundations of Observability — Measurement Theory, Resolution & Aliasing, Statistical & Causal Analysis, Dashboard Methodology, and "Keep-Everything" Retention Economics
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: observability
tags: [research, first-principles, measurement-theory, control-theory, nyquist, aliasing, signal-processing, mergeable-summaries, ddsketch, statistics, theil-sen, cusum, pelt, stl, burgess, gqm, endsley, cleveland-mcgill, shneiderman, tufte, retention-economics, a-010]
assumptions: [A-010]
summary: Ground-up theoretical & methodological foundation for Antikythera observability answering six foundational questions before finalizing tools: (1) What should we monitor and why (Kalman observability, Ashby Requisite Variety, GQM, Promise Theory, Little's Law & USL), (2) What governs sampling & process/entity resolution (Nyquist-Shannon aliasing, counters vs gauges vs kernel peaks vs events, observer effect, IndexDB churn vs cgroups v2), (3) When and how to save pre-computed statistics (Agarwal mergeable summaries, DDSketch/HDR histograms, avoiding the averaging-percentiles fallacy), (4) Empirically benchmarking "keep everything forever" vs tiered archival at our fleet scale (EXP-0013), (5) A formal cognitive/InfoVis methodology for dashboards (GQM -> Endsley SA -> Shneiderman Mantra -> Cleveland & McGill -> Few/Tufte -> generative SST views), and (6) A stratified taxonomy of analytical methods separating deterministic math, robust statistics, causal graphs, and where AI/LLMs genuinely add value vs where they do not.
---

<!-- abstract:start -->
## Executive Abstract

Establishes the **first-principles mathematical, statistical, cognitive, and economic foundations** for observability in Antikythera (`aky`), independent of specific vendor tools, backed by live empirical proof in [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md):
1. **What to Monitor & Why (Control Theory + GQM + Promise Theory)**: Derives telemetry strictly from **Kalman Observability** (minimum linearly independent outputs to reconstruct internal state), **Ashby's Law of Requisite Variety** (diagnostic variety must match failure modes), **Basili's GQM** (Goal → Question → Metric), **Little's Law ($L = \lambda W$) / Gunther's USL**, and **Burgess Promise Theory**, partitioning all measurement into **4 irreducible epistemic purposes** (*Fault Detection*, *Forensic Attribution*, *Capacity/Economics*, *Exploratory Discovery/Repurposing*).
2. **Sampling & Process Resolution (Signal Processing + Cardinality Physics)**: Applies **Nyquist–Shannon ($f_s \ge 2 f_{\max}$)** to prove why instantaneous **gauges alias** short spikes while **monotonic counters**, **kernel high-water marks (`memory.peak`, `PSI`)**, and **event-driven wide logs** do *not*! Proves empirically in [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md) that **entity churn** (per-PID polling), *not* long retention, is what explodes TSDB indexes (`IndexDB`), establishing **`Host → Slice → Unit` (`cgroups v2`) + exit wide-events + adaptive eBPF zoom** as the mathematically optimal resolution hierarchy.
3. **Pre-Computed Statistics & Mergeable Algebra**: Applies **Agarwal et al. (PODS 2012)** (*Mergeable Summaries*), **DDSketch (VLDB 2019)**, **t-digest**, and **Gil Tene's HDR Histograms / Coordinated Omission** to separate safely pre-aggregatable monoids (`sum`, `count`, `min`, `max`, `sum_sq`, exponential histograms) from **non-mergeable quantiles** (never average p95s!). Shows when saving rollups is mathematically essential (instant multi-year dashboards & seasonal baselines) even when raw data is retained!
4. **Retention Economics ("Keep Everything" Tested Empirically!)**: Evaluates the user's core hypothesis — *at an 8-host personal fleet scale, is keeping 100% of raw telemetry forever actually costly?* — using [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md) multi-year benchmarks (`15.77M` real 3-year samples) to distinguish **lossless permanent retention** (keeping 100% of curated raw data across hot NVMe + lossless cold Parquet on `hbox`/R2 so *nothing* is ever thrown away and *any* future hypothesis can be tested!) from **unbounded hot NVMe sprawl**.
5. **Methodological Dashboard Engineering**: Replaces ad-hoc dashboard piles with a 5-stage engineering pipeline: **GQM** (*why*) → **Endsley Situation Awareness** (*Perception / Comprehension / Projection*) → **Shneiderman Mantra** (*Overview → Zoom & Filter → Details-on-Demand*) → **Cleveland & McGill Perceptual Hierarchy** (Position > Length > Area > Hue; justifying small multiples over gauges and Squarified Treemaps specifically for hierarchical part-to-whole + growth hue) → **Generative Agent-Driven Views** compiled from Antikythera manifests.
6. **Stratified Analysis Taxonomy (Math → Statistics → Causal Graphs → LLMs)**: Proves why classical non-parametric statistics (**Theil–Sen** beating v1's OLS `deriv()` by orders of magnitude under transient spikes, **CUSUM/PELT/BOCPD** change-point detection, **Burgess 2D weekly baselines / STL**, **Drain / `collapse_nums`** log novelty) + **Antikythera's deterministic generation DAG (`FOLLOWS`)** handle 95% of analysis deterministically in milliseconds — reserving AI/LLMs strictly for **semantic last-mile synthesis, ad-hoc NL-to-SQL/PromQL hypothesis translation, and PR drafting** when genuinely useful.
<!-- abstract:end -->

# RES-0021: First-Principles Foundations of Observability

---

## 1. What Should We Even Try to Monitor — And Why?

Most monitoring stacks fail because they are built **bottom-up from available exporters** ("turn on cAdvisor, node_exporter, process_exporter, Grafana self-metrics, see what shows up"). That guarantees `65%+` zero-query noise (as measured live on `astrolabe` in [`EXP-0012`](../experiments/EXP-0012-e2e-observability-pipeline-and-archival.md)) while still leaving blind spots during real failures.

Five classical theories answer **"what to monitor, and why"** from first principles:

### 1.1 Five Governing Theoretical Laws
1. **Kalman Observability (Control Theory, Kalman 1960)**: A dynamical system is *observable* iff its internal state vector $x(t)$ can be uniquely reconstructed from a finite history of external outputs $y(t)$. **Corollary**: Do not collect 12 redundant proxies for the same internal state variable (e.g., 14 cAdvisor memory counters); collect the **minimal linearly independent basis** that reconstructs every failure state (utilization + **saturation/queuing** + error counters + lifecycle transitions).
2. **Ashby's Law of Requisite Variety (Cybernetics, Ashby 1956)**: *"Only variety can absorb variety."* A monitoring/diagnostic system must have at least as many diagnostic degrees of freedom as the operational failure modes it governs. **Corollary**: Rigid 4-metric dashboards (CPU/RAM/Disk/Up) fail on novel failures — you need **high-dimensional structured events** (*Observability 2.0*) to match unknown-unknown variety!
3. **Basili's Goal–Question–Metric (GQM, 1994)**: Every single collected signal MUST trace upward to an explicit **Goal → Operational Question → Metric/Event**. If a metric answers zero questions (or has `requestsCount = 0` for 90 days), it is ungrounded waste unless explicitly earmarked for exploratory archival.
4. **Promise Theory & Operational Trust (Burgess)**: Every Agent publishes external promises $\Pi_{\text{ext}}$ ("Vaultwarden responds HTTP 200 in `< 500ms`", "Restic backs up to R2 every 24h", "R2 bill stays `< \$2/mo`"). Primary monitoring assesses **whether promises are kept**; secondary monitoring diagnoses *why* a promise broke; trust governs sampling attentiveness.
5. **Queueing Theory — Little's Law ($L = \lambda W$) & Gunther's Universal Scalability Law (USL)**: Performance collapses non-linearly at the "knee of the curve" where contention ($\alpha$) and coherency crosstalk ($\beta$) cause queuing delay ($W$) to explode. Measuring **Throughput ($\lambda$)**, **Latency ($W$)**, **Concurrency ($L$)**, and **Kernel Saturation (`PSI` stall time)** lets you detect the knee *before* total collapse.

### 1.2 The Four Irreducible Epistemic Purposes (Taxonomy of What to Measure)

Every single signal in Antikythera maps to one of **four distinct epistemic layers**, each with radically different cardinality, resolution, and retention physics:

| Layer | Core Question | What to Measure (Minimal Basis) | Signal Form |
| :--- | :--- | :--- | :--- |
| **L1. Promise Verification (External / Symptom)** | *Is every user-facing & system promise currently kept?* | **Tri-Purpose Probes ($\alpha$)**: HTTP/TCP/systemd/command checks, RED (Rate, Errors, Duration **histograms**), Backup recency & restore-drill status, `P-AkyPull` generation convergence & rollback count, R2 exact GB & USD budget, TLS cert expiry, Btrfs scrub/SMART disk health. | Low-cardinality counters, exponential histograms, discrete probe events |
| **L2. Physical & Kernel Saturation (Internal / USE + PSI)** | *Which physical/cgroup bottleneck is starving or approaching a cliff?* | **CPU/Mem/IO/Net USE** + **Linux cgroups v2 per-slice & per-unit** (`memory.current`, `memory.peak`, `memory.high/max`, `cpu.stat`, `io.stat`, **`{cpu,memory,io}.pressure` PSI**, `oom_kill`) + **Thermal/Battery/AC/Wi-Fi metered state** (for laptops & lid-closed compute!) + **Storage Tree attribution** (`du` / Btrfs `squota` / R2 / `hbox` / `git-annex`). | Stable-label gauges + monotonic counters + periodic scans |
| **L3. Causal Provenance & Wide Events (Observability 2.0)** | *Exactly WHAT ran, WHEN, on WHICH generation, and WHAT happened?* | **One rich structured JSON wide event** per discrete lifecycle unit: `P-AkyPull` deploy/rollback (w/ `generation_id` + `dix` summary), `systemd` unit exit (`SD_MESSAGE_UNIT_RESOURCES`: `CPU_USAGE_NSEC`, `MEMORY_PEAK`, `IO_*`), `restic` snapshot, `DC-NATS-Pull` job, `niks3` cache op, Caddy HTTP access, SSH/Auth events — plus **OTLP traces** linking multi-step control-plane & error paths! | High-dimensional JSON wide events (`VictoriaLogs`) + OTLP spans (`VictoriaTraces`) |
| **L4. Meta-Telemetry & Exploratory Context** | *How fast/clean is our own engineering & fleet, and what patterns emerge over years?* | CI wall/runner times, local Nix eval latency/RAM, cache-isolation leaks (`perf-monitor`), TSDB cardinality/zero-query audit, Alert SNR counts, laptop lid/uptime/battery-health degradation over years, bandwidth/hotspot usage, personal workload rhythms. | Compact wide events + slow gauges (ideal for multi-year repurposing!) |

---

## 2. What Governs Sampling Resolution & Process/Entity Resolution?

### 2.1 Signal Processing: Nyquist–Shannon, Aliasing & Metric Algebraic Types

The **Nyquist–Shannon Sampling Theorem** ($f_s \ge 2 f_{\max}$) states that sampling a continuous signal slower than twice its highest frequency causes **aliasing** — fast spikes vanish completely or impersonate slow drift. Crucially, aliasing behaves **completely differently** across the four signal types:

1. **Instantaneous Gauges (`memory.current`, `temperature`, `runqueue`, `battery_%`) — VULNERABLE TO ALIASING!**
   - Polling a gauge every `60s` completely misses `5s–20s` memory spikes or thermal bursts (`EXP-0013` empirically proves `60s` polling misses **`~90%`** of `5s` spikes!).
   - **The Right Fix is NOT `1s` polling** (which multiplies storage `60×`, causes CPU wakeups ruining laptop C6/C10 deep sleep battery life — the *Observer Effect* — and burns NVMe writes!).
   - **The Right Fix is Kernel-Side Integration**: Read **high-water marks & kernel accumulators** (`memory.peak`, `memory.events[high|max|oom_kill]`, **PSI `total` microseconds**, `thermal_throttle_count`) every `15s–30s`! A `5s` spike between `30s` scrapes leaves an **exact, un-aliased footprint** in `memory.peak` and `memory.pressure` (`EXP-0013`: **`0.0%` spikes missed at `30s`!**).
2. **Monotonic Cumulative Counters (`cpu_seconds_total`, `io_bytes_total`, `psi_stalled_seconds_total`, `http_requests_total`) — ZERO TOTAL-ENERGY LOSS!**
   - Because counters integrate all activity continuously in the kernel/app between scrapes, sampling at `15s–30s` loses **zero** total CPU time, bytes, or errors. The scrape interval *only* controls the minimum temporal width of a rate spike you can localize (`rate([2×scrape])`).
3. **Latency Distributions & Coordinated Omission (Gil Tene, *HDR Histogram*)**:
   - Never sample latency as a periodic gauge or average — record every request/probe in **exponential / HDR histograms** (`DDSketch` / Prometheus native histograms / OTel exponential histograms) OR as exact `duration_ms` fields on **Observability 2.0 wide events**, ensuring probes run on an **independent fixed schedule** (never waiting for the previous stalled probe to finish — preventing *Coordinated Omission*!).
4. **Discrete Event Streams (Journald, Wide Events, OTLP Spans) — ZERO SAMPLING ALIASING!**
   - Event-driven capture records exact kernel/application timestamps down to the microsecond, regardless of how brief the event is (`0.1 ms` or `10 hours`), with **zero idle polling cost** when nothing is happening!

**Resulting Resolution Policy (Derived from Physics, Not Guesswork):**
- **Continuous Host/Cgroup Counters & Kernel Peaks/PSI**: **`15s` on `astrolabe`** (always-on AC server), **`30s` on AC laptops / `rpi`**, **`60s` on battery laptops** (preserving CPU C-states & battery life — still `0%` missed total energy/stalls thanks to counters + kernel peaks!).
- **Tri-Purpose Probes ($\alpha$)**: **`30s–60s`** independent scheduled probes (fast enough to fire a `5m` MWMBR burn alert cleanly).
- **Slow Physical State (Storage `du` directory tree, R2/hbox budgets, SMART, battery wear, Nix store GC)**: **`15m–6h`** (disk trees don't oscillate at 1 Hz; scanning every 15s would thrash NVMe I/O!).
- **Discrete Events & Control-Plane Traces**: **Event-driven (`100%` immediate capture)** with exact microsecond timestamps.
- **High-Frequency Diagnostic Zoom (`1s` metrics / eBPF `perf` / `parca-agent` 19–99 Hz stack sampling)**: **Strictly on-demand / anomaly-triggered** (Burgess adaptive attentiveness: `0%` observer overhead when healthy, sub-second zoom when diagnosing!).

### 2.2 Process & Entity Resolution: Why Per-PID Polling Fails & Cgroups v2 Wins

Consider the **Spatial Entity Granularity Ladder**:
$$\text{Fleet} \supset \text{Host} \supset \text{Cgroup Slice (Tier)} \supset \text{Systemd Unit / Agent} \supset \text{Process Group} \supset \text{PID / Thread} \supset \text{Stack Frame / Syscall}$$

Why did v1's unrestricted `{{.Comm}}` process-exporter bloat Alloy and why is continuous per-PID scraping theoretically unsound?
1. **Short-Lived Process Aliasing**: Nix builds, compilers (`cc1plus`, `rustc`), git hooks, and shell pipelines spawn thousands of processes lasting `50 ms–2 s`. A `15s` scraper misses most of them completely while catching random snapshots of others.
2. **TSDB Index Explosion (`IndexDB` Churn)**: In `EXP-0013`, ingesting the **exact same `100,000` samples** across `20,000` ephemeral PIDs vs. `50` stable cgroups multiplied `IndexDB` size and query latency dramatically! **Entity churn, NOT time-series duration, is the true enemy of TSDB scalability.**
3. **The Optimal Multi-Resolution Entity Stack**:
   - **Continuous TSDB Layer → `Host → Slice → Systemd Unit` (`cgroups v2`)**: Stable, bounded entity set (`~50–100` cgroups/host), **100% child-process inclusive** (even a `5 ms` forked child process's CPU, RAM, and I/O are accounted by the Linux kernel into its parent unit's cgroup!), zero `IndexDB` churn!
   - **Discrete Event Layer → Per-Invocation Exit Accounting (`SD_MESSAGE_UNIT_RESOURCES` + `aky` job wide events)**: Every transient oneshot service, timer, backup, or batch job automatically emits one exact wide event upon completion with exact `CPU_USAGE_NSEC`, `MEMORY_PEAK`, `IO_METRIC_*`, `EXIT_STATUS` — zero polling, zero missed short jobs!
   - **On-Demand Deep Layer → Per-PID & Stack Frames (`btop`, `bpftrace`, `perf`, `parca-agent`)**: Engaged *only* during interactive inspection or automated anomaly escalation when a unit's PSI or memory breaches its envelope!

---

## 3. Should We Run & Save Pre-Computed Calculations and Statistics?

### 3.1 The Mathematics of Mergeable Summaries (Agarwal et al., PODS 2012)

Before deciding what statistics to save, you must obey one iron mathematical law:
- **Mergeable Monoids (Safe to Pre-Compute & Re-Aggregate Across Arbitrary Windows)**:
  - `count`, `sum`, `min`, `max`, `sum_of_squares` (enabling exact pooled mean & variance via Chan/Welford's parallel algorithm!), **Exponential / Native Histograms**, **`DDSketch`** (*Masson et al., VLDB 2019* — bounded relative error $(1\pm\epsilon)x$!), and **`t-digest`** (*Dunning*)!
- **Non-Mergeable Statistics (NEVER Average Across Rollup Buckets!)**:
  - `median`, `p95`, `p99`, `distinct_count`. Averaging 24 hourly `p95` latencies does **NOT** equal the daily `p95` (it can be off by `10×` on bursty workloads!).
  - **Rule**: Either compute `p95`/`p99` directly from raw data/wide events/Parquet, OR save **mergeable exponential histogram buckets / DDSketch summaries** (or label saved `1h` `p95` explicitly as *"hourly-window P95 envelope"*, never re-averaging it as a global P95!).

### 3.2 Three Concrete Reasons to Save Derived Statistics *Even If You Keep Raw Data*

Even if we keep **100% of raw data** (Section 4), pre-computing and persisting compact derived summaries pays massive dividends for three distinct reasons:
1. **Interactive Multi-Year Query Speed (`EXP-0013` Proved!)**: Scanning 3 years of raw high-res samples across 20 series in a live dashboard takes seconds and spikes VM page cache; querying a pre-computed `1h` rollup takes **single-digit milliseconds (`~30–100×` faster!)** while keeping raw data intact underneath for drill-down!
2. **Materialized Baselines & Seasonal Envelopes**: Computing **Burgess 2D periodic baselines** (`(day_of_week, hour_of_day)` exponentially weighted mean & variance), **STL trend/seasonal/residual decompositions**, **Theil–Sen growth slopes**, and **SLO error-budget burn series** once per hour/day turns complex statistical models into cheap, inspectable, versioned time series you can plot and compare across years!
3. **Immutable Historical Ground Truth Across Schema/Config Changes**: Saving daily/generation snapshots of **declared allocations (`MemoryHigh`, R2 budget, closure size, `dix` diff)** alongside measured `min/p50/p95/max` preserves exact apples-to-apples historical context even after you rename a service or resize a slice two years later!

---

## 4. "Keep Everything Forever?" — Retention Economics at Our Scale (`EXP-0013`)

Enterprise observability advice ("drop raw metrics at 30d, drop logs at 14d") assumes **10,000 Kubernetes nodes emitting 50 million active series**. **We are an 8-host personal fleet!**

So we tested the user's exact hypothesis empirically in [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md) (ingesting **`15.77 MILLION` real 3-year samples** into `VictoriaMetrics`, measuring exact disk, `IndexDB`, RAM, and 3-year query latencies, combined with live `astrolabe` `0.47 B/sample` and `EXP-0012`'s `4.36 B/event` / `6.51 B/event` Parquet numbers).

### The Verdict: **YES — At Our Scale, We Can Keep 100% of Curated Raw Data PERMANENTLY (Zero Data Thrown Away!), While Separating Hot NVMe Speed from Infinite Cold Lossless Storage!**

*(Exact measured figures from `EXP-0013` are recorded directly in [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md) — key economic insight:)*
- **The bottleneck is NOT keeping 100% of curated raw data** (`~2–5 GiB/yr` for an entire 8-host fleet of curated metrics + `~0.1–0.5 GiB/yr` for wide events/logs in Parquet!).
- **The ONLY two real hazards of naive `-retentionPeriod=100y` on a single `100 GiB` VPS NVMe are**:
  1. **Unpruned High-Churn Cardinality** (like v1's `65%` zero-query noise or per-PID labels) bloating `IndexDB` RAM & disk.
  2. **Unbounded Log/Trace Floods** (e.g., a misconfigured debug loop or DDoS emitting 50 GiB of raw HTTP logs in a weekend) filling `astrolabe`'s `100 GiB` NVMe if there is no disk quota / archival tier!
- **Therefore, the Mathematically & Economically Ideal "Keep Everything Forever" Architecture (`ARC-LosslessKeepAll`)**:
  - **Hot Live TSDB (`VictoriaMetrics` on `astrolabe`)**: Keep **100% of curated raw metrics for `3–5 years` (or `10y` under a generous Btrfs `squota`, e.g., `15–20 GiB`)** + `1h` pre-computed rollups (`< 150 MiB/yr`) for instant multi-year dashboard rendering! Because curated stable entities barely grow `IndexDB`, keeping years of raw metrics hot costs almost nothing!
  - **Hot Live Logs/Wide Events & Traces (`VictoriaLogs` + `VictoriaTraces` on `astrolabe`)**: Keep **`1 year` (logs/wide events)** and **`90d–180d` (traces)** hot on NVMe (guarded by `-retention.maxDiskUsagePercent=80` + Btrfs `squota` so a log storm can never crash `astrolabe`!).
  - **Permanent Lossless Open Archive (`100%` of Raw Metrics + Logs + Wide Events + Traces → `DuckDB` zstd-9 Apache Parquet on `hbox` / `git-annex` + R2)**: Monthly lossless export means **ZERO DATA IS EVER DELETED** — every raw byte from years ago remains queryable at any future date in `~56 ms` with `DuckDB` SQL, Python/Polars, or an AI agent to test *any* new hypothesis or repurpose your data years later!

---

## 5. A Formal Methodological Approach to Dashboards

Stop designing dashboards by dragging panels onto a canvas. Treat dashboards as **human-computer cognitive instruments** engineered through a strict **5-Step Methodology**:

1. **Step 1 — Basili GQM Contract**: Every dashboard begins with a 1-sentence **Mission** and **3–5 explicit Questions** it answers. Any panel not answering one of those questions is deleted.
2. **Step 2 — Endsley Situation Awareness Layout (Top → Bottom Cognitive Flow)**:
   - **Top Strip — Level 1 (*Perception*)**: Immediate pre-attentive status ("Are all promises green? Which host/service is burning error budget?"). Small, scannable stat/badge strip.
   - **Middle Zone — Level 2 (*Comprehension*)**: Contextual distributions, correlated timelines, **Generation Deploy / OOM annotations**, **Squarified Treemaps** (spatial/hierarchical breakdown), and **Tufte Small Multiples** (aligned axes across hosts/slices so the eye compares patterns instantaneously!).
   - **Bottom / Drill-Down Zone — Level 3 (*Projection & Forensics*)**: Robust **Theil–Sen** capacity exhaustion projections, declared-vs-measured right-sizing tables, exact LogsQL error streams, and `VictoriaTraces` Gantt waterfall!
3. **Step 3 — Shneiderman's Visual Information-Seeking Mantra (= Epistemic Zoom `C5`)**:
   - Strict 3-level hierarchy — **never a flat soup of 12 overlapping dashboards**:
     - **Depth 0 (Overview)**: *Fleet Command Center* (1 page to rule them all).
     - **Depth 1 (Zoom & Filter)**: *Spatial & Topology Atlases* (Storage/Memory Treemaps + SST Graph), *Capacity & Right-Sizing*, *Host & Hardware*.
     - **Depth 2 (Details-on-Demand)**: *Service & Trace Inspector*, *Incident Time Machine*, *Raw Explore (`vmui` / `LogsExplorer` / `DuckDB` SQL)*.
4. **Step 4 — Cleveland & McGill (1984) + Few (2006) + Gregg Perceptual Encoding Rules**:
   - **Position on aligned axes** (Line charts, Dot plots, Small multiples) for precise trend & cross-host comparison.
   - **Aligned Bar Length** for ranked top-N comparisons (never Pie charts or decorative radial Speedometer gauges!).
   - **Latency Heatmaps & Quantile Bands** (never hide bimodal tails behind a single average line!).
   - **Squarified Treemaps (Bruls et al. 2000)** *specifically* for hierarchical part-to-whole budgets (Storage & Memory), where **area** = magnitude and **diverging hue** = secondary rate/pressure (growth/day or `% of MemoryHigh`)!
   - **Semantic Color Discipline**: Neutral cool slate for normal state; reserve amber/red **strictly** for broken promises, PSI stalls, or rapid growth — never rainbow palettes!
5. **Step 5 — Generative Schema-Driven Dashboards (Antikythera Advantage!)**:
   - Never hand-author bespoke dashboard JSON per service. `aky` compiles standard views directly from the formal **Agent / Promise / Probe / Budget** manifests into declarative Perses CUE/JSON (and optional Atlas JSON), guaranteeing every new service automatically gets SLOs, probes, annotations, and drill-down links on day one!

---

## 6. Stratified Analysis Taxonomy: Deterministic Math vs. Classical Statistics vs. Causal Graphs vs. AI

**Core Design Principle**: *Always use the simplest, most mathematically exact, lowest-cost analytical method that solves the problem. Never use a probabilistic LLM to do arithmetic, anomaly thresholding, or trend estimation!*

| Tier | Analytical Methods (Theoretical Basis) | Concrete Antikythera Use Cases | Execution Cost & Determinism |
| :--- | :--- | :--- | :--- |
| **Tier 1: Exact Deterministic & Relational** | Promise evaluation ($\alpha$), Google SRE **MWMBR** error budgets, **Declared-vs-Measured** budget algebra, **Generation Diff** (`metric(g_{n+1}) - metric(g_n)` + `dix` closure diff), TSDB `requestsCount == 0` audit | Real-time SLO paging; `P-AkyPull` automatic rollback; R2 `80 GB / \$2` guardrails; spotting unused noisy metrics; exact diff of RAM/closure size per NixOS deploy | `< 5 ms`, **100% deterministic**, `0` ML/LLM |
| **Tier 2: Robust Non-Parametric & Time-Series Statistics** | **Median/MAD & Quantiles** (heavy-tailed latencies); **Theil–Sen slope + Mann–Kendall test** (outlier-resistant trend — beats v1 OLS `deriv()` dramatically in `EXP-0013`!); **Burgess 2D Weekly Baselines** & **STL Decomposition** (*Cleveland 1990*); **CUSUM** (*Page 1954*) & **PELT** (*Killick 2012*) / **BOCPD** (*Adams & MacKay 2007*) change-point detection; **Lag-aware cross-correlation** | Silent memory-leak detection; accurate disk/R2 exhaustion dates immune to temporary build spikes; separating normal Sunday backups from true anomalies; automatic timestamping of subtle behavioral regressions across generations; weekly digest statistical engine | `< 50 ms` batch / streaming, **100% deterministic & mathematically explainable**, `0` LLM |
| **Tier 3: Unsupervised Structural & Text Mining** | **Drain / Drain3** (*He et al., ICWS 2017*) via `VictoriaLogs` `collapse_nums`; **Log-Odds / Contrastive Frequency** (incident window vs. healthy baseline); **Queueing knee / Little's Law** checks | Automatic **"Brand-New Error Templates"** section in Weekly Digest & Incident Time Machine ("this exact error pattern appeared `47×` after `gen-043` and `0×` in the prior 30 days!") | `< 100 ms` inside `VictoriaLogs`, **deterministic**, `0` LLM |
| **Tier 4: Causal Graph & Topology Collapse** | **Burgess Semantic Spacetime $\gamma(3,4)$** (`CONTAINS`, `EXPRESSES`, `FOLLOWS`, `NEAR`) + **Pearl Structural Causal DAG** root-cause collapse | Suppress cascading alert storms (if `astrolabe` ingress drops, collapse 12 failing service probes into 1 root node); automatically isolate the minimal **causal cone** of units, dependencies, and recent commits before any human or AI ever looks! | `< 5 ms` in `aky`, **100% deterministic**, `0` LLM |
| **Tier 5: Semantic AI / LLM ("Last Mile" ONLY)** | *OpenRCA* (ICLR 2025) / *AIOpsLab* (MLSys 2025) **programmatic tool-use over pre-localized causal cones** via Biscuit-scoped read-only **`aky mcp` + VM/VL MCP + DuckDB** | **ONLY 3 high-value semantic tasks where math alone stops:**<br>1. **Semantic Root-Cause Explanation**: Reading a pre-localized Tier 1–4 incident packet (`PELT` shift + `gen-043` `dix` diff + top 3 novel Drain templates + Nix module source) and explaining *in plain English* why the code change broke it.<br>2. **Exploratory Hypothesis Translation**: Turning natural-language ad-hoc questions (*"Did kernel 6.18 increase idle battery drain on `x240`?"*) into exact PromQL/LogsQL/`DuckDB` queries over your full multi-year lossless archive!<br>3. **Optional Draft PR Synthesis**: Opening a CI-tested Draft PR via `aky-agent[bot]` (`ADR-0013`) when a clear declarative fix exists (strictly human-reviewed, `0` tokens when healthy). | Invoked **only on real anomaly or explicit user query**; **`0` tokens steady-state** |
