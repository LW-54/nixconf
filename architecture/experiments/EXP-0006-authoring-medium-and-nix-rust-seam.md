---
id: EXP-0006
title: Stage 3A.1 Empirical Benchmark — Authoring Mediums (A1 Nix vs A2 TOML+Nix vs A3 Hybrid) & Zero-IFD Nix↔Rust Seam
type: experiment
status: completed
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [experiment, benchmark, phase-3, stage-3a, authoring-medium, toml, nix, rust, aky-core, cache-isolation, non-piercing]
assumptions: [A-001, A-002, A-013]
summary: Head-to-head empirical benchmark on astrolabe linking the Lean-4-verified Rust engine (architecture/formal/drt/engine/) against real pinned nixpkgs NixOS + standalone realizations across A1 (Pure Single-File Nix), A2 (Split TOML Boundary + Pure Nix Interior), and A3 (Hybrid). Proves A2 verifies a 48-agent/8-host fleet in 5.79 ms with zero Nix dependency (14x faster than A1-direct 79.24 ms; 23x faster than A1-flake 131.16 ms), while producing bit-for-bit identical NixOS & standalone .drv hashes with 0 cache busts and mechanical non-piercing enforcement.
---

<!-- abstract:start -->
## Executive Abstract

Empirically evaluates the **Stage `3A.1` One-Way Door** candidate set (**`A1` Pure Single-File Nix**, **`A2` Split TOML Boundaries + Pure Nix Interiors**, **`A3` Hybrid `*.toml` Fleet + `*.nix` Atomic Agents**, with **`A4` Nickel/CUE** pruned via 2025–2026 ecosystem evidence) against the real Lean-4-verified Rust core (`architecture/formal/drt/engine/`) and pinned `nixpkgs` (`nixos/lib/eval-config.nix` + standalone `pkgs.writeShellApplication`):

1. **Boundary-First Verification Latency (`Π_ext ⊥ Interior`):**
   - **3 agents / 2 hosts:** `A2` Zero-Nix Rust TOML **`2.29 ms`** vs. `A3` Hybrid `59.16 ms` vs. `A1-direct` (`nix eval --file`) `64.77 ms` vs. `A1-flake` `130.43 ms`.
   - **48 agents / 8 hosts (full planned fleet scale):** `A2` Zero-Nix Rust TOML **`5.79 ms`** (`4.05 ms` Rust engine) vs. `A3` Hybrid `59.27 ms` vs. `A1-direct` `79.24 ms` vs. `A1-flake` `131.16 ms` (note: flake copy overhead scales further with repo size, reaching `~830 ms` in full repos per `EXP-0004`).
2. **Identical Realization & Cache Isolation (`Zero ${self}` / `Zero IFD`):**
   - Both `A1` and `A2` evaluate real NixOS (`astrolabe`, Vaultwarden + Caddy) and standalone (`aky-hello`) derivations to **bit-for-bit identical `.drv` store paths**:
     - `/nix/store/l02079fihxmafvdf5aas5l6dnglrzjv6-nixos-system-astrolabe-26.11pre-git.drv`
     - `/nix/store/xdvcrgybywskn44hxbzlfakzlsnr452x-aky-hello.drv`
   - Mutating `README.md` and `hosts/live-iso.*` produced **0 cache busts** on `astrolabe` in both `A1` and `A2`.
3. **Mechanical Verification & Non-Piercing Proof:**
   - The Lean-verified Rust engine passed `astrolabe` (`scope + state + superagent_conforms`), rejected `vaultwarden` on ephemeral `live-iso` (`all_volumes_valid = false`), and enforced Cedar `forbid-roaming-or-ai` on `agy` across all candidates.
   - An interior (`agents/vaultwarden/interior.nix`) attempting to read an undeclared offer (`bound."undeclared:secret"`) failed immediately during Nix evaluation with exact source location (`attribute '"undeclared:secret"' missing at agents/vaultwarden/interior.nix:3:35`).
<!-- abstract:end -->

# EXP-0006: Stage 3A.1 Authoring Medium & Nix↔Rust Seam Benchmark

## 1. Environment & Methodology (`astrolabe`, `x86_64-linux`)
- **Pinned `nixpkgs`**: `/nix/store/p7yx739q7ips4f9a1a26k509id1kd85i-source`
- **Nix**: `2.34.9`
- **Rust**: `rustc 1.99.0` (`/nix/store/6l9kbzxwq9ij2lcmwl2qb1jdpqisjr8l-rustc-wrapper-1.99.0/bin/rustc`) compiling the **actual Lean-4-verified engine** from [`architecture/formal/drt/engine/`](../formal/drt/engine/mod.rs) (`compile time: 2.72 s`).
- **Workload**:
  - *Small*: 3 agents (`caddy`, `vaultwarden`, standalone `aky-hello`) × 2 contrasting substrates (`astrolabe` 11 GiB durable VPS, `live-iso` 2 GiB ephemeral).
  - *Fleet Scale*: 48 agents × 8 hosts (`astrolabe`, `live-iso`, `x240`, `zenbook`, `tuf`, `chromebook`, `rpi`, `wsl`).
