---
id: AUD-0001
title: Phase 1 Audit — Core Primitives, Contracts, Implementations, Features & Entanglement
type: audit
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [audit, primitives, contracts, implementations, entanglement, portability, multi-implementation]
assumptions: [A-001, A-002, A-003, A-013]
git_commit: 90c0b02
summary: Quantitative and structural audit of flake.nix, primitives/, and modules/ exposing 3-pass evaluation complexity, 1:1 implementation lock-in, Parnas boundary violations, N×M boilerplate, cross-host eval coupling, and standalone portability gaps.
---

<!-- abstract:start -->
## Executive Abstract

Audits the core composition layers of `nixconf` at commit `90c0b02` (~33.9k LOC across `primitives/` and `modules/`). **Core findings**: (1) **Inverted weight ratio** — actual host definitions are only 506 LOC (~1% of the 50k-LOC repo), while `primitives/` (4,874 LOC) builds a custom 3-pass meta-compiler (`evalModules` → `flake-parts` → `nixosSystem`) on top of Nix's module system; (2) **Severe hidden entanglement** — `internal.<ns>` global backchannels appear 226× (driven by flat `import-tree` auto-loading), `self.lib.*` 197×, defensive `config.*.enable or false` 85×, and `hub.nix` forces full evaluation of *all other hosts* (`self.nixosConfigurations`) when evaluating `astrolabe`; (3) **Broken contract↔implementation boundaries** — `modules/contracts/monitoring/` embeds ~7,300 LOC of Grafana-specific JSON dashboards inside a "vendor-neutral" contract, `contracts/storage/cli.nix` directly imports `self.lib.sops`, `primitives/host` hardcodes `reverse-proxy`, `monitoring`, `resources`, `docker`, and `x86_64-linux`, and `checkContractFulfillment` **hard-blocks >1 implementation per contract** (`noConflict = length <= 1`) using a fragile `tryEval`/`_file` regex scraper; (4) **Low standalone portability** — only 9 of 34 features export standalone packages (only 2 via `wrapper-modules`), locking reusable user-space tools inside NixOS-only host modules.
<!-- abstract:end -->

# AUD-0001: Core Primitives, Modules & Entanglement Audit

- **Snapshot**: Git commit `90c0b02` (branch `main` baseline)
- **Method**: Full quantitative static census + direct line-by-line inspection of `flake.nix`, `primitives/`, `modules/contracts/`, `modules/implementations/`, `modules/features/`, and `modules/hosts/`.

---

## 1. Quantitative Anatomy of the Codebase

| Layer | Files | Total LOC | `.nix` LOC | `.rs` LOC | Share of Repo (~50k LOC) |
| :--- | ---: | ---: | ---: | ---: | ---: |
| `primitives/` | 24 | 4,874 | 4,874 | 0 | 9.7% |
| `modules/contracts/` | 45 | 14,108 | 14,108 | 0 | 28.2% |
| `modules/implementations/` | 30 | 7,297 | 7,297 | 0 | 14.6% |
| `modules/features/` | 39 | 7,139 | 5,911 | 1,228 | 14.3% |
| `modules/hosts/` | 12 | 506 | 506 | 0 | **1.0%** |
| `meta/` *(see `AUD-0002`)* | 74 | 15,009 | 10,520 | 4,052 | **30.0%** |
| `.tack/` + `secrets/` + `.githooks/` + `.github/` | 32 | 2,539 | 1,082 | 0 | 5.1% |

> **Diagnostic Signal**: Only ~1% of repository code describes actual hosts, and ~14% describes features — while **~78% of the repository is meta-machinery, contracts, schemas, dashboards, and custom tooling**. Much of that weight comes from leaky abstractions and duplicated glue rather than intrinsic problem complexity.

---

## 2. How `primitives/` Actually Works (3-Pass Meta-Compiler Critique)

In `flake.nix:7-20`:
1. **Pass 1**: `nixpkgs.lib.evalModules` evaluates `import-tree ./primitives` to produce a deferred flake-parts module `config.primitives` (synthesizing option declarations for `contract`, `implementation`, `feature`, `host`, `lib`, and meta-`primitive`, plus `checks.schemas`, `flake.schemas`, and parallel doc hooks).
2. **Pass 2**: `flake-parts.lib.mkFlake` imports `primitives`, `import-tree ./modules`, and `import-tree ./meta`, compiling instances into `flake.nixosModules.*`, `flake.lib.*`, `packages.*`, `devShells.*`, and `flake.nixosConfigurations.*`.
3. **Pass 3**: `nixpkgs.lib.nixosSystem` evaluates each host (`modules/hosts/*`), automatically injecting `contracts`, `testing`, `hostTestingModule`, and `hostMonitoringModule`.

