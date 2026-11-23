---
id: AUD-0003
title: Phase 1 Audit — Verification Tiers, CI, Cache Isolation, Secrets & Operational Subsystems
type: audit
status: active
created: 2026-11-23
updated: 2026-11-23
domain: verification
tags: [audit, testing, ci, cache-isolation, secrets, sops, attic, monitoring, resources, backup, impermanence]
assumptions: [A-004, A-006, A-008, A-010]
git_commit: 90c0b02
summary: Audits nixconf's 4-tier test harness, CI workflows, cache isolation, SOPS/Bitwarden secret boundaries, and operational contracts/implementations, identifying strengths to preserve and concrete gaps for multi-host/GitOps scaling.
---

<!-- abstract:start -->
## Executive Abstract

Audits verification, CI, cache isolation, secrets, and operational infrastructure at commit `90c0b02`. **Genuine strengths worth preserving as concepts**: (1) progressive 4-tier verification (`eval` → `inspect` → `vm` → `install` with per-namespace slicing), (2) fast Attic + `.narinfo` cache-skip CI (~49s wall time) with automated `README.md` cache-isolation guard, (3) deterministic throwaway SOPS test keys (`mkTestSecrets`) enabling secretless QEMU/install tests, and (4) declarative cgroup v2 resource tiering + continuous Grafana/VictoriaMetrics perf monitoring. **Concrete flaws & scaling gaps discovered**: (1) **Residual `${self}` leak** in `modules/implementations/rclone/mounts.nix:132` (`DEVENV_ROOT=${self}`); (2) **Zero verification** of Rust code (`cargo test`/`clippy`), `meta/` scripts, `aarch64` builds, or cross-host network interactions (`meta/tests` supports `scenarios`, yet 0 multi-node scenarios exist); (3) **Manual host-onboarding secret friction** — adding each new host requires manually editing 4+ anchors/rules in `.sops.yaml`, re-encrypting shared secrets, and bootstrapping keys via Bitwarden; (4) **Hardcoded single-VPS topology** — `x240` hardcodes `https://vm.adje.app` / `https://vlogs.adje.app` public ingestion endpoints with static bearer tokens instead of private mesh transport; and (5) **No GitOps convergence or automated updates** — deployment is still manual `just switch <host>` and `tack update`.
<!-- abstract:end -->

# AUD-0003: Testing, CI, Cache Isolation, Secrets & Ops Audit

- **Snapshot**: Git commit `90c0b02`

---

## 1. Verification & Testing Architecture Audit

### 1.1 Current Test Tiers (`primitives/host/lib.nix`, `primitives/host/testing.nix`, `meta/tests/`)
| Tier | Mechanism | Typical Time | Scope Covered |
| :--- | :--- | ---: | :--- |
| **`schemas`** | Custom `primitives/primitive/lib/schemas.nix` | ~2–3s | Primitive option/contract presence + 1:1 implementation check |
| **`eval-<host>`** | `runCommandLocal` forcing `evalChecks` + NixOS `assertions` | ~6s | Hostname, bootloader, login, stateVersion, port conflicts, per-feature eval assertions |
| **`inspect-<host>`** | `runCommand` inspecting `$etc` & `$sw` (plus `inspectByNamespace`) | ~10–15s | Generated systemd units, `/etc` files, configs without KVM |
| **`vm-<host>`** | `nixpkgs.lib.nixos.runTest` in QEMU with mock SOPS secrets (plus `vmByNamespace`) | ~30–120s | Boot to `multi-user.target`, 0 unexpected failed units, runtime service HTTP/socket checks |
| **`install-<host>`** | Full Disko partitioning + `nixos-install` + reboot + `vmChecks` + `installChecks` | ~5–10m | End-to-end bare-metal/impermanence install & reboot persistence |
| **`docs` / `ci`** | Diff check against working tree + `actionlint` | ~12s / ~3s | Sync of 169 generated Markdown files and 2 GitHub Actions YAML files |

### 1.2 Verification Blind Spots & Structural Weaknesses
1. **Zero verification of auxiliary tooling & Rust**:
   - No `cargo test`, `cargo clippy`, `rustfmt --check`, or `shellcheck` across `meta/prof/`, `meta/docs/sync.rs`, `antigravity/hub.rs`, `.githooks/pre-commit`, or `Justfile`.
