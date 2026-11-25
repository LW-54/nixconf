---
id: ADR-0015
title: Stage 3C.2 — Six-Pillar Bounded-RAM Observability, Semantic Spacetime (E3) Spine, Lossless Parquet Archival & Stratified AI Ops
type: adr
status: accepted
created: 2026-11-25
updated: 2026-11-25
domain: observability
tags: [adr, stage-3c2, observability, victoriametrics, victorialogs, victoriatraces, perses, fluent-bit, node-exporter, cgroups-v2, psi, duckdb, parquet, sst, probes, slo, mwmbr, theil-sen, cusum, mcp, aiops, a-010]
assumptions: [A-010]
supersedes: []
summary: Ratifies Stage 3C.2 (falsifying v1 Alloy+Grafana Pareto assumption A-010): COL-FluentNode crash-safe edge collection (44.4 MiB) + native cgroups v2/PSI & structured journald + VictoriaStack 3-signal backend (VM+VL+VictoriaTraces) over private Tailscale zone:mesh + UI-PersesPure (Perses 0.54.0, ~90 MiB, 5-step GQM/Endsley/Shneiderman/Cleveland-McGill generative dashboards) + ARC-LosslessKeepAll (1-3y hot + 1h rollups + 100% lossless pre-redacted DuckDB zstd-9 Parquet on hbox/git-annex + compact R2 mirror) + Tri-Purpose Probes (C7) -> MWMBR SLOs + Availability Classes + Stratified Tiers 1-4 deterministic analysis + Tier 5 read-only Biscuit MCP & AI-EscalatedPR strictly for semantic last-mile value.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3C.2`** (**Observability, Semantic Spacetime `E3` Epistemic Spine, Tri-Purpose Probes `C7`, & Autonomous AI Ops**) for **Antikythera (`aky`, `LW-54/antikythera`)**, grounded in [`RES-0020`](../research/RES-0020-observability-sst-spine-and-ai-ops.md), [`RES-0021`](../research/RES-0021-observability-first-principles-and-methodology.md), and three live empirical experiments on `astrolabe` ([`EXP-0011`](../experiments/EXP-0011-observability-stack-rss-benchmark.md), [`EXP-0012`](../experiments/EXP-0012-e2e-observability-pipeline-and-archival.md), [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md)):
1. **Assumption `A-010` Empirically Falsified & Replaced**: Live measurements proved v1's `Alloy + Grafana` stack (`1,443 MiB` steady / `2,403 MiB` peak for 2 signals, `> 65%` zero-query series) was *not* on the Pareto frontier. v2 delivers **3 full signals (Metrics + Logs/Wide Events + Distributed Traces)** at **`~525–580 MiB` steady on `astrolabe` (`~2.6×` smaller)** and **`44.4 MiB` on edge hosts (`12.6×` lighter than Alloy — effortless on `1 GiB` RPi!)**.
2. **Collection (`COL-FluentNode` + Kernel-Native + Observability 2.0)**: Replaces `Alloy`/cAdvisor/process-exporter with **`fluent-bit 5.1.5`** (`storage.type filesystem`, `storage.sync full`, `storage.checksum on`, SQLite journal `DB` cursor — verified `100.0%` `SIGKILL`-safe in `EXP-0012`) + **`node_exporter 1.12.1`** + native **Linux cgroups v2 + PSI** collector (`768` vs. `6,166` cAdvisor series, `0 MiB` daemon) + native structured journald (`SD_MESSAGE_UNIT_RESOURCES`, deleting v1's 1,100-char regex) + **Observability 2.0 wide JSON events** + cardinality allowlist + battery-adaptive sampling (`15s` VPS / `30s` AC / `60s` battery), shipped privately over **Tailscale `zone:mesh`** (`ADR-0012`, zero public ingest endpoints or bearer tokens).
3. **Storage & Lossless Archival (`VictoriaStack` + `ARC-LosslessKeepAll`)**: `VictoriaMetrics 1.155` + `VictoriaLogs 1.53` + **`VictoriaTraces 0.12` (`17.5 MiB`)** — all native NixOS modules! Keeps **100% of curated raw data permanently**: `1–3y` hot metrics (`~4.6 GiB/yr` @ `30s` at measured `0.47 B/sample`) + `1y` hot logs + `90–180d` hot traces on `astrolabe` NVMe under Btrfs `squota` & `-retention.maxDiskUsagePercent=80`, **plus** `1h`/`1d` mergeable `vmalert` rollups (`< 20 MiB/yr`, **`45.8×` faster** 3-year queries!), **plus** monthly **pre-redacted 100% lossless `DuckDB 1.5.5` zstd-9 Apache Parquet** archival (`6.51 B/event`, `56 ms` cold SQL) on **`hbox` (`git-annex`)** + compact R2 mirror (`< \$0.01/mo`).
4. **Presentation (`UI-PersesPure`)**: **CNCF `Perses 0.54.0`** (`~90 MiB` RSS, 64 built-in plugins verified live in `EXP-0012`: `Prometheus`, `VictoriaLogs`, `Jaeger`/`TracingGanttChart`, `HeatMapChart`, `FlameChart`, `StatusHistoryChart`, `AlertManager`, `PrometheusPromQLAnnotation`) + native `vmui`, engineered via the 5-step **GQM → Endsley SA → Shneiderman Mantra → Cleveland & McGill → Generative Agent-Driven Dashboard** methodology (retaining a clean future extension path for a native Perses ECharts Treemap plugin since Perses renders on Apache ECharts internally).
5. **Analysis, Review & Stratified AI Ops (`E3` + `C7` + `Tiers 1–4` + `AI-EscalatedPR`)**: **Tri-Purpose Probes ($\alpha$, `C7`)** compile once into QEMU VM tests, `P-AkyPull` rollback gates, and Google SRE **MWMBR SLO** alerts; **Availability Classes** (`always-on` / `intermittent` / `ephemeral`) eliminate false laptop pages; **Tiers 1–4 deterministic math & statistics** (**Theil–Sen `0.1%` error** vs. v1 OLS `47.7%`, **CUSUM/PELT** change-points, **Burgess 2D weekly / STL** baselines, `VictoriaLogs` `collapse_nums` novel templates, SST $\gamma(3,4)$ causal collapse, and Weekly Operational Digest w/ Alert SNR hygiene) handle 95% of analysis with `0` LLM cost — while **Tier 5 AI (`aky mcp` + VM/VL MCP + DuckDB, Biscuit-scoped read-only, `0` tokens idle)** activates strictly for semantic last-mile RCA, ad-hoc NL-to-SQL/PromQL archive exploration, and optional CI-gated Draft PRs via `aky-agent[bot]` (`ADR-0013`).
<!-- abstract:end -->

# ADR-0015: Stage 3C.2 — Observability, Semantic Spacetime (`E3`) Spine, Lossless Archival & AI Ops

## 1. Context & Problem Statement

In v1, monitoring was the heaviest workload on `astrolabe` (`1,443.4 MiB` steady / `2,403.1 MiB` peak across 7 units — `5×` heavier than all user-facing services combined), while covering only 2 signals (Metrics + Logs, zero Traces), exposing public ingest endpoints (`vm.adje.app`, `vlogs.adje.app`) with static bearer tokens, duplicating probes 3 ways, setting unbounded `-retentionPeriod=100y` on raw NVMe databases, and failing to accommodate `1–2 GiB` Raspberry Pis or sleeping laptops.

At the same time, v1 pioneered valuable ideas — declared-vs-measured capacity right-sizing (`allocations.nix`, `capacity-analytics`), point-in-time forensic reconstruction (`time-machine`), CI/eval meta-observability (`perf-monitor`), and crash-consistent snapshot backups — and our target architecture (**Antikythera**) introduces decisive structural advantages: a formal Semantic Spacetime $\gamma(3,4)$ graph (`ADR-0005`), deterministic signed `P-AkyPull` generations (`ADR-0013`), Tailscale `zone:mesh` (`ADR-0012`), Biscuit capabilities (`ADR-0011`), Cloudflare R2 + `hbox`/`git-annex` (`ADR-0014`), and `aky-agent[bot]` Draft PRs (`ADR-0013`).

To avoid tool-first bias, we conducted a two-tier investigation:
- **Systems & Live Pipeline Benchmarks**: [`RES-0020`](../research/RES-0020-observability-sst-spine-and-ai-ops.md), [`EXP-0011`](../experiments/EXP-0011-observability-stack-rss-benchmark.md), and [`EXP-0012`](../experiments/EXP-0012-e2e-observability-pipeline-and-archival.md).
- **First-Principles Measurement, Signal Processing, Statistical, InfoVis & Retention Economics**: [`RES-0021`](../research/RES-0021-observability-first-principles-and-methodology.md) and [`EXP-0013`](../experiments/EXP-0013-keep-everything-scale-and-aliasing.md).

---

## 2. Ratified Decisions (Six-Pillar Architecture)

### 2.1 Pillar 1 — Collection: `COL-FluentNode` + Kernel-Native Accounting + Observability 2.0 Wide Events
- **Uniform Crash-Safe Edge Stack (`44.4 MiB` total — `12.6×` lighter than Alloy)**:
  - **`services.fluent-bit`** (`fluent-bit 5.1.5`, `21.0 MiB` RSS) with mandatory crash-safe disk spooling (`storage.type filesystem`, `storage.sync full`, `storage.checksum on`, bounded `storage.total_limit_size` — `256M` on `1–2 GiB` boards, `1G` on laptops/VPS) and persistent SQLite journal cursor (`DB /var/lib/fluent-bit/journal.db`, declared in `[state.*]` for `ADR-0010` impermanence!). Empirically verified at **`100.0%` delivery after backend outage + `SIGKILL`** (`EXP-0012`), whereas `vlagent`'s in-RAM `fastqueue` was **falsified** (lost `500/500` offline events on `SIGKILL`).
  - **`services.prometheus.exporters.node`** (`node_exporter 1.12.1`, `23.5 MiB` RSS) with textfile directory (`/var/lib/aky/metrics-textfile`) for slow/declarative exports (`allocations.prom`, storage tree scan, R2/hbox budgets, `P-AkyPull` generation state, backup age).
  - **Native Linux cgroups v2 + PSI Collector (`0 MiB` daemon, `< 3 ms` in Rust)**: Walks `/sys/fs/cgroup` across all `.slice` and managed `.service` units emitting `memory.{current,peak,high,max}`, `cpu.stat`, `io.stat`, per-unit `{cpu,memory,io}.pressure` **PSI**, and `oom_kill` counters (`768` series vs. `6,166` cAdvisor = **`8.03×` lower cardinality**, completely retiring cAdvisor and unrestricted `{{.Comm}}` process-exporter!).
  - **Native Structured Journald & Observability 2.0 Wide Events**: Fluent Bit's `systemd` input preserves native kernel/systemd fields (`CPU_USAGE_NSEC`, `MEMORY_PEAK`, `IO_METRIC_READ_BYTES`, `IO_METRIC_WRITE_BYTES`, `INVOCATION_ID`, `MESSAGE_ID=ae8f7b866b0347b9af31fe1c80b127c0`), permanently retiring v1's 1,100-char `systemdOpsParsePipe` regex. Antikythera daemons (`aky pull`, `aky worker`, `restic`, Caddy, Probes) emit **one rich structured JSON wide event** per discrete lifecycle transition to `VictoriaLogs` (`/insert/jsonline?_stream_fields=host,agent_id,event_kind&_msg_field=_msg`) and **100% control-plane / error OTLP traces** (plus `1–5%` routine `200 OK` baseline) to `VictoriaTraces`.
  - **Physics-Derived Adaptive Sampling Resolution (`EXP-0013` Test 3)**: `15s` on `astrolabe` (AC server), `30s` on AC laptops / `rpi`, `60s` on battery laptops (preserving CPU C6/C10 sleep while catching `100%` of spikes via counters + `memory.peak`/PSI!), `15m–6h` for disk tree/SMART/R2 scans, event-driven for discrete transitions, and `1s`/eBPF (`parca-agent`/`perf`) strictly **on-demand / escalated** (`0 MiB` idle).
  - **Strict Cardinality Allowlist**: Drops zero-query self-metrics (`flag`, unused `caddy_*_size_bytes_bucket`, ephemeral per-PID labels), cutting active TSDB series by **`~3×`** and preventing the **`345.3×` entity-churn disk explosion** proved in `EXP-0013` Test 2.
  - **Private Tailscale `zone:mesh` Transport (`ADR-0012`)**: Retires public `vm.adje.app` / `vlogs.adje.app` and `telemetry-ingest-token` completely. Tailscale `policy.hujson` grants `tag:fleet` write-only access to `astrolabe`'s ingest ports over WireGuard, and `role:human-root` access to Perses/query UIs.

### 2.2 Pillar 2 & Pillar 3 — Storage & Lossless Permanent Archival: `VictoriaStack` + `ARC-LosslessKeepAll`
All three core storage engines use **native pinned NixOS modules** (`services.victoriametrics`, `services.victorialogs`, `services.victoriatraces`):
- **Hot Raw Tier (`astrolabe` NVMe, Btrfs `squota` + `-retention.maxDiskUsagePercent=80` safety rails)**:
  - **`VictoriaMetrics 1.155.0`** (`~180–233 MiB` RSS): **`1–3 years`** of 100% curated raw metrics (`~4.6 GiB/yr` for 10k series @ `30s` at measured `0.47 B/sample`).
  - **`VictoriaLogs 1.53.0`** (`~97 MiB` RSS): **`1 year`** of raw journald & Observability 2.0 wide events (`4.36 B/event` compressed!).
  - **`VictoriaTraces 0.12.0`** (`17.5 MiB` RSS): **`90–180 days`** of OTLP spans (serving Jaeger HTTP Query API `/select/jaeger/api/...` natively to Perses!).
  - Retains v1's crash-consistent hardlinked snapshot hooks (`/snapshot/create`, `/internal/partition/snapshot/create`) integrated into `ADR-0014` `ST-UnifiedRestic`.
- **Warm Materialized Rollup Tier (`astrolabe` NVMe, `5–10 years`, `< 150 MiB/yr`)**:
  - `vmalert` (`services.vmalert`) computes **`1h` / `1d` mergeable summaries** (`sum`, `count`, `min`, `max`, `sum_sq`, exponential histograms — obeying **Agarwal et al. PODS 2012** and never re-averaging quantiles!) plus daily snapshots of declared budgets (`MemoryHigh`, R2 quota), SLO error-budget burn, and `P-AkyPull` generation transitions.
  - Delivers **`45.8×` faster multi-year dashboard queries (`27.8 ms` vs. `635.9 ms`)** and avoids `420+ MiB` raw-scan RAM spikes (`EXP-0013` Test 1).
- **Cold 100% Lossless Open Lakehouse Archive (`hbox` / `git-annex` + Compact R2 Mirror)**:
  - A monthly low-priority `systemd` timer (or `DC-NATS-Pull` job) exports raw metrics, logs/wide events, and traces **after deterministic PII/secret redaction** into **Hive-partitioned `DuckDB 1.5.5` zstd-9 Apache Parquet** (`telemetry/signal={metrics,logs,traces}/year=YYYY/month=MM/`, measured at **`6.51 B/event`, `41.1×` compression**).
  - **Primary Cold Store**: **`hbox` (`100+ GB` `git-annex` / SFTP)** — **ZERO curated raw data is ever deleted**, enabling arbitrary post-hoc mining and repurposing years later via `duckdb` / `aky query --cold` (`56.0 ms` p99 SQL, **`0 MiB` idle daemon**!).
  - **Compact Cloud Mirror**: Wide events, rollups, and incident/audit Parquet (`~65–200 MiB/yr`, `< \$0.003/mo`, `\$0` egress!) mirrored to Cloudflare R2 well inside `ADR-0014`'s `< \$2/mo` envelope.

### 2.3 Pillar 4 — Presentation: `UI-PersesPure` + Five-Step Cognitive Dashboard Methodology
- **Visualization Stack**: **`services.perses`** (**CNCF `Perses 0.54.0`**, **`89.9 MiB` RSS** — `5.1×` lighter than Grafana's `458–542 MiB`, 64 built-in plugins verified live in `EXP-0012` including `Prometheus`, `VictoriaLogs` [logs + timeseries + variables], `Jaeger`/`TracingGanttChart`, `HeatMapChart`, `FlameChart`, `StatusHistoryChart`, `AlertManager`, `PrometheusPromQLAnnotation`) + built-in `vmui` for raw ad-hoc exploration, served exclusively over Tailscale `zone:mesh` (`ADR-0012`).
- **Zero Custom Frontend Maintenance Today, Clean Extension Path Tomorrow**: `UI-PersesPure` ships zero custom HTML/JS/React code (retiring v1's 923 LOC JS-in-Nix strings!). Because Perses renders on Apache ECharts internally and loads plugins via `DefaultArchivePluginPath`, a native Perses ECharts Treemap or SST Graph plugin remains a clean, additive Phase 4+ enhancement without changing any storage, schema, or dashboard pipeline!
- **Strict 5-Step Dashboard Engineering Methodology (`RES-0021` §5)**:
  1. **Basili GQM Contract**: Every dashboard states 1 mission + 3–5 questions.
  2. **Endsley Situation Awareness Flow**: Top = Level 1 *Perception* (status strip), Middle = Level 2 *Comprehension* (aligned timelines w/ Generation/Reboot/OOM annotations & Tufte small multiples), Bottom = Level 3 *Projection & Forensics* (Theil–Sen forecasts, LogsQL, Trace Gantt).
  3. **Shneiderman Mantra Hierarchy (`C5` Epistemic Zoom)**: Consolidates v1's 12 overlapping dashboards into **6 cohesive views** across 3 zoom depths (`Fleet Command` → `Capacity/Right-Sizing & perf-monitor` + `Host & Storage` → `Service & Trace Inspector`, `Incident Time Machine`, `Pipeline & Cardinality Health`).
  4. **Cleveland & McGill + Gregg Perceptual Encoding**: Aligned lines/bars/small multiples & **Latency Heatmaps** (no pie charts, no decorative radial gauges, semantic color discipline).
  5. **Generative Agent-Driven Compilation**: `aky` compiles Perses CUE/JSON dashboards (`percli dac`) directly from Agent/Promise/Probe/Budget manifests.

### 2.4 Pillar 5 & Pillar 6 — Analysis, Operational Review, Semantic Spacetime (`E3`), Tri-Purpose Probes (`C7`) & Stratified AI Ops
- **Tri-Purpose Assessment Probes ($\alpha$, `C7`)**: Declared **once** per Agent (`http_2xx`, `tcp_connect`, `systemd_active`, `command`, plus SLO target), compiling uniformly into: (1) QEMU `vm-*` CI tests, (2) `P-AkyPull` post-switch survival rollback gates (`ADR-0013`), and (3) live Google SRE **Multi-Window Multi-Burn-Rate (MWMBR)** SLO alert rules (`14.4×` `5m`&`1h` fast-burn page → `ntfy`; `3×` `6h`&`3d` slow-burn → Weekly Digest).
- **Intermittent Fleet Availability Classes**: Every Host Agent declares `availability = "always-on" | "intermittent" | "ephemeral"`:
  - `always-on` (`astrolabe`, `rpi`): strict heartbeat + MWMBR paging.
  - `intermittent` (laptops/tablet): sleeping/offline **never pages**; monitors local health only while awake, tracks backup recency independently of uptime, and flags `last_seen > 14d` gently in the Weekly Digest.
  - `ephemeral` (`Live-ISO`, transient `WSL`): telemetry push disabled by default (opt-in RAM-only buffer if enabled), zero liveness alerts.
- **Zero-Daemon `E3` Semantic Spacetime Spine**: Static `CONTAINS`/`EXPRESSES`/`NEAR` graph compiled by `aky` in `2.4 ms` (`0 MiB` daemon); dynamic `FOLLOWS` provenance (`g_n → g_{n+1}`, rollbacks, `dix` closure summaries, batch runs) appended to `VictoriaLogs` + `/var/lib/aky/sst-events.jsonl`.
- **Stratified 5-Tier Analytical Engine (`RES-0021` §6 — Non-AI First!)**:
  - **Tier 1 (Deterministic Math)**: MWMBR error budgets, declared-vs-measured budget ratios, deterministic generation diffs (`metric(g_{n+1}) - metric(g_n)` + `dix`), `perf-monitor` migrated from Attic/B2 to **`niks3` + Cloudflare R2 `< \$2/mo`**, and zero-query cardinality audit (`requestsCount == 0`).
  - **Tier 2 (Classical Robust Statistics)**: **Theil–Sen robust slope + Mann–Kendall** (`0.1%` error vs. v1 OLS `47.7%` error under transient build spikes in `EXP-0013`!), **CUSUM / PELT / BOCPD** change-point detection (`0`-lag in `1.12 ms`), and **Burgess 2D `(day_of_week, hour)` / STL** seasonal baselines — computed by a lightweight deterministic `aky` timer writing summary metrics & digest sections.
  - **Tier 3 (Structural Log Mining)**: Drain-style template clustering via native `VictoriaLogs` `collapse_nums` + contrastive log-odds highlighting **newly appeared error templates**.
  - **Tier 4 (Causal Graph Collapse)**: SST $\gamma(3,4)$ DAG collapses cascading downstream probe failures into the single upstream root node before alerting or diagnosis.
  - **Tier 5 (AI / LLM — `AI-EscalatedPR`, Strictly Semantic Last-Mile Only)**:
    - **`0` LLM tokens / `0 MiB` idle** when the fleet is healthy.
    - All telemetry/graph access is strictly **read-only** via **Biscuit-attenuated capability tokens (`ADR-0011`, `C5`)** over **`aky mcp` + `mcp-victoriametrics` + `mcp-victorialogs` + `DuckDB`** (zero secret reads, zero direct prod mutation!).
    - Invoked *only* for 3 genuinely semantic tasks: (1) summarizing a pre-localized Tier 1–4 incident packet (linking `PELT` shift + `gen` `dix` diff + novel log templates + Nix source) into an `ntfy` RCA briefing, (2) interactive natural-language → PromQL/LogsQL/`DuckDB` exploration over the multi-year lossless archive, and (3) opening a **CI-tested Draft PR via `aky-agent[bot]` (`ADR-0013` `Perm-AgentApp`)** *only when a clear declarative fix exists* (human reviews & merges!).
- **Closed-Loop Operational Review**:
  1. Strict symptom-only `ntfy` paging (`< 2/mo` target).
  2. **Automated Weekly Operational Digest** (deterministic Tier 1–4 report archived as Markdown + `ntfy` summary: SLO burn, **Alert SNR / noisy-rule audit**, Theil–Sen capacity & right-sizing deltas, **R2 GB & `< \$2/mo` cost forecast**, `niks3`/CI `perf-monitor`, novel log templates, intermittent fleet check-in).
  3. Blameless post-incident notes linked via `NEAR` SST edges validating observability coverage.

---

## 3. Cross-ADR Hardening Invariants (Compliance Audit Against `ADR-0002`..`ADR-0014`)

1. **Impermanence & Bounded Edge Buffers (`ADR-0010`)**: `/var/lib/fluent-bit` (SQLite journal `DB` + fsync disk queue) declared in `[state.*]` on impermanent hosts, with strict `storage.total_limit_size` caps (`256M` edge / `1G` laptops).
2. **Substrate Polymorphism (`ADR-0010`)**: `Live-ISO` defaults to telemetry push off (`ephemeral`); `NixOS-WSL` gracefully omits SMART/thermal/bare-metal hardware collectors without conditionals in core agents.
3. **Edge & Pre-Archival Redaction (`ADR-0011`)**: `fluent-bit` strips `Authorization`, `Cookie`, `Set-Cookie`, `X-Api-Key`, `token=`, `password=` at ingestion; monthly Parquet archival runs a second deterministic scrub pass before writing to `hbox` / R2.
4. **Tailscale Zero-Public-Exposure (`ADR-0012`)**: All ingest (`VM`/`VL`/`VT`) and UI (`Perses`/`vmui`/`Alertmanager`) endpoints bind strictly to loopback / Tailscale `zone:mesh` `*.ts.net` Caddy vhosts with Tailscale ACL tag enforcement.
5. **Cloudflare R2 `< \$2/mo` Budget Integrity (`ADR-0014`)**: Full lossless Parquet archive targets `hbox` (`git-annex`) as primary cold store; only compact wide-event/rollup Parquet (`< 200 MiB/yr`, `< \$0.003/mo`) mirrors to R2; `perf-monitor` tracks exact R2 GB & projected monthly USD.
6. **Verified `astrolabe` RAM Envelope (`A-010`)**: Total steady `astrolabe` observability RSS across all 3 signals + alerting + UI is **`~525–580 MiB`** (`fluent-bit` `21` + `node_exporter` `23.5` + `VM` `~180–233` + `VL` `~97` + `VT` `17.5` + `Perses` `89.9` + `vmalert×2` `60.1` + `alertmanager` `37.7`) — **`~860–920 MiB` steady (`~1.5+ GiB` peak) lighter than v1** while adding Traces, PSI, and Lossless Archival!

---

## 4. Consequences & Trade-Offs

- **Benefits**: `~2.6×` lower VPS RAM, `12.6×` lower edge RAM (`44.4 MiB` runs cleanly on `1 GiB` RPi), `~3×` lower TSDB cardinality, `100.0%` crash-safe intermittent edge buffering, 3 full telemetry signals + 100% lossless multi-year Parquet archive for future repurposing, `45.8×` faster multi-year queries via rollups, mathematically sound non-AI statistical engine (`Theil–Sen` / `CUSUM` / `collapse_nums` / `MWMBR`), zero public telemetry attack surface, and zero LLM spend when healthy.
- **Trade-Offs Accepted**:
  - `UI-PersesPure` defers interactive Storage/Memory Squarified Treemaps (using Perses `BarChart`/`Table`/`HeatMapChart`/`StatusHistoryChart` first); reversible later by adding a native Perses ECharts Treemap plugin without altering any storage or query layer.
  - Fluent Bit + `node_exporter` is two small units (`44.4 MiB`) rather than one binary (`Vector` `78–102 MiB`), trading single-binary VRL elegance for `2×` lower edge RAM on `1–2 GiB` boards.
  - Maintaining `vmalert` `1h` rollup rules (because VictoriaMetrics FOSS omits Enterprise auto-downsampling) is small and declarative since rules are generated from Agent manifests.

---

## 5. Verification Gates (Phase 4)
1. **QEMU VM End-to-End Test (`vm-astrolabe-obs`)**: Boots `fluent-bit`, `node_exporter`, `aky` cgroups collector, `victoriametrics`, `victorialogs`, `victoriatraces`, `vmalert`, `alertmanager`, and `perses`; verifies OTLP span → Jaeger API, structured `SD_MESSAGE_UNIT_RESOURCES` ingestion, `storage.sync full` crash recovery, and zero public WAN port exposure.
2. **Pre-Archival Redaction & Cold DuckDB Round-Trip Test**: Injects synthetic bearer tokens into test logs, runs the Parquet archival timer, asserts `0` leaked tokens in Parquet, and executes a `DuckDB` `quantile_cont(0.99)` query cleanly.
3. **Biscuit Read-Only MCP Audit**: Verifies `aky mcp` rejects any mutation or secret-path query under its read-only Biscuit token.