### Ousterhout Depth Assessment (`primitives/` = 4,874 LOC)
- **What adds genuine value**: Uniform contract option loading, unified host assertion/inspect/VM test harness, and preventing silent typos via schema checks.
- **What is shallow / over-engineered / leaky**:
  - **1,246 LOC of primitive-specific doc generators** (`primitives/*/docs.nix`) tightly coupled to `meta/docs` and `internal.docs`.
  - **1,733 LOC of custom meta-schema/parser/validator machinery** (`primitives/primitive/lib/*.nix` — `check.nix` 573 LOC, `option.nix` 304 LOC, `parser.nix` 274 LOC, `schemas.nix` 219 LOC, `output.nix` 208 LOC, `common.nix` 155 LOC) re-implementing option introspection and schema validation *outside* NixOS's native module type system.
  - **Domain leakage into core primitives**:
    - `primitives/host/monitoring.nix` (392 LOC) hardcodes `monitoring`, `resources`, `virtualisation.docker`, and `virtualisation.podman` directly inside the `host` primitive!
    - `primitives/host/testing.nix:36` calls `self.lib.reverse-proxy.findPortConflicts` directly inside the `host` primitive!
    - `primitives/host/testing.nix:75-78` asserts a bootloader (`boot.loader.*` or `boot.isContainer`) on *every* host — which breaks **WSL** and **Live USB ISOs** without opt-out hacks.

---

## 3. Concrete Entanglement & Fragility Hotspots

### 3.1 Flat Auto-Import Forces 226 `internal.<ns>` Global Backchannels
Because `import-tree` auto-imports every `.nix` file under `modules/` and `meta/` into one flat `flake-parts` module graph, splitting *any* multi-file subsystem forces declaring global mutable-like escape hatches (`options.internal.<name> = mkOption { type = lazyAttrsOf raw; }`):
- **226 occurrences** across the repo (`101` in `modules/`, `124` in `meta/`, `1` in `primitives/`).
- Effect: Hidden untyped (`types.raw`) coupling between files; impossible to tell from file imports what depends on what without grepping `internal.*`.

### 3.2 Broken Contract ↔ Implementation Boundaries (Parnas Violations)
The repo explicitly claims *"Pure contract interfaces decoupled from any specific provider"* (`primitives/contract/default.nix:10`), yet concrete providers leak deeply into contracts:
1. **`modules/contracts/monitoring/` (9,000+ LOC total!)**:
   - Contains **~7,300 LOC** of Grafana-specific JSON dashboard layout DSL (`dashboard/*.nix`: 2,870 LOC) and 12 Grafana dashboards (`dashboards/*.nix`: 5,100 LOC) inside the supposedly vendor-neutral `monitoring` *contract*!
   - `monitoring/default.nix:19-20,72` and `monitoring/types.nix` hardcode `adje.app`, Prometheus scrape semantics, and Grafana `schemaVersion = 39`.
2. **`modules/contracts/storage/cli.nix` (704 LOC)**:
   - Line 7 iterates `self.nixosConfigurations` directly (cross-host coupling).
   - Line 20 calls `self.lib.sops.mkWriteSecretScript` — binding the abstract `storage` contract directly to the concrete `sops` implementation!
   - `modules/contracts/storage/drivers/` embeds concrete cloud drivers (`gdrive.nix`, `hetzner-box.nix`, `s3.nix`) inside `contracts/`.
3. **Personal constants baked into abstract contracts**:
   - `adje.app` appears **24 times** across the repo, including inside `contracts/auth`, `contracts/monitoring`, `contracts/reverse-proxy`.
   - `lw` appears **33 times**, including inside `contracts/home.nix`, `contracts/persistence.nix`, `features/git.nix`, `features/nix.nix`, `features/zed.nix`.

### 3.3 Hard 1:1 Lock-In Blocks Multi-Implementation & Sub-Component Swapping
- `primitives/implementation/default.nix:53`: `contract = option.contract;` — a single scalar string. An implementation cannot fulfill multiple contracts or modular sub-contracts.
- `primitives/host/lib.nix:135,142`:
  ```nix
  noConflict = builtins.length activeImpls <= 1;
  noConflictingImplementations = (!isEnabled) || noConflict;
  ```
  Structurally **forbids** running two implementations of the same contract on one host (e.g., two storage/secret/proxy/home layers or staged migration between backends).