2. **Host-test boilerplate coupling**:
   - `primitives/host/testing.nix` bakes bare-metal assumptions (`bootloader` check, `/etc/fstab` inspect check, `disko` `installTest`) directly into *every* host — incompatible with **WSL** and **Live ISO** targets without per-host disable hacks.
3. **Zero multi-host / mesh integration tests**:
   - `meta/tests/default.nix:16-23` defines a `test.scenarios` multi-node QEMU runner, but **0 scenarios exist**; cross-host interactions (e.g., `x240` → `astrolabe` telemetry/cache/mesh) are completely untested.
4. **Single-architecture CI (`x86_64-linux` only)**:
   - `meta/ci/build.nix` and `meta/ci/host-tests.nix` hardcode `x86_64-linux` throughout; no `aarch64-linux` check/build path exists for Raspberry Pi.
5. **Pre-commit hardcoded host list**:
   - `.githooks/pre-commit:111-112` and `Justfile:39,46,56` hardcode `eval-astrolabe` and `eval-x240` instead of discovering hosts dynamically — every new host requires manual edits in multiple files.

---

## 2. CI & Binary Cache Isolation Audit

### 2.1 What Works Well (Measured Baselines)
- **Attic self-hosted binary cache** (`https://cache.adje.app/nixconf`, `modules/features/attic.nix`) + **Cachix** + **`.narinfo` cache-skip** in `.github/workflows/{build,host-tests}.yml`: reduced full `CI & Binary Cache Push` wall time from 259s / 35.5 runner-min to **~49s / 2.7 runner-min**.
- **Automated Cache-Isolation Guard** (`meta/ci/build.nix:246`): Mutates `README.md` in CI and fails if any non-docs derivation hash changes — preventing accidental `${self}` regressions.
- **Continuous Performance Telemetry** (`modules/features/perf-monitor.nix` + `nixprof metrics`): Exports 30-min CI/Attic metrics, daily eval/cache-isolation metrics, and live `.githooks/pre-commit` timings to VictoriaMetrics + Grafana + Alertmanager → ntfy.

### 2.2 Concrete Gaps & Latent Bugs Found
1. **Latent `${self}` Cache Leak**: `modules/implementations/rclone/mounts.nix:132` sets `"DEVENV_ROOT=${self}"` in `storage-drift-check.service` — whenever `driftCheck.enable = true`, *any* edit to any file in the repository invalidates the service and host toplevel!
2. **Source-tree scans using `self + "/..."`**: `meta/docs/lib/context.nix`, `meta/docs/pages/guide.nix`, and `meta/graph/extractors/source.nix` use `self + "/..."` during Nix evaluation (safe for derivation outputs only when not interpolated into derivations, but fragile and tightly tied to repo root layout).
3. **No GitOps / PR-bot automation**:
   - CI builds & caches on push to `main` and PRs, but there is **no automated update PR pipeline** (e.g., for Vaultwarden / nixpkgs security updates) and **no host auto-convergence** (`comin` / `system.autoUpgrade`).
   - `.tack/pins.lock.json` blocks standard Nix flake update actions (`DeterminateSystems/update-flake-lock`, Renovate flake manager).

---

## 3. Secrets & Trust Boundary Audit (`.sops.yaml` & `modules/implementations/sops.nix`)

### 3.1 Current Key Hierarchy
- **4 Age Keys** in `.sops.yaml`: `admin` (master key stored in Bitwarden), `x240`, `astrolabe`, `github_actions` (uploaded to GitHub Secrets).
- **25 encrypted YAML files** under `secrets/` (`admin/`, `ci/`, `hosts/{astrolabe,x240}/`, `services/`, `storage/`, `wifi/`).
- **Agent autonomous push key**: `secrets/hosts/astrolabe/agent-git.yaml` decrypted to `/run/secrets/agy-git-deploy-key` (0400 `lw:users`), scoped strictly to `LW-54/nixconf` write access with `main` force-push/deletion ruleset.
- **Secretless testing (`mkTestSecrets`)**: Deterministic throwaway age keypair in `modules/implementations/sops.nix:9-64` generates mock SOPS files during VM/install tests — a genuinely clean pattern.