- **Seam Tested (`S1` — Zero-Artifact Parallel Read)**:
  - Rust `aky-core` reads boundaries directly (TOML in `A2`, or `nix eval --json` stdout in `A1`/`A3`) and verifies all invariants (`is_scope_valid`, `superagent_conforms`, `all_volumes_valid`, Cedar `authorize`).
  - Nix realizes hosts and standalone packages natively with **zero generated files and zero IFD** (`builtins.fromTOML` in `A2`, `import` in `A1`) via a ~25-LOC keyed binder passing ONLY `{ self, bound, pkgs }` to each agent's `interior`.

---

## 2. Empirical Measurements

### 2.1 Boundary-First Preflight Latency (`Π_ext ⊥ Interior`)

| Candidate & Invocation Path | Small (3 agents / 2 hosts) Median | Fleet Scale (48 agents / 8 hosts) Median | Fleet Scale Min / Max | Requires `nix` Binary? |
| :--- | ---: | ---: | ---: | :---: |
| **`A2`: Pure Split TOML → Zero-Nix Rust `aky-core`** | **`2.29 ms`** *(Rust: 0.56 ms)* | **`5.79 ms`** *(Rust: 4.05 ms)* | `5.55 / 7.63 ms` | **NO** |
| **`A3`: Hybrid (`*.toml` hosts + `nix eval --file` agents) → Rust** | `59.16 ms` *(Rust: 0.35 ms)* | `59.27 ms` *(Rust: 1.53 ms)* | `47.71 / 60.84 ms` | Yes (for full check) |
| **`A1-direct`: Pure Nix (`nix eval --json --file`) → Rust** | `64.77 ms` *(Rust: 0.19 ms)* | `79.24 ms` *(Rust: 0.82 ms)* | `52.69 / 87.51 ms` | Yes |
| **`A1-flake`: Pure Nix (`nix eval --json .#akyBoundary`) → Rust** | `130.43 ms` | `131.16 ms` *(grows w/ repo size!)* | `114.29 / 135.06 ms` | Yes |

### 2.2 Real NixOS + Standalone Realization, Cache Isolation & Non-Piercing

| Verification Check | `A1` (Pure Nix) | `A2` (TOML + Nix) | Evidence |
| :--- | :---: | :---: | :--- |
| **Full NixOS (`astrolabe`) + Standalone (`aky-hello`) Eval** | `15.25 s` | `12.14 s` | Evaluates real `services.vaultwarden`, `services.caddy`, and `pkgs.writeShellApplication` |
| **Identical `.drv` Output (`A1 == A2`)** | **PASS** | **PASS** | `l02079fihxmafvdf5aas5l6dnglrzjv6-nixos-system-astrolabe-26.11pre-git.drv` & `xdvcrgybywskn44hxbzlfakzlsnr452x-aky-hello.drv` |
| **Cache Isolation (`README.md` + `live-iso` mutated)** | **0 busts** | **0 busts** | `astrolabeDrv` bit-for-bit identical before & after |
| **Lean-Verified Engine Checks (`astrolabe` ok, `live-iso` rejected, `agy` forbid)** | **PASS** | **PASS** | Caught key-matching mismatch on first prototype run in `307 µs`! |
| **Non-Piercing Interior Leak Test (`bound."undeclared:secret"`)** | **BLOCKED** | **BLOCKED** | Exit code 1: `error: attribute '"undeclared:secret"' missing at agents/vaultwarden/interior.nix:3:35` |

---

## 3. Structural Takeaways for Stage `3A.1` Ratification

1. **`A1-direct` is surprisingly viable on raw speed (`79 ms` at 48 agents / 8 hosts)** when bypassing flake tree-copying — so the decision between `A1`, `A2`, and `A3` is **NOT** merely about speed, but about **five deeper architectural trade-offs**:
   - **Zero-Nix operation & `5.8 ms` latency (`A2`)** vs. single-language Nix locality (`A1`).
   - **Syntactic impossibility of `nixpkgs`/thunk leaks into $\Pi_{\text{ext}}$ (`A2`)** vs. lint-enforced purity (`A1`).
   - **Lossless programmatic mutation (`toml_edit` for `aky onboard` Genesis `t=0`, `aky revoke`, AI PRs) (`A2`/`A3`)** vs. Nix AST generation (`A1`).
   - **Fractal Uniformity (`A2` = TOML for every entity; `A1` = Nix for every entity)** vs. dual boundary syntax (`A3`).
   - **2 files per atomic Nix agent (`agent.toml` + `interior.nix` in `A2`)** vs. 1 file per atomic Nix agent (`agent.nix` in `A1`/`A3`).
2. **Seam `S1` (Zero-Artifact Parallel Read) is strictly superior to `S2` (Codegen Lockfile) and `S3` (Rust Subprocess Driver)**: Zero generated files, zero IFD, native `nix run`/`nix build` work standalone without `aky` installed, and `A1`/`A2` yield bit-for-bit identical store derivations.
3. **Ecosystem Pruning (`A4` Nickel/CUE)**: Pruned via 2025–2026 primary survey (`organist` remains dev-shell scoped without native NixOS module interop; adds a 4th language and dependency risk `D` without adding formal guarantees beyond our Lean-verified Rust core + JSON Schema).
