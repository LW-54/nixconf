---
id: RES-0020
title: Stage 3C.2 Deep Research — Six-Pillar Observability Architecture, Semantic Spacetime (E3) Spine, Tri-Purpose Probes (C7) & Autonomous AI Ops
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: observability
tags: [research, stage-3c2, observability, promise-theory, semantic-spacetime, observability-2-0, wide-events, slo, mwmbr, psi, cgroups-v2, victoriametrics, victorialogs, victoriatraces, perses, grafana, echarts, treemap, vector, fluent-bit, duckdb, parquet, aiops, openrca, mcp, a-010]
assumptions: [A-010]
summary: Comprehensive academic, systems-engineering, v1-audit, and empirical research dossier for Stage 3C.2 (A-010) covering all six observability lifecycle pillars (Collection, Analysis, Presentation, Review, Storage, Archival) grounded in Promise Theory, Semantic Spacetime gamma(3,4), Observability 2.0, Google SRE, InfoVis theory, and live astrolabe experiments EXP-0011 and EXP-0012.
---

<!-- abstract:start -->
## Executive Abstract

Conducts a ground-up, literature-grounded, and empirically benchmarked architectural study ([`EXP-0011`](../experiments/EXP-0011-observability-stack-rss-benchmark.md), [`EXP-0012`](../experiments/EXP-0012-e2e-observability-pipeline-and-archival.md)) of **all six observability lifecycle pillars** — **Collection, Analysis, Presentation, Review, Storage, and Archival** — tailored uniquely to **Antikythera (`aky`)**:
1. **Honoring v1's Genuine Brilliance While Eliminating Its Structural Bloat**: Audits v1's live `1,443–2,403 MiB` stack and 12 dashboards. Preserves and elevates v1's standout innovations — **WizTree & growth-heatmap Storage Atlas treemaps**, **slice/unit Memory Pressure treemaps**, **Declared-vs-Measured Capacity Right-Sizing**, **Incident Time Machine**, **Trends & Cycles**, **CI/Eval/Cache `perf-monitor`**, and **crash-consistent snapshot backups** — while eliminating its root pathologies: `558–811 MiB` Alloy/cAdvisor, **`> 65%` zero-query TSDB cardinality waste**, a fragile 1,100-char journald regex (`systemdOpsParsePipe`), 923 LOC of unlinted JS-in-Nix strings, public ingest endpoints (`vm.adje.app`/`vlogs.adje.app`), 3-way probe duplication, and unbounded `100y` raw NVMe retention.
2. **Collection (Burgess Operational Trust + Gregg USE/PSI + Observability 2.0 Wide Events)**: Combines continuous low-cardinality **USE + Linux cgroups v2 PSI** metrics (`768` series via native cgroups walker vs. `6,166` cAdvisor) with **Observability 2.0 structured wide canonical events** (`VictoriaLogs` at `4.36 B/event`, including native systemd `SD_MESSAGE_UNIT_RESOURCES` fields!) and tail/control-plane **OTLP traces** (`VictoriaTraces`, `17.5 MiB`). `EXP-0012` falsified `vlagent` under `SIGKILL` offline crashes (`500/500` offline events lost) and verified **`100.0%` crash-safe delivery** for both **`COL-FluentNode`** (`44.4 MiB`, `storage.sync full`) and **`COL-Vector`** (`78.2 MiB` single Rust WAL binary).
3. **Analysis (Promise-Derived MWMBR SLOs + Intermittent Envelopes + Deterministic Generation Correlation)**: Derives **Multi-Window Multi-Burn-Rate (MWMBR)** alerts directly from Agent **Tri-Purpose Probes (`C7`)**; introduces **Availability Classes** (`always-on` / `intermittent` / `ephemeral`) to abolish false laptop `InstanceDown` pages; correlates regressions deterministically to signed `P-AkyPull` generations (`g_n -> g_{n+1}`) + `dix` closure diffs; adds `VictoriaLogs` `collapse_nums` Drain-style log novelty mining + offline CUSUM/PELT regime checks; and grounds **AI Ops RCA** in `OpenRCA`/`AIOpsLab`/`FoundRoot` findings (causal-cone programmatic queries over SST + Biscuit-scoped read-only MCP, never raw context stuffing).
4. **Presentation (Shneiderman's Mantra + Squarified Treemaps + Tufte Small Multiples)**: Solves the Perses-vs-Grafana treemap trade-off via **`UI-PersesAtlas`** — pairing **CNCF `Perses 0.54.0` (`89.9 MiB`, 64 built-in plugins incl. `VictoriaLogs`, `Prometheus`, `Jaeger`/`TracingGanttChart`, `HeatMapChart`, `FlameChart`, `StatusHistoryChart`, `PrometheusPromQLAnnotation`)** with a **`0 MiB`-idle static Antikythera Atlas** (clean ECharts Storage & Memory Treemaps + interactive **Semantic Spacetime $\gamma(3,4)$ Fleet Graph** served by Caddy over Tailscale `zone:mesh`), alongside **`UI-Grafana`** (`458 MiB`) and **`UI-PersesPure`** (`90 MiB`) alternatives.
5. **Review, Storage & Open-Format Lakehouse Archival**: Adds an **Automated Weekly Operational Review Digest** (SLO budgets, alert SNR hygiene, capacity/R2 `< \$2/mo` forecast, novel log templates, intermittent fleet health) and blameless post-incident `NEAR` SST loops; replaces `100y` raw NVMe retention with a **3-tier Hot (`VictoriaStack`) / Warm (`vmalert` 5m/1h rollups, `< 150 MiB/yr`, 10-year baselines!) / Cold (`DuckDB 1.5.5` zstd-9 Apache Parquet on `hbox`/`git-annex` + R2 at `6.51 B/event`, `56 ms` zero-daemon SQL)** lifecycle with pre-archival PII/secret redaction!
<!-- abstract:end -->

# RES-0020: Six-Pillar Observability, Semantic Spacetime (`E3`) & AI Ops Dossier

---

## 1. Deep Audit of v1 Monitoring (`modules/contracts/monitoring/` & Live `astrolabe`)

Before designing v2, we inspected v1's complete monitoring contracts, dashboards, resource allocation exporters, and live production telemetry databases on `astrolabe` ([`EXP-0011`](../experiments/EXP-0011-observability-stack-rss-benchmark.md), [`EXP-0012`](../experiments/EXP-0012-e2e-observability-pipeline-and-archival.md)).

### 1.1 What Was Genuinely Excellent in v1 (Must Preserve & Elevate!)
1. **Interactive Squarified Treemaps (`storage-atlas.nix`, `treemap.nix`)**:
   - *Storage Atlas*: `Host → Provider (local / hbox / gdrive / b2) → Slice / Directory Tree` with 3 instant color modes (**Stock-Market Growth/day Heatmap**, **Capacity Pressure %**, **WizTree Category Palette**).
   - *Memory Pressure Treemap (`mkMemoryHeatmapTreemap`)*: Live RAM working-set nested by `Host → Slice → Unit`, colored by pressure against declared `MemoryHigh` / `MemoryMax`!
2. **Declared-vs-Measured Statistical Capacity Right-Sizing (`allocations.nix`, `capacity-analytics.nix`, `trends-explorer.nix`)**:
   - Exporting declarative Nix cgroup budgets (`MemoryHigh`, `MemoryMax`, `CPUQuota`) as static textfile metrics and comparing them side-by-side against rolling `P50 / P95 / Max / StdDev / Burst / Growth/day` and previous-cycle offsets (`-1d`, `-7d`, `-30d`).
3. **Forensic Incident Time Machine (`time-machine.nix`) + Automatic Host Event Annotations (`presets.nix`)**:
   - Scrubbing a master timeline strip (CPU/RAM/PSI + Error Log Bursts) with automatic vertical markers for Reboots, NixOS Deploys, OOM Kills, and Unit Failures.
4. **Build/Eval/Cache Meta-Observability (`perf-monitor.nix`)**:
   - Tracking CI wall/runner times, local Nix eval time/RAM, pre-commit hook duration, cache isolation leaks, and binary cache latency/storage.
5. **Crash-Consistent Snapshot Staging (`server.nix` L545–566)**:
   - Hardlinked VictoriaMetrics (`/snapshot/create`) and VictoriaLogs (`/internal/partition/snapshot/create`) snapshots before Restic backup.

### 1.2 Structural Pathologies & Measured Waste in v1
| Pathology | Empirical Measurement (`EXP-0011` / `EXP-0012`) | Root Cause in v1 |
| :--- | :--- | :--- |
| **Collector RAM Bloat** | `alloy.service`: **`558.0 MiB` current / `810.7 MiB` peak** + `376 MiB` WAL | [`alloy.nix`](../../modules/implementations/grafana/alloy.nix) embeds 5 exporters (`unix`, `cadvisor`, unrestricted `{{.Comm}}` process exporter, `blackbox`, `journal`) in one Go process — OOMs `1–2 GiB` RPi boards |
| **Massive Zero-Query Cardinality** | **`> 65%` (`~18,000+` of `27,744` live series) have `requestsCount = 0`** | Self-scraping `grafana` K8s apiserver (`6,444` series), full `cadvisor` (`6,166` series), unused `caddy` size buckets (`3,246` series), VM `flag` (`831` series) |
| **Fragile Log Regex Parsing** | `1,100`-character `systemdOpsParsePipe` regex in [`presets.nix`](../../modules/contracts/monitoring/dashboard/presets.nix) | `loki.source.journal` stripped systemd's native structured accounting fields (`CPU_USAGE_NSEC`, `MEMORY_PEAK`, `IO_METRIC_READ_BYTES`, `IO_METRIC_WRITE_BYTES`, `MESSAGE_ID`)! |
| **UI Bloat & Unlinted JS-in-Nix** | `grafana.service`: **`458.1 MiB` / `542.2 MiB` peak** + `923` LOC JS inside Nix strings | Needed `volkovlabs-echarts-panel` solely for the 2 treemaps; 12 overlapping dashboards (`~4,500+` LOC Nix JSON builders) |
| **3-Way Probe Duplication** | Probes declared separately in `vmChecks`, `monitoring.probes`, and `monitoring.rules` | No unified Agent Probe primitive (`C7`) |
| **Public Ingest Exposure** | `vm.adje.app` & `vlogs.adje.app` on public internet with static bearer token | Built before `ADR-0012` Tailscale `zone:mesh` |
| **Unbounded Hot NVMe Retention** | Live flags: **`-retentionPeriod=100y`** on BOTH VM and VL | No tiered Warm rollup or Cold Parquet archival lifecycle |
| **Always-On Alerting Assumptions** | Standard `up`/`absent` semantics clash with sleeping laptops | No Availability Class model (`always-on` vs `intermittent` vs `ephemeral`) |
| **No Closed-Loop Review or Traces** | Zero distributed traces; zero automated weekly review digest; zero alert SNR tracking | Write-only dashboards until manual inspection |

---

## 2. Literature Review & Antikythera Synthesis Across All Six Pillars

### Pillar 1: Data Collection — *Promise-Budgeted, Kernel-Native, Observability 2.0 & Crash-Safe Intermittent Edge*

**Foundational Literature:**
- **Mark Burgess — *Operational Trust & Policy for Inattentiveness*** (*Trust and Trustability*; *In Search of Certainty*): Trust is not sentiment; it is an economic policy governing **how closely you must observe an agent**. Constantly polling healthy, high-trust components wastes RAM, NVMe endurance, battery, and cognitive bandwidth. Observability must default to lean, low-cardinality baselines and **dynamically increase resolution only when trust degrades** (*Epistemic Zoom `C5`*).
- **Brendan Gregg — *The USE Method*** (Utilization, Saturation, Errors) & **Johannes Weiner — *Linux PSI (Pressure Stall Information)***: Utilization percentages deceive ("90% CPU" during a `DC-NATS-Pull` encode is desirable headroom utilization!). **cgroups v2 PSI** (`cpu.pressure`, `memory.pressure`, `io.pressure` — `some` and `full` stall microseconds) directly measures real queuing and starvation per workload slice and unit.
- **Charity Majors — *Observability 2.0 & Wide Canonical Events*** (building on Stripe's *Canonical Log Lines*): Traditional 3-pillar monitoring forces engineers to pre-aggregate into rigid low-cardinality metrics at write time. Instead, emit **one rich structured JSON wide event** per logical unit of work (`aky pull` generation transition, `DC-NATS-Pull` job, `restic` backup run, Caddy HTTP request, Tri-Purpose Probe evaluation, systemd unit exit `SD_MESSAGE_UNIT_RESOURCES`) carrying arbitrary high-cardinality attributes (`agent_id`, `host`, `generation_id`, `trace_id`, `duration_ms`, `bytes`, `status`, `exit_code`). Columnar log engines (`VictoriaLogs`, measured at **`4.36 B/event`** in `EXP-0012`) compute arbitrary `p50`/`p95`/`p99` RED metrics on demand in **`35.5 ms`**!
- **OpenTelemetry Adaptive & Tail-Aware Tracing (2024–2026)**: Head-based 1% sampling drops rare errors; full 100% web tracing wastes storage. Antikythera cleanly splits **control-plane / lifecycle spans** (`aky pull`, `niks3`, `restic`, `DC-NATS-Pull`, error spans, P99+ latency outliers → **100% kept**) from routine `200 OK` HTTP spans (**1–5% baseline**), giving full causality inside `VictoriaTraces` (`17.5 MiB` RSS) at minimal disk cost.

**Antikythera-Native Collection Design:**
1. **Strict Cardinality Allowlist**: Drop zero-query self-metrics (`flag`, `grafana_apiserver_*`, unused `caddy_*_size_bytes_bucket`, unbounded `{{.Comm}}` process-exporter). Cuts active series by **`~3×`** immediately.
2. **Native cgroups v2 + PSI Collector (`EXP-0012`)**: Replaces 558 MiB cAdvisor/Alloy with a `< 3 ms` Rust collector inside `aky` (or textfile timer) walking `/sys/fs/cgroup` → **`768` series** (`8.03×` fewer than cAdvisor), exposing `memory.{current,peak,high,max}`, `cpu.stat`, `io.stat`, per-unit CPU/Mem/IO **PSI**, and `oom_kill` events — 100% feeding Memory Treemaps & Capacity Analytics!
3. **Native Structured Journald Ingestion**: Preserves systemd's `CPU_USAGE_NSEC`, `MEMORY_PEAK`, `IO_METRIC_READ_BYTES`, `IO_METRIC_WRITE_BYTES`, `INVOCATION_ID`, `MESSAGE_ID` directly into `VictoriaLogs` — permanently retiring v1's 1,100-char regex!
4. **Private Tailscale `zone:mesh` Push + Crash-Safe Edge Buffering (`EXP-0012`)**:
   - Retires public `vm.adje.app` / `vlogs.adje.app` and static ingest tokens completely (`ADR-0012`).
   - Because laptops sleep, switch Wi-Fi/hotspots, and suffer hard crashes, `EXP-0012` stress-tested shippers under outage + **`SIGKILL`**:
     - **`vlagent` FALSIFIED** (`fastqueue` kept offline batch in RAM and lost `500/500` offline events on `SIGKILL`).
     - **`COL-FluentNode`** (`fluent-bit 5.1.5` w/ `storage.type filesystem` + `storage.sync full` + `storage.checksum on` + `node_exporter 1.12.1`): **`44.4 MiB` total**, **`100.0%` `SIGKILL` recovery (`2.44 s`)**, runs effortlessly on `1 GiB` RPi & Chromebook.
     - **`COL-Vector`** (`vector 0.60.0` single Rust binary w/ transactional WAL `buffer.type = "disk"`): **`78.2 MiB` standalone** (`101.6 MiB` if paired w/ `node_exporter`), **`100.0%` `SIGKILL` recovery (`1.82 s`)**, single declarative TOML/JSON pipeline with native `journald` structured fields, VRL edge PII redaction/enrichment, Prometheus remote-write, VictoriaLogs JSONL, and OTLP forwarding!
     - **`COL-Tiered`** (Hybrid): `COL-Vector` (`78 MiB`) on `astrolabe` + workstations (`≥ 4 GiB` RAM, rich VRL transforms & OTLP) and `COL-FluentNode` (`44 MiB`) only on ultra-constrained `1–2 GiB` boards (`rpi`, `tablet`). *(Trade-off: 2 collector templates to maintain vs. uniform single collector across the fleet.)*
5. **On-Demand / Escalated eBPF Profiling**: Keep `parca-agent` / `perf` flamegraphs strictly **on-demand / escalated** during anomaly investigation (`0 MiB` idle RAM while healthy, consistent with Burgess operational trust).

---

### Pillar 2: Data Analysis — *Promise-Derived SLOs, Intermittent Envelopes, Generation Causality & Causal-Cone AI Ops*

**Foundational Literature:**
- **Google SRE Workbook Ch. 5 — *Multi-Window, Multi-Burn-Rate (MWMBR) SLO Alerting***: Replace noisy cause-based alerts ("CPU > 90%") with **symptom-based Error Budgets** derived directly from Service Level Indicators (SLIs):
  - *Fast burn (Page `ntfy`)*: `14.4×` burn rate across **both `5m` AND `1h`** windows (catches severe outages in minutes without flapping on 30-second blips).
  - *Slow burn (Weekly Review / Ticket, no page)*: `3×` burn rate across **both `6h` AND `3d`** windows (catches chronic silent degradation before budget exhaustion).
- **Intermittent Edge Availability Semantics (Burgess $T_{\text{avail}}$ + MetricsQL `last_over_time`)**: Standard `up == 0` / `absent()` creates intolerable alert fatigue on roaming laptops. In Antikythera, every Host Agent declares an explicit **Availability Class**:
  - `always-on` (`astrolabe`, `rpi`): strict heartbeat + MWMBR paging on outage.
  - `intermittent` (`x240`, `zenbook`, `tuf`, `tablet`): **sleeping/offline is normal, never pages!** Alerts fire on local unit/probe failure *only while awake*, on backup age exceeding policy (`> 7d`), or as a gentle Weekly Review note if unseen for `> 14d`.
  - `ephemeral` (`Live-ISO`, `NixOS-WSL` transient): opt-in diagnostic telemetry only, zero liveness alerts.
- **Statistical Change-Point Detection & Log Template Mining**:
  - **CUSUM** (online cumulative shift detection on PSI `full` and latency) and **PELT** (*Killick et al. 2012*, offline exact linear-time multi-change-point segmentation) detect structural regime shifts without brittle static thresholds.
  - **Drain / Drain3** (*He et al., ICWS 2017*): Fixed-depth parse-tree log template clustering turns raw text logs into template frequency series to spot *novel* error patterns. **Bonus**: `VictoriaLogs` LogsQL natively ships `collapse_nums` + `stats by (_msg)` to cluster log templates directly inside the query engine with zero extra ML daemon!
- **Antikythera's Unique Superpower — Deterministic Generation Causality (`FOLLOWS`)**:
  - Every fleet state change is a signed NixOS generation (`g_n → g_{n+1}`) recorded by `P-AkyPull` (`ADR-0013`) as a `FOLLOWS` edge, a PromQL annotation, and a `generation_id` label/field. Change-point analysis doesn't guess *why* RAM jumped 150 MiB at 03:14 — it deterministically attributes the regime shift to `gen-042 → gen-043` and its exact `dix` closure diff!
- **Tri-Purpose Assessment Probes ($\alpha$, `C7`)**:
  - Each Agent declares its probes **once** (`http_2xx`, `tcp_connect`, `systemd_active`, `command`, plus SLO target e.g. `99.9%`). Antikythera compiles them simultaneously into: (1) QEMU `vm-*` CI tests, (2) `P-AkyPull` post-switch survival rollback gates, and (3) live runtime SLIs + MWMBR alert rules!
- **AIOps & Causal RCA Literature (`OpenRCA` ICLR 2025, `AIOpsLab` MLSys 2025, `FoundRoot` ICSE 2026, *Lag-Aware Causal Inference* FSE 2026)**:
  - **Key Empirical Law from `OpenRCA` (335 real failures, 68 GB telemetry)**: Context-stuffing raw metrics/logs into an LLM fails badly. Accuracy jumps dramatically ONLY when the agent uses **programmatic query tools** guided by an explicit **causal dependency graph**!
  - Antikythera's **Semantic Spacetime $\gamma(3,4)$ Spine (`E3`)** + **Biscuit-attenuated Read-Only Epistemic Zoom (`C5`)** via **`aky mcp`** (+ official `mcp-victoriametrics` / `mcp-victorialogs`) implements this exact architecture natively:
    1. Start coarse (`aky status --json` — ~1 KB: broken promises, degraded agents, active alerts).
    2. Traverse `CONTAINS` (host → slice → service → unit) & `FOLLOWS` (recent `g_n → g_{n+1}` deploys, rollbacks, `dix` diffs) to isolate the causal cone.
    3. Zoom programmatically into bounded PromQL / LogsQL (`collapse_nums`) / VictoriaTraces slices — zero secret reads (enforced by Biscuit capability tokens), zero live production mutation, `0` LLM tokens when healthy!

---

### Pillar 3: Presentation — *Shneiderman's Mantra, Squarified Treemaps, Tufte Small Multiples & Zero-Bloat Aesthetics*

**Foundational Literature:**
- **Ben Shneiderman (1996) — *Visual Information-Seeking Mantra*** (*"Overview first, zoom and filter, then details-on-demand"*): Literally the human visual counterpart of Antikythera's **Semantic Spacetime Epistemic Zoom (`C5`)**.
- **Mark Bruls, Kees Huizing & Jarke J. van Wijk (2000) — *Squarified Treemaps***: Improves Shneiderman's treemaps by bounding rectangle aspect ratios near `1.0` for accurate visual area comparison — proven ideal for **hierarchical storage attribution (WizTree)** and **slice/unit memory attribution** with a second visual channel (hue) encoding **growth rate** or **budget pressure %**!
- **Edward Tufte (*Small Multiples*, Data-Ink Ratio) & Stephen Few (*Information Dashboard Design*)**: Abolish decorative radial gauges and redundant overlapping dashboards; consolidate v1's 12 overlapping dashboards into **6 cohesive, task-driven views** derived declaratively from Agent manifests:
  1. **Fleet Command Overview** *(Overview)*: SLO error budgets, Availability-Class-aware host matrix, firing alerts, R2 `< \$2/mo` cost & GB gauge, backup freshness, latest `P-AkyPull` generations.
  2. **Antikythera Atlas — Interactive Spatial & Topology Views** *(Zoom & Filter)*:
     - *Storage Atlas Squarified Treemap* (`Host → Provider [local / r2 / hbox / gdrive / git-annex] → Service / Dir`, colored by Growth/day, Pressure %, or Category),
     - *Memory & PSI Pressure Treemap* (`Host → Slice → Unit` colored by `% of MemoryHigh/MemoryMax` + PSI stall indicator),
     - *Semantic Spacetime $\gamma(3,4)$ Fleet Graph* (interactive Agent / Promise / Probe / `FOLLOWS` topology with click-to-inspect!).
  3. **Capacity, Right-Sizing & Trends** *(Long-Term Planning)*: Declared `MemoryHigh`/`MemoryMax` vs. `P50/P95/Max/Burst/Growth`, `±1σ` & `-7d/-30d` cycle overlays, time-to-full projections, `niks3`/R2/CI `perf-monitor` metrics.
  4. **Service & Trace Inspector** *(Application Zoom)*: Auto-templated per Antikythera Agent — RED metrics, **Latency Heatmaps** (*Brendan Gregg* — exposing bimodal tails instead of misleading averages!), **Tracing Gantt Charts** (`VictoriaTraces`), and correlated LogsQL table.
  5. **Incident Time Machine** *(Forensic Details-on-Demand)*: Scrubbable master timeline with **Generation Deploy / Reboot / OOM / Rollback annotations**, PSI saturation, error log bursts, and top-unit snapshots.
  6. **Observability & Pipeline Health**: Ingestion rates, cardinality top-N (`requestsCount == 0` detector!), edge buffer depth, hot/warm/cold storage sizes, and Weekly Operational Digest archive.

**Presentation Architecture Trade-Offs (Empirically Verified in `EXP-0012`):**

| Option | Server RAM (`astrolabe`) | Standard Panels + Traces + Logs + Annotations | Squarified Treemaps + SST $\gamma(3,4)$ Graph | Maintenance & Upgrade Ergonomics |
| :--- | ---: | :--- | :--- | :--- |
| **`UI-PersesAtlas`** *(Recommended)* — **CNCF `Perses 0.54.0` + `0 MiB`-idle Static Antikythera Atlas** | **`~90 MiB`** (`5.1×` lighter than Grafana; total stack **`~520–560 MiB`** = **`~2.7×` smaller than v1!**) | **Full 64 built-in plugins**: `Prometheus`, `VictoriaLogs` (logs+metrics+vars), `Jaeger`/`TracingGanttChart`, `HeatMapChart`, `FlameChart`, `StatusHistoryChart`, `AlertManager`, `PrometheusPromQLAnnotation` | **First-class!** Clean, linted static TypeScript/HTML + Apache ECharts Treemaps (Storage + Memory) + **interactive SST $\gamma(3,4)$ Topology Graph** + Weekly Digest viewer served directly by Caddy on `zone:mesh` (**`0 MiB` backend RAM!**), deep-linking straight into Perses! | Pure CNCF GitOps CUE/JSON DaC (`percli dac`); zero Grafana plugin breakage; clean linted static frontend (no JS-in-Nix strings!). Optional future native Perses custom plugin since Perses uses ECharts internally. |
| **`UI-Grafana`** — **`Grafana 13.3.0` + `volkovlabs-echarts-panel`** | **`~458 MiB`** (total stack **`~890–940 MiB`** — still `~520 MiB` lighter than v1 once Alloy is dropped) | Maximum plugin ecosystem, Explore UI, familiar UX | Keeps Storage & Memory Treemaps inside the same UI *(no native SST $\gamma(3,4)$ graph without custom plugin/panel)* | Heaviest single daemon on `astrolabe`; third-party `volkovlabs-echarts-panel` fragility across Grafana major versions; must disable Grafana's `6,444` self-metrics |
| **`UI-PersesPure`** — **CNCF `Perses 0.54.0` + `vmui` only** | **`~90 MiB`** | Full 64 built-in plugins + native `vmui` | **No treemaps / no SST graph** (uses `BarChart`, `Table`, `HeatMapChart`, `StatusHistoryChart`) | Zero custom frontend code to maintain |

---

### Pillar 4: Operational Review — *Closed-Loop SRE Governance & Anti-Fatigue Discipline*

**Foundational Literature** (*Google SRE Workbook*, *Alert Fatigue / SNR Management*, *Blameless Postmortems*):
Observability without a structured review cadence decays into noisy, abandoned dashboards. Antikythera institutionalizes **three distinct signal cadences**:
1. **Immediate Actionable Paging (`ntfy`)**: Strictly symptom-based & urgent (MWMBR fast burn, automatic `P-AkyPull` rollback, R2 approaching `80 GB` / `\$2/mo`, backup stale `> 48h`, NVMe `< 72h` to full). Every alert links directly to its **Incident Time Machine** window and **SST causal cone**.
2. **Automated Weekly Operational Digest** *(Scheduled Sunday evening → archived Markdown + concise `ntfy` summary + Atlas link)*:
   - **Reliability & SLO Burn**: 7d/30d SLO compliance per Agent; `P-AkyPull` deploys & rollbacks.
   - **Alert Signal-to-Noise (SNR) Hygiene**: Counts every alert fired that week, flags flapping or unactionable rules for immediate tuning/removal!
   - **Capacity, Storage & Cost Governance**: Top growing directories/slices, right-sizing deltas (`MemoryHigh` over/under-provisioned), exact **Cloudflare R2 GB & projected monthly USD (`< \$2/mo` guardrail)**, `niks3` cache size/latency, and CI build/eval duration trends (`perf-monitor`).
   - **Novel Log Templates & Regime Shifts**: Top *brand-new* unseen error templates (`VictoriaLogs` `collapse_nums`) + PELT/CUSUM structural shift markers across generations.
   - **Intermittent Fleet Pulse**: Last check-in, backup freshness, and `git-annex` / `DC-NATS-Pull` health across laptops, tablet, and RPi.
3. **Blameless Post-Incident Feedback Loop (`NEAR` SST Links)**: Any significant outage or rollback generates a compact incident record linked via `NEAR` edges to the affected Agent(s) and ADRs, explicitly answering: *"Did observability detect this cleanly? What alert/probe/test closes this blind spot?"*

---

### Pillar 5 & Pillar 6: Storage & Cold Archival — *Hot / Warm / Cold Lakehouse (`VictoriaStack` + Rollups + `Parquet/DuckDB`)*

**Foundational Literature & Empirical Compression (`EXP-0012`):**
- **Pelkonen et al. (VLDB 2015) — *Facebook Gorilla TSDB*** introduced delta-of-delta timestamp + XOR float compression (`1.37 B/sample`). Live `astrolabe` `VictoriaMetrics 1.155.0` beat that by **`3×`** at **`0.47 bytes/sample`** (`916.8M` rows in `431.5 MiB`!).
- **Columnar Log/Event Engines (`VictoriaLogs`) & Open Lakehouse Archival (`Apache Parquet` + `DuckDB`)**: Storing raw logs/traces forever on hot `100 GiB` NVMe (`-retentionPeriod=100y` in v1) creates silent disk exhaustion risk and locks multi-year analytics to one engine. Meanwhile, `VictoriaMetrics` FOSS does *not* include Enterprise automated downsampling (`vmalert` recording rules are FOSS!).

**Three-Tier Storage & Archival Lifecycle (`ST-ObsTiered`):**

| Tier | Engine & Location | Contents | Retention | Empirical Footprint (`EXP-0012`) | Query / Access Path |
| :--- | :--- | :--- | :--- | ---: | :--- |
| **Tier 1: Hot Raw** | `VictoriaMetrics` + `VictoriaLogs` + `VictoriaTraces` on `astrolabe` NVMe (Btrfs `squota` capped + crash-consistent snapshot backup!) | Full-res USE/PSI/SLO metrics (`15–30s`), raw journald & Observability 2.0 wide events, OTLP traces | Metrics: **`180d`**<br>Logs/Events: **`60–90d`** *(+80% disk rail)*<br>Traces: **`30d`** | Metrics: `~2–2.5 GiB`<br>Logs: `~0.5–1.5 GiB`<br>Traces: `~0.2–0.5 GiB`<br>**Total Hot: `< 5 GiB`** | Instant ms queries via Perses, Atlas, `vmui`, `aky mcp` |
| **Tier 2: Warm Rollups & Provenance** | `VictoriaMetrics` (`vmalert` `5m`/`1h` recording rules) + compact SST `FOLLOWS` provenance log on `astrolabe` NVMe (backed up via `ST-UnifiedRestic`!) | Pre-computed `avg`/`p95`/`max`/`growth` per host, slice, storage tree, SLO, CI perf, R2 cost + generation history | **`5–10 years`** *(long-term `capacity-analytics` & `trends-explorer`!)* | **`< 150 MiB / year`** (`< 1.5 GiB` for 10 years!) | Instant multi-year dashboards & capacity forecasting in Perses/Atlas |
| **Tier 3: Cold Open Lakehouse Archive** | **Monthly `DuckDB 1.5.5` zstd-9 Apache Parquet** (`year=YYYY/month=MM/`) on **`hbox` (`git-annex`)** + optional compact audit mirror on **Cloudflare R2** (`\$0` egress!) | **Pre-redacted** expiring raw logs, wide events, traces, and monthly metric snapshots *(sensitive headers/tokens/PII scrubbed BEFORE export!)* | **`3–10 years`** (configurable per signal) | **`6.51 B/event`** (`41.1×` compression — **10M events = `~65 MiB/yr`**, `< \$0.001/mo` on R2!) | Zero-daemon forensic SQL via **`duckdb`** (`56 ms` p99 query!) or `aky query --cold` |

---

## 3. Synthesized Decision Space for Stage `3C.2`

With all six pillars deeply researched and empirically verified (`EXP-0011`, `EXP-0012`), the Stage `3C.2` decisions distill cleanly into **three tightly scoped choices** (presented across 2 crisp forks):

1. **Fork `3C.2-1` — Collection & Presentation Architecture**:
   - **Collector (`100%` `SIGKILL` crash-safe verified in `EXP-0012`)**:
     - **`COL-FluentNode`** (`fluent-bit 5.1.5` `storage.sync full` + `node_exporter 1.12.1` + `aky` cgroups/storage textfiles = **`44.4 MiB`**, uniform across `1 GiB` RPi through `astrolabe`).
     - **`COL-Vector`** (`vector 0.60.0` single Rust WAL binary = **`78.2 MiB`** standalone / `101.6 MiB` w/ `node_exporter`, unified native `journald` + VRL redaction + OTLP + remote-write).
     - **`COL-Hybrid`** (`Vector` on `≥ 4 GiB` hosts + `FluentNode` on `1–2 GiB` boards).
   - **Presentation UI**:
     - **`UI-PersesAtlas`** *(Recommended)*: **CNCF `Perses 0.54.0` (`~90 MiB`)** + **`0 MiB`-idle static Antikythera Atlas** (Storage & Memory ECharts Squarified Treemaps + interactive **Semantic Spacetime $\gamma(3,4)$ Fleet Graph** + Weekly Digest viewer served over Tailscale `zone:mesh`).
     - **`UI-Grafana`** (`Grafana 13.3.0`, `~458 MiB` — keeps everything in one familiar app, still `~520 MiB` lighter than v1 once Alloy is dropped).
     - **`UI-PersesPure`** (`Perses 0.54.0` + `vmui` only, `~90 MiB` — zero custom frontend code, drops treemaps).
2. **Fork `3C.2-2` — Operational Review, Cold Archival & Autonomous AI Ops Tier (`QA-10`)**:
   - **Storage/Archival**: Confirm the **3-tier Hot (`180d`/`90d`/`30d`) / Warm (`5–10y` `vmalert` rollups) / Cold (`DuckDB` zstd-9 Parquet on `hbox`/R2 w/ redaction)** lifecycle vs. simpler Hot+Warm only (no Parquet cold archive).
   - **Review & AI Ops Escalation**:
     - **`AI-EscalatedPR`** *(Recommended)*: Automated Weekly Operational Digest + Alert SNR audit + causal-cone RCA via Biscuit-scoped read-only MCP → `ntfy` briefing + **Draft PRs via `aky-agent[bot]`** (`Perm-AgentApp`, human reviews & merges; `0` tokens idle).
     - **`AI-BriefOnly`**: Same Weekly Digest + causal-cone RCA briefings to `ntfy` / Atlas, never opens automated PRs.
     - **`AI-ManualOnDemand`**: Interactive `aky mcp` + VM/VL MCP tools only; deterministic non-LLM Weekly Digest script only.