### 3.2 Scaling Friction & Fragility
1. **Manual N-host YAML boilerplate in `.sops.yaml`**: Adding 6 new hosts (`zenbook`, `tuf`, `chromebook`, `rpi`, `wsl`, `iso`) requires manually adding keys, YAML anchor groups (`*all`, `*personal`, `*servers`, `*host_<name>`), creation rules, AND running `sops updatekeys` across every shared secret file!
2. **Hardcoded impermanence path**: `modules/implementations/sops.nix:6` defaults `defaultAgeKeyFile = "/persist/sops-nix/key.txt"` — assumes impermanence `/persist` exists (breaks on WSL, non-impermanent hosts, and Live ISOs!).
3. **Interactive Bitwarden bottleneck**: Multiple workflows (`github-cli`, `github-ssh`, `gemini-api`, `storage-admin`) depend on interactive Bitwarden CLI login (`bw`), creating friction for headless provisioning and automation.

---

## 4. Operational Subsystems Audit (`astrolabe` & `x240`)

### 4.1 Hardcoded Single-VPS Topology (No Mesh Fabric)
- `modules/hosts/x240/system.nix:50-54` hardcodes public HTTPS push URLs `https://vm.adje.app/api/v1/write` and `https://vlogs.adje.app/insert/loki/api/v1/push` authenticated via a shared static bearer token.
- No private host-to-host network exists: SSH, Attic cache, Grafana/VictoriaMetrics ingestion, remote builders, and future storage/compute all have to either traverse the public internet (requiring public DNS, TLS, Caddy exposure, and auth hardening) or remain unreachable across NAT (e.g., home Raspberry Pi & roaming laptops).

### 4.2 Impermanence & Systemd Friction Patterns
- Repeated real-world collisions between `impermanence` bind-mounts (`/persist` → `/var/lib/*`) and upstream systemd hardening (`DynamicUser=true` failing with `EBUSY` on `/var/lib/atticd`, `/etc/ssl/certs/ca-certificates.crt` symlinks through `/etc/static`, `ProtectSystem=strict` vs `/home/lw` impermanent mounts).
- `astrolabe` allocates 9 dedicated loopback/thin disk volumes (`modules/hosts/astrolabe/resources.nix:29-136`) — strong quota isolation, though tightly tied to `cgroups/volumes.nix` (518 LOC custom volume manager!).

### 4.3 Live `astrolabe` Resource & Observability Baseline (Measured 2026-11-23)
- **CPU / RAM / Disk**: 6 vCPU, 11 GiB RAM (`3.9 GiB` used, `7.5 GiB` available) + 5.7 GiB zram (`920 MiB` used); `/nix` = `45 GiB / 100 GiB` (`/nix/store` = `26 GiB`).
- **Observability Stack RSS (~1.59 GiB total — 14.4% of VPS RAM)**:
  - `grafana.service`: 513 MiB
  - `alloy.service`: 458 MiB (+ 378 MiB WAL on disk)
  - `victoriametrics.service`: 436 MiB (312 MiB on disk / 25G volume)
  - `victorialogs.service`: 83 MiB (21 MiB on disk / 15G volume)
  - `alertmanager.service`: 48 MiB
  - `vmalert-metrics.service`: 32 MiB; `vmalert-logs.service`: 16 MiB
- **Core Edge & App Services RSS (~291 MiB combined)**:
  - `caddy` (87 MiB), `vaultwarden` (52 MiB), `ntfy-sh` (52 MiB), `authelia-main` (36 MiB), `ttyd-web` (34 MiB), `copyparty` (12 MiB), `sshd` (11 MiB), `lldap` (7 MiB).
- **Build / Agent Services RSS (~1.55 GiB combined)**:
  - `nix-daemon` (927 MiB), `agy-remote-control` (305 MiB, `agent.slice`), `atticd` (222 MiB), `cachix-watch-store-agent` (101 MiB).

> **Key empirical insight for `RFD-0007`**: Observability currently consumes **5.5× more RAM than all user-facing edge/auth/app services combined**, with `grafana` (513 MiB) and `alloy` (458 MiB) as the two largest consumers — while actual disk storage is tiny (~333 MiB). This immediately defines where optimization vs richer telemetry (traces/eBPF/profiling) has real leverage.
