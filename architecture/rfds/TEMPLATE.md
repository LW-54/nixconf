---
id: RFD-NNNN
title: <Bias-Free Problem-Domain Title>
type: rfd
status: prediscussion          # prediscussion | discussion | decided | abandoned
created: YYYY-MM-DD
updated: YYYY-MM-DD
domain: <foundations|verification|tooling|networking-fleet|gitops|distributed|observability|knowledge>
tags: []
assumptions: []                # e.g., [A-001, A-002]
depends_on: []                 # e.g., [AUD-0001, RFD-0001]
experiments: []                # e.g., [EXP-0001]
research: []                   # e.g., [RES-0003]
adrs: []                       # Filled once status -> decided
summary: <One crisp sentence for INDEX.md>
---

<!-- abstract:start -->
## Executive Abstract

<Max 15 lines. State the fundamental problem, key dimensions explored in the design manifold, empirical highlights, leading candidate(s) with core trade-offs, and open decision questions for review.>
<!-- abstract:end -->

# RFD-NNNN: <Title>

## 1. Fundamental Problem Statement
*(Formulated purely from Charter goals and boundary constraints — ZERO presuppositions about current `nixconf` internals.)*

- **Core Problem**:
- **Non-Goals / Explicit Boundaries**:
- **Relevant ATAM Quality Scenarios**: (`QA-XX`, …)
- **Relevant Assumptions**: (`A-XXX`, …)

## 2. Formal Shape of the Underlying Problem
*(What are the mathematical/structural invariants, state transitions, coupling forces, or fundamental trade-off laws governing this domain?)*

## 3. Morphological Design Space (Zwicky Box)
*(Factor the problem into orthogonal dimensions and enumerate the full option space without design fixation.)*

| Dimension | Option A | Option B | Option C | Option D |
| :--- | :--- | :--- | :--- | :--- |
| **D1: ...** | ... | ... | ... | ... |
| **D2: ...** | ... | ... | ... | ... |

### 3.1 Cross-Consistency Assessment (CCA)
*(Explicitly prune impossible or self-contradictory combinations and explain why.)*

### 3.2 Feasible Pareto Frontier (Candidate Architectures)
*(Describe the 2–5 distinct non-dominated candidate points on the manifold.)*

## 4. Empirical Evidence, Benchmarks & Prototypes
*(Link to `research/RES-*` and `experiments/EXP-*` — real data, never guesses.)*

## 5. ATAM Trade-Off Analysis

| Candidate | Elegance (X1/X2) | Portability (QA-03) | Speed/Cache (QA-05) | Reliability/Ops | Maint. / Dep. Risk (X5) | Key Sensitivity & Trade-Off Points |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Candidate 1** | | | | | | |

## 6. Recommendation & Open Questions for Co-Design
- **Current Leaning**:
- **Key Risks & Falsification Triggers**:
- **Questions for Discussion**:

## 7. Decision & Lineage Log
- `YYYY-MM-DD`: Initial `prediscussion` draft created.
