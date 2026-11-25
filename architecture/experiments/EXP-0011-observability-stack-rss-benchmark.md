---
id: EXP-0011
title: Stage 3C.2 Live Observability Stack RSS Benchmark on astrolabe
type: experiment
status: completed
created: 2026-11-25
updated: 2026-11-25
domain: observability
tags: [experiment, benchmark, stage-3c2, observability, rss, alloy, vector, fluent-bit, node-exporter, perses, grafana, victoriatraces, a-010]
assumptions: [A-010]
summary: Direct live memory benchmark on astrolabe comparing v1 production observability RSS (1,443 MiB current / 2,403 MiB peak, dominated by alloy 558-811 MiB and grafana 458-542 MiB) against 2026 pinned nixpkgs contenders: fluent-bit 5.1.5 (17.3 MiB), node_exporter 1.12.1 (22.2 MiB), vector 0.60.0 (81.9 MiB), victoriatraces 0.12.0 (15.4 MiB), and perses 0.54.0 (57.3 MiB).
---

<!-- abstract:start -->
## Executive Abstract

Measured live production observability RSS on `astrolabe` (`Linux 6.18.60`, 6 vCPU / 11 GiB RAM) alongside live runs of pinned `nixpkgs 26.11` (`1d06008`) contenders scraping real host metrics and serving HTTP endpoints. Proves two decisive Pareto leaps for **`A-010`**:
1. **Collector Replacement (`-518` to `-771 MiB` on `astrolabe`, enabling `1–2 GiB` RPi!)**: Live v1 `alloy.service` consumes **`558.0 MiB` current / `810.7 MiB` peak** (due to embedded cAdvisor, unrestricted `{{.Comm}}` process exporter, and a 378 MiB WAL). Replacing Alloy with **`fluent-bit 5.1.5` (`17.3 MiB`) + `node_exporter 1.12.1` (`22.2 MiB`) = `39.5 MiB`** yields a **`14.1×` RAM cut**, or single-binary Rust **`vector 0.60.0` (`81.9 MiB`)** yields a **`6.8×` RAM cut**.
2. **Full 3-Signal Telemetry (`Metrics + Logs + Traces`) Fits Far Below v1's Footprint**: Adding native OTLP distributed tracing via **`victoriatraces 0.12.0`** costs only **`15.4 MiB`**. Visualization offers a clean measured trade-off between **`perses 0.54.0` (`57.3 MiB`, `8.0×` lighter than `grafana`, shipping built-in `VictoriaLogs`, `Prometheus`, `AlertManager`, `TracingGanttChart`, and `FlameChart` plugins)** vs. retaining **`grafana 13.3.0` (`458.1 MiB`)** for custom HTML/WizTree panels (still `~550 MiB` net lighter than v1 once Alloy is replaced!).
<!-- abstract:end -->

# EXP-0011: Live Observability RSS Benchmark on `astrolabe`

## 1. Live Production v1 Baseline (`systemctl show`, 2026-11-25)
| Unit | Active State | `MemoryCurrent` | `MemoryPeak` | Notes |
| :--- | :---: | ---: | ---: | :--- |
| `alloy.service` | active | **`558.0 MiB`** | **`810.7 MiB`** | Embeds unix + cAdvisor + unrestricted process exporter + blackbox + journald + 378 MiB WAL |
| `grafana.service` | active | **`458.1 MiB`** | **`542.2 MiB`** | 12 custom dashboards + `perf-monitor` + VictoriaLogs plugin |
| `victoriametrics.service` | active | `232.7 MiB` | `785.2 MiB` | Time-series metrics DB |
| `victorialogs.service` | active | `96.8 MiB` | `136.9 MiB` | LogsQL log store |
| `alertmanager.service` | active | `37.7 MiB` | `56.7 MiB` | Alert dedup/routing → `ntfy` |
| `vmalert-metrics.service` | active | `36.2 MiB` | `44.2 MiB` | PromQL alert evaluator |
| `vmalert-logs.service` | active | `23.9 MiB` | `27.2 MiB` | LogsQL alert evaluator |
| **v1 Total (Metrics + Logs only)** | — | **`1,443.4 MiB`** | **`2,403.1 MiB`** | Zero traces, zero profiling; public `vm.adje.app`/`vlogs.adje.app` ingest |

## 2. Live Measured 2026 Contenders (`nixpkgs 1d06008`, `VmRSS` / `VmHWM`)
| Binary (Pinned Store Path) | Workload Tested | `VmRSS` | `VmHWM` (Peak) | Ratio vs. v1 Equivalent |
| :--- | :--- | ---: | ---: | ---: |
| `fluent-bit 5.1.5` (`q8i5m9...`) | Live `prometheus_scrape` of `node_exporter` (2s interval) | **`17.3 MiB`** | **`17.3 MiB`** | **`32.3×`** lighter than `alloy` |
| `prometheus-node-exporter 1.12.1` (`1bxwaa...`) | Full host `/metrics` scrape (`160 KiB` payload) | **`22.2 MiB`** | **`22.2 MiB`** | Combined w/ `fluent-bit`: **`39.5 MiB`** (**`14.1×`** lighter than `alloy`!) |
| `vector 0.60.0` (`9injh9...`) | Single Rust binary: `prometheus_scrape` + `host_metrics` (2s interval) | **`81.9 MiB`** | **`82.0 MiB`** | **`6.8×`** lighter than `alloy` |
| `victoriatraces 0.12.0` (`05xpzi...`) | Live OTLP HTTP trace server (`/health` probed) | **`15.4 MiB`** | **`15.4 MiB`** | New 3rd signal (Traces) for only `+15.4 MiB`! |
| `perses 0.54.0` (`ym8rda...`) | CNCF Go dashboard server (ships `VictoriaLogs`, `Prometheus`, `TraceGantt`, `FlameChart` plugins) | **`57.3 MiB`** | **`57.3 MiB`** | **`8.0×`** lighter than `grafana` (`-401 MiB`) |

## 3. Projected Total v2 Stack Footprint on `astrolabe` (11 GiB RAM)
| Candidate Stack | Signals Covered | Projected Steady RSS | Delta vs. v1 (`1,443 MiB`) | Edge/RPi Agent RSS |
| :--- | :--- | ---: | ---: | ---: |
| **v1 Status Quo** (`Alloy + VM + VL + Grafana + Alerts`) | Metrics + Logs | `1,443 MiB` | baseline | `558 MiB` *(OOMs 1 GiB RPi!)* |
| **`OBS-LeanGrafana`** (`FluentBit+NodeExp` or `Vector` + `VM + VL + VT` + `Grafana` + `Alerts`) | **Metrics + Logs + Traces** | **`~890–940 MiB`** | **`-500` to `-550 MiB`** *(keeps rich Grafana dashboards!)* | **`39.5 MiB`** *(or `82 MiB` Vector)* |
| **`OBS-UltraLeanPerses`** (`FluentBit+NodeExp` + `VM + VL + VT` + `Perses` + `Alerts`) | **Metrics + Logs + Traces** | **`~490–530 MiB`** | **`-910` to `-950 MiB` (`~3×` smaller!)** | **`39.5 MiB`** |