- **Fragile Module Discovery Hack** (`primitives/host/lib.nix:9-115`):
  To determine which implementations a host imports, `collectHostImportedModules` builds fake `dummyArgs = { pkgs = {}; config = {}; options = {}; ... }`, calls module functions inside `builtins.tryEval`, silently swallows failures (`else {}`), and regex-splits `_file` strings on `"#nixosModules."`! Any host using conditional or dynamic imports silently defeats contract fulfillment verification.

### 3.4 N×M Service-to-Contract Synchronization Boilerplate
Every service feature manually wires 3–6 cross-cutting contracts via parallel `// self.lib.<c>.mkOption { ... }` + `(self.lib.<c>.mkConfig { inherit config cfg; })` blocks:
- `copyparty.nix`: 6 contracts (`backup`, `monitoring`, `persistence`, `resources`, `reverse-proxy`, `storage`)
- `uchiyomi.nix`: 6 contracts
- `vaultwarden.nix`: 5 contracts
- `attic.nix`, `ntfy.nix`: 4 contracts each
- `ttyd.nix`, `antigravity/hub.nix`: 3 contracts each
- **Consequence**: Adding a new cross-cutting concern (e.g., Tailscale mesh exposure or automated update policy) forces editing *every* service module; forgetting either `mkOption` or `mkConfig` silently drops integration. (Contrast with Daniel Jackson's declarative **Synchronizations**!)

### 3.5 Hidden Cross-Host Eval Coupling & Fixed-Point Traps
- **`modules/features/antigravity/hub.nix:21-26`**: Evaluates `self.nixosConfigurations.${hostName}.config.services.agy-remote-control.enable` for *every* host in the flake just to populate `AGY_HUB_KNOWN_HOSTS`. Evaluating `astrolabe` therefore drags in `x240` (and would drag in all 8 future hosts, including `aarch64`!).
- **Defensive `config.*.enable or false` (85 occurrences)** and **`options ? ...` (9 occurrences)**: Indicate implicit optional dependencies where modules probe peer namespaces ad-hoc instead of declaring clean interfaces.
- **Fixed-Point Recursion Hazards**: Observed directly during recent `remote-control.nix` edits — indexing `home.users.${cfg.user}` where `cfg.user` derives from `users.users` triggers infinite recursion because `hjem` derives `users.users` from `home.users` attrNames.

### 3.6 Hardcoded Platform & Target Assumptions (`QA-03` Blockers)
- `x86_64-linux` is hardcoded **25 times** (`primitives/host/default.nix:57,116,145`, `primitives/host/docs.nix`, `meta/ci/*`, `meta/docs/render.nix`, `Justfile`).
- `primitives/host/default.nix:114-125` assumes every host is a full bootable NixOS machine with `contracts`, `testing`, `hostTestingModule`, and `hostMonitoringModule` — no clean separation for **WSL** (no bootloader/disko), **Live USB ISO** (ephemeral squashfs), or **`aarch64` SBC**.

---

## 4. Standalone Portability Audit (`QA-09`: `nix run` Anywhere)

Out of **34 features** in `modules/features/`:
- **Only 9** export standalone `packages`: `antigravity`, `attic` (bootstrap script), `bitwarden`, `dolphin`, `fonts`, `foot`, `git`, `micro`, `zed`.
- **Only 3** export `devShells`: `antigravity` (`gemini-api`), `git` (`github-ssh`, `github-cli`), `ssh`.
- **Only 2** (`foot.nix`, `git.nix`) use `wrapper-modules` to build portable pre-configured standalone binaries — and even those **duplicate** settings logic between NixOS `home.*` config and wrapped standalone `packages`!
- **25+ features** (including highly portable user tools like `direnv`, `micro` config, `zed` config, `vscode`, `vivaldi`, `helium`, `labwc`, `noctalia`, `tack`, `ssh` client config, `agy` rules/settings) are partially or completely trapped inside NixOS-only `modules`.

---

## 5. Summary: What Worked Well vs What Failed Structurally

| Keep as Empirical Inspiration | Discard / Re-Architect from First Principles |
| :--- | :--- |
| Declarative contract idea (abstracting backup, persistence, monitoring, resources, secrets, ingress) | 3-pass `primitives/` meta-compiler (4.9k LOC) + `tryEval`/`_file` string-scraping hacks |
| Progressive test tiers (`eval` → `inspect` → `vm` → `install`) | Hard 1:1 `implementation` lock-in; leaking Grafana/SOPS/reverse-proxy into contracts & primitives |
| Portable wrapped binaries (`wrapper-modules` concept) | Flat `import-tree` forcing 226 untyped `internal.*` globals |
| Strong separation of small host files (506 LOC) from reusable capabilities | Cross-host `self.nixosConfigurations` coupling (`hub.nix`, `storage/cli.nix`) and `x86_64`/full-disk assumptions |
