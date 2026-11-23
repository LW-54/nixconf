---
id: EXP-NNNN
title: <Descriptive Experiment / Benchmark Title>
type: experiment
status: planned                # planned | running | completed
created: YYYY-MM-DD
updated: YYYY-MM-DD
domain: <foundations|verification|tooling|networking-fleet|gitops|distributed|observability|knowledge>
tags: []
assumptions: []                # Assumptions tested (e.g., [A-005])
rfd: null                      # Linked RFD (e.g., RFD-0003)
git_commit: <sha>              # Exact repo commit tested against
host: astrolabe                # Hardware & OS environment
summary: <One crisp sentence summarizing hypothesis and measured verdict>
---

<!-- abstract:start -->
## Executive Abstract

<Max 12 lines: Hypothesis tested, exact setup, headline empirical numbers, and clear verdict on linked assumptions (`validated` / `falsified` / `nuanced`).>
<!-- abstract:end -->

# EXP-NNNN: <Title>

## 1. Hypothesis & Falsification Criteria
- **Tests Assumption(s)**: `A-XXX`
- **Hypothesis**:
- **Falsification Criterion** *(What measured outcome would disprove the hypothesis?)*:

## 2. Environment & Reproducibility
- **Git Commit**: `<sha>`
- **Host**: `<hostname, CPU, RAM, Nix version, kernel>`
- **Isolation Method**: *(e.g., `/tmp/exp-NNNN` or throwaway branch `exp/EXP-NNNN-*`)*
- **Exact Commands / Prototype Code**:
```bash
# Reproducible invocation
```

## 3. Raw Measurements & Observations
*(Include full quantitative tables, distributions, memory/disk/wall/CPU numbers, and error outputs. Store large raw JSON/logs in `experiments/raw/EXP-NNNN-*`.)*

## 4. Analysis & Verdict
- **Result**:
- **Assumption Update**: `A-XXX` → `<validated | falsified | experimenting>`
- **Architectural Takeaway**:
