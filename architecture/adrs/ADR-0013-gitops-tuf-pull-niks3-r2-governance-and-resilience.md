---
id: ADR-0013
title: Adopt Stage 3B.3 GitOps Convergence (P-AkyPull + TUF), NikS3 on Cloudflare R2, Split Security PRs, Perm-AgentApp Governance & M-FleetBare + Codeberg Resilience
type: adr
status: accepted
created: 2026-11-25
updated: 2026-11-25
domain: gitops
tags: [adr, stage-3b3, gitops, tuf, aky-pull, systemd-bless-boot, niks3, cloudflare-r2, aarch64, github-actions, rulesets, github-app, ai-agent-security, dix, gitleaks, codeberg, 3-2-1-1-0, a-008]
rfd: null
assumptions: [A-004, A-008, A-009]
supersedes: null
superseded_by: null
summary: Ratifies Stage 3B.3 (completing all of Stage 3B Cross-Cutting Planes) for canonical repository LW-54/antikythera: P-AkyPull zero-eval TUF convergence + alpha auto-rollback + systemd-boot.bootCounting, BC-Niks3 on Cloudflare R2 with native GitHub OIDC (retiring B2, Attic, Cachix, and CI SOPS), free native ubuntu-24.04-arm multi-arch CI, U-SplitGHA + Auto-Tiered security PRs, Perm-AgentApp strict PR-only main + locked calibrated Rulesets + dix/gitleaks governance, and M-FleetBare + Codeberg 3-2-1-1-0 resilience.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3B.3`** (completing all three Stage `3B` Cross-Cutting Planes — Trust [`ADR-0011`], Mesh [`ADR-0012`], and GitOps/Convergence/Cache/Governance/Resilience) for canonical v2 repository **`LW-54/antikythera`**, realizing [`ADR-0005`](ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md) (`C3`) and [`triadic_pull.qnt`](../../v2/formal/quint/triadic_pull.qnt) (`1,878,049` TLC-verified states) while closing `A-008` for Phase 4 QEMU validation:
1. **Zero-Eval TUF Pull Convergence (`P-AkyPull`)**: Thin ~400-LOC Rust `aky pull` systemd timer consuming a CI-signed Ed25519 TUF Snapshot (`calibration.json` on locked orphan branch `calibrated`) with persisted `max_seen_epoch`, staleness freeze alert ($\Delta t$), `--max-jobs 0` cache-only fetch (`~20 MiB` RSS vs `662–906 MiB` measured local Nix eval!), two-phase `switch-to-configuration test` → Tri-Purpose Survival Probes ($\alpha$) → `boot` commit (`boot.loader.systemd-boot.bootCounting.enable = true` / `systemd-bless-boot`) or atomic rollback, host proper-time conditions, and shared `flock(/run/aky-switch.lock)` with interactive `aky switch`.
2. **Binary Cache & Multi-Arch Build Plane (`BC-Niks3` + Cloudflare R2 + `ubuntu-24.04-arm`)**: `Mic92/niks3` (`v1.16.0` in pinned `nixpkgs`) on `astrolabe` (PostgreSQL reference-tracking GC) backed by **Cloudflare R2** (`cache.adje.app`, \$0 egress, direct CDN reads surviving `astrolabe` downtime/reinstalls, `0 GiB` VPS blob disk) + **native GitHub Actions OIDC** — retiring Backblaze B2 globally across the stack, retiring `atticd` and `cachix-watch-store-agent` (`-146` to `-640 MiB` peak RSS), and **eliminating `SOPS_AGE_KEY`, `ATTIC_TOKEN`, and `CACHIX_AUTH_TOKEN` from CI**. Free native 4-vCPU `ubuntu-24.04-arm` builds `aarch64-linux` closures while KVM VM tests run on `ubuntu-latest` (`x86_64`).
3. **Automated Security PRs (`U-SplitGHA` + `Auto-Tiered`)**: Daily isolated `nixpkgs` PR (`vaultwarden`, `tailscale`, `caddy`, `openssh`, kernel) auto-merging *only* when 100% of CI + KVM `vm-astrolabe` checks pass (+ `ntfy` digest); weekly isolated per-input third-party flake PRs + Dependabot (`Cargo.lock`, pinned GHA SHAs) + `cargo-deny` + optional weekly `sbomnix`/`vulnxscan` human/AI-reviewed.
4. **GitOps Governance & AI Agent Least-Privilege (`Perm-AgentApp` + Strict Rulesets)**: Trunk-Based Development (`feat/*`, `fix/*`, `agent/*`, `bot/*`), linear history, SSH commit signing, **`dix 3.0.0`** closure-diff + `aky` Cedar/SOPS blast-radius PR comments, stratified pre-commit (`gitleaks`, `aky check`, `aky secrets audit`, dynamic affected-host eval), scoped **`aky-agent[bot]`** GitHub App (1h ephemeral JWT, pushes branches + opens PRs, **zero merge permission**, human `LW-54` can formally review/approve), separate **`aky-ops[bot]`** for CI, strict PR-only `main` Ruleset, write-locked **`calibrated`** Ruleset (CI `main`-only bypass exclusively), and sensitive-path CI guard.
5. **Sovereign `3-2-1-1-0` Resilience (`M-FleetBare + Codeberg`)**: Fleet-wide `~3–15 MiB` auto-synced offline bare Git mirrors (`/var/lib/antikythera/repo.git`) on every non-ephemeral host (`0 MiB` idle RAM), `astrolabe` static Tailnet Caddy export of `calibrated/`, automatic push-mirror to **Codeberg** (EU non-profit hosted Forgejo — ~95% workflow parity, `0 MiB` VPS RAM), daily `0 MiB`-idle GitHub metadata JSON export (Issues/PRs/Reviews/Rulesets), dual-cloud encrypted backups to **Cloudflare R2 (WORM Bucket Locks, 30–90d)** + **Hetzner Storage Box (`hbox`)**, two-role TUF key custody (online CI Snapshot key vs offline Human Root key), and monthly `\$0`-egress automated restore drills.
<!-- abstract:end -->

# ADR-0013: GitOps Convergence (`P-AkyPull` + TUF), `BC-Niks3` on Cloudflare R2, Security PRs, `Perm-AgentApp` Governance & `M-FleetBare + Codeberg` Resilience

---

## 1. Context & Empirical Drivers
Stage `3B.3` realizes the dynamic convergence, build/cache, supply-chain governance, and disaster-resilience plane across all 8 fleet targets (`astrolabe`, `x240`, ZenBook, TUF, Chromebook, `aarch64` RPi, WSL, Live-ISO) and canonical repository **`LW-54/antikythera`**. Two dedicated research dossiers ([`RES-0017`](../research/RES-0017-gitops-tuf-binary-cache-and-repo-resilience.md), [`RES-0018`](../research/RES-0018-gitops-governance-agent-permissions-and-resilience.md)) and live benchmarks on `astrolabe` established five hard constraints:
1. **Local Nix evaluation OOMs small targets**: Measured cold `nix eval` peak RSS on `astrolabe` is **`661.7 MiB`** (`11.62 s`, minimal 4-agent `v2` skeleton) to **`905.9 MiB`** (`17.20 s`, full v1 production host) vs **`18.6 MiB`** (`0.25 s`) for zero-eval prebuilt metadata fetch — disqualifying target-side eval daemons (`comin`, `system.autoUpgrade`) for `1–2 GiB` Raspberry Pi nodes and battery-aware laptops.
2. **NixOS `26.11` ships native boot counting**: Verified `boot.loader.systemd-boot.bootCounting.{enable,tries}` + `systemd-bless-boot.service` in pinned `nixpkgs`, natively realizing `triadic_pull.qnt`'s `hostCrashMidSwitch` power-loss/kernel-panic recovery invariant alongside Lanzaboote (`ADR-0011`).
3. **`astrolabe` disk & CI secret surface**: `astrolabe`'s 100 GiB disk is already 52% full with 2 hosts, while v1 dual-pushed to local `atticd` + `Cachix` (`101 MiB` watcher) and required `SOPS_AGE_KEY` + `CACHIX_AUTH_TOKEN` in GitHub Secrets. `Mic92/niks3 1.16.0` (in pinned `nixpkgs`) eliminates all static CI cache secrets via GitHub OIDC and serves reads directly from Cloudflare R2 (`\$0` egress, user's preferred Cloudflare DNS/domain platform — also allowing complete retirement of Backblaze B2 across the stack).
4. **v1 AI-agent deploy-key blast radius**: A repo-wide SSH Write Deploy Key could push directly to unprotected branches (including `calibrated`), lacks distinct GitHub App audit identity, and cannot participate cleanly in solo-repo bot-author PR reviews.
5. **Repo size & lightweight-forge reality**: Our entire repo is only **`2.27 MiB` packed** (making fleet-wide offline bare mirrors essentially free), while no actively maintained, security-patched self-hosted full forge is lighter than `Forgejo` (`Gogs` was removed from `nixpkgs` after CISA-KEV RCE `CVE-2025-8110`).

---

## 2. Decision Outcome

### 2.1 Autonomous Pull & TUF Supply-Chain Defense (`P-AkyPull`)
- **Signed TUF Calibration Manifest**: Post-merge `main` CI (after all verification gates and R2 cache pushes succeed) generates deterministic `calibration.json` (`{ version, epoch, git_rev, issued_at, expires_at, hosts: { <id>: { system, toplevel } } }`), signs it with a `main`-only GitHub Environment Ed25519 key (`CALIBRATION_SIGNING_KEY`), and publishes `calibration.json` + `.sig` to ruleset-locked orphan branch **`calibrated`**.
- **Two-Role TUF Key Custody**:
  - **Online CI Snapshot Key**: Signs routine `main` calibrations; rotatable via PR + Environment update; bounded epoch jump prevents arbitrary fast-forward bricking.
  - **Offline Human Root TUF Key** (stored in offline break-glass kit + Vaultwarden): Can sign emergency calibrations on the self-hosted mirror during a GitHub outage **and** sign `root_rotation` / `epoch_reset` payloads if the CI key is ever compromised.
- **Host Pull State Machine (`aky pull`, ~400 LOC Rust in `crates/aky-cli`, systemd timer)**:
  1. Checks host-declared proper-time conditions (unattended on `astrolabe`/`rpi`; AC + unmetered Wi-Fi or manual opt-in on roaming laptops; disabled on `live-iso`).
  2. Fetches `calibration.json` + `.sig` with automatic fallback (`GitHub Raw` → `Codeberg` → `https://mirror.astrolabe.<tailnet>.ts.net/calibrated/`).
  3. Verifies Ed25519 signature, strict monotonic `epoch > max_seen_epoch` (persisted atomically at `/persist/var/lib/aky/pull-state.json` or `/var/lib/aky/pull-state.json`), `now <= expires_at`, and `now - issued_at <= max_staleness` (else emits `aky_pull_freeze_alert = 1` metric to `E3` / Alertmanager → `ntfy`).
  4. Acquires `flock(/run/aky-switch.lock)` (shared with interactive `L3+` `aky switch` & `aky switch --test`), fetches closure strictly cache-only (`--max-jobs 0`, `~20 MiB` RSS, zero local eval/compile), and executes:
     - `<new>/bin/switch-to-configuration test`
     - Host **Tri-Purpose Survival Probes ($\alpha$)**: `sshd`, `tailscaled`, critical systemd units, core local HTTP endpoints (`vaultwarden`/`caddy`).
     - **PASS**: `nix-env -p /nix/var/nix/profiles/system --set <new>` + `<new>/bin/switch-to-configuration boot` (with `boot.loader.systemd-boot.bootCounting.enable = true`), commits `last_healthy` & `max_seen_epoch`, emits `FOLLOWS` provenance & Prometheus textfile metrics, and fetches latest delta into local `/var/lib/antikythera/repo.git`.
     - **FAIL**: Atomic rollback `<last_healthy>/bin/switch-to-configuration test`, advances `max_seen_epoch = bad_epoch` (preventing crash loops), increments `rollback_count`, alerts via `ntfy`.
     - **Mid-Switch Power Loss / Kernel Panic**: Bootloader still defaults to `last_healthy` (and post-reboot crashes decrement `bootCounting` tries to auto-fallback via `systemd-bless-boot`); tmpfs lock clears cleanly.

### 2.2 Binary Cache & Multi-Arch Build Plane (`BC-Niks3` + Cloudflare R2 + `ubuntu-24.04-arm`)
- **Binary Cache Agent (`+b: binary-cache`)**: Sealed `Mic92/niks3` (`v1.16.0` in pinned `nixpkgs`, PostgreSQL reference-tracking GC on `astrolabe`, `~65 MiB` combined RSS) backed by a dedicated **Cloudflare R2** bucket on custom domain **`https://cache.adje.app`** (`\$0` egress, `10 GB` free tier, direct R2 CDN reads completely independent of `astrolabe` uptime/reinstalls, `0 GiB` VPS blob storage).
- **Zero Static CI Cache Secrets**: GitHub Actions authenticates to `niks3-server` via **native GitHub OIDC** (`bound_subject = "repo:LW-54/antikythera:ref:refs/heads/main"`). Retires `atticd`, `cachix-watch-store-agent` (`-101 MiB` RAM), `secrets/ci/attic.yaml`, `CACHIX_AUTH_TOKEN`, `SOPS_AGE_KEY` from GitHub Secrets, and **retires Backblaze B2 completely** (consolidating object storage onto Cloudflare R2 globally across `3B.3` and `3C.1`).
- **Multi-Arch CI Stratification**:
  - `x86_64-linux` (`ubuntu-latest` with `/dev/kvm`): `aky check`, `schemas`, `eval-*`, `inspect-*`, KVM `vm-*`/`install-*`, Rust/Lean/Quint gates, `x86_64` toplevels/packages.
  - `aarch64-linux` (free native 4-vCPU `ubuntu-24.04-arm`, no `/dev/kvm`): `eval-rpi`, `inspect-rpi`, `aky` ARM64 tests/build, native `rpi` toplevel + `sdImage` pushed directly to R2.
  - Preserves v1's `.narinfo` cache-skip optimization and automated `README.md` cache-isolation probe.

### 2.3 Automated Security & Dependency PRs (`U-SplitGHA` + `Auto-Tiered`)
- **Single Fleet `nixpkgs/nixos-unstable` Input**: Keeps Vaultwarden, Tailscale, Caddy, OpenSSH, and kernel synchronized with upstream fixes and Bitwarden clients across one shared store-closure family.
- **2-Track Isolated Flake Updater (`U-SplitGHA`)**: Uses scoped CI GitHub App **`aky-ops[bot]`** (`actions/create-github-app-token`, 1h JWT — triggers full `on: pull_request` CI with zero personal PAT):
  - **Daily `nixpkgs` Track (`bot/update-nixpkgs`)**: Isolated PR updating *only* `nixpkgs` so broken desktop flakes never block security updates.
  - **Weekly Auxiliary Track (`bot/update-<input>`)**: Isolated PRs per third-party flake (`sops-nix`, `hjem`, `impermanence`, `disko`, `crane`, `noctalia`, `antigravity-nix`, `helium`).
- **Rust, GHA & CVE Scanning**: GitHub built-in **Dependabot** handles `v2/Cargo.lock` + pinned `.github/workflows` SHAs; CI runs `cargo-deny check advisories`; optional weekly **`sbomnix` / `vulnxscan`** scans `astrolabe`'s closure with Nix-patch awareness and alerts `ntfy` only on new unpatched High/Critical CVEs.
- **Auto-Merge Policy (`Auto-Tiered`)**:
  - Daily `bot/update-nixpkgs` PRs **auto-merge ONLY when 100% of required CI passes** (including KVM `vm-astrolabe` booting real Vaultwarden + Caddy + `aarch64` build) + send an `ntfy` digest.
  - Third-party flakes, `Cargo.lock`, GHA bumps, and all AI-agent PRs **never auto-merge** (explicit human review required).

### 2.4 GitOps Governance, PR UX & AI Agent Permissions (`Perm-AgentApp`)
- **Repository & Branch Methodology**: Canonical repo **`LW-54/antikythera`**, Trunk-Based Development, short-lived branches (`feat/*`, `fix/*`, `refactor/*`, `chore/*`, `docs/*`, `design/*` for humans; **`agent/*`** for AI agents; **`bot/*`** for updaters), linear history (squash/rebase), Conventional Commits (`<type>: <description>`), and native Git **SSH commit signing** for human commits.
- **High-Signal PR Telemetry & Live Staging**: Every PR receives one auto-updated summary comment with **`dix 3.0.0`** closure diffs per affected host + **`aky` boundary/Cedar/SOPS blast-radius diff**. Operators stage risky PRs locally via `aky switch --test` before merging.
- **Three-Tier Verification Stratification**:
  1. **Local Pre-Commit (`< 1–10 s`)**: staged `alejandra`/`rustfmt`, **`gitleaks protect --staged`**, `aky check` (`2.4 ms`), `aky secrets audit` (`< 2 ms`), commit-msg format check, and dynamically discovered affected-host `eval` + `schemas`.
  2. **PR CI (`0` secrets)**: full `eval`/`inspect`/`dix` diff, KVM `vm-*`, `aarch64` native build, Rust/Lean/Quint gates, cache-isolation guard, and **sensitive-path CI guard** (flags `.github/workflows/**`, `v2/policies/**`, `v2/formal/**`, `secrets/**`, `AGENTS.md`, `.gemini/**` and blocks auto-merge).
  3. **Post-Merge `main` CI (`main`-only Environment)**: `BC-Niks3` OIDC push → sign & publish `calibration.json` to `calibrated` → `install-*` disk tests on disk-diff/cooldown.
- **Strict Identity Separation & Free GitHub Rulesets**:
  - **`LW-54` (Human)**: Strict PR-only normal workflow on `main` (admin bypass strictly for break-glass emergencies); can formally review & approve `[bot]` PRs without hitting GitHub's solo-author self-approval catch-22.
  - **`aky-agent[bot]` (`Perm-AgentApp`)**: Scoped GitHub App bound solely to `LW-54/antikythera` (`Contents: write`, `Pull requests: write`, 1h ephemeral JWT via local `aky git-cred`, retaining v1's strict systemd `ProtectSystem=strict` + `InaccessiblePaths` sandbox); pushes `agent/*` branches and opens clean PRs, **locked out of `main` and `calibrated` by Rulesets and barred from merging**.
  - **`aky-ops[bot]`**: Separate CI-only GitHub App for `U-SplitGHA` PR creation and exclusive bypass on the **`calibrated`** Ruleset.
  - **Deferred**: CNCF `gittuf 0.16.0` (redundant with `P-AkyPull` TUF end-to-end verification on a solo repo; revisit if multi-maintainer).

### 2.5 Sovereign `3-2-1-1-0` Resilience (`M-FleetBare + Codeberg`) & `M1-Sunset` Cutover Hook
- **Fleet-Wide Offline Bare Mirrors**: Every non-ephemeral host (`astrolabe`, laptops, `rpi`, `wsl`) auto-syncs `/var/lib/antikythera/repo.git` (`~3–15 MiB` disk, `0 MiB` idle RAM) in lockstep with `P-AkyPull` / timer ticks for 100% offline history, `aky check`, and decentralized redundancy.
- **Tailnet Break-Glass Endpoint (`astrolabe`)**: `systemd` timer updates bare mirror every 15 min (outbound HTTPS pull — zero inbound creds) and atomically extracts `calibrated/calibration.{json,sig}` to static Tailnet Caddy (`https://mirror.astrolabe.<tailnet>.ts.net/calibrated/`, `0 MiB` extra RAM); emergency pushes over Tailscale SSH + `aky calibrate --sign-human` keep the fleet converging even during a full GitHub outage.
- **Secondary Hosted Forge Failover (`Codeberg`)**: Free automatic push-mirror on `main` + `calibrated` to **Codeberg** (EU non-profit hosted Forgejo — `0 MiB` VPS RAM, ~95% `.github/workflows` parity via Forgejo Actions, 1:1 path to self-hosted `services.forgejo` later if ever desired).
- **Full `3-2-1-1-0` Metadata & Dual-Cloud Protection**:
  - Daily `0 MiB`-idle systemd timer exports GitHub Issues, PR discussions, Reviews, Releases, and Ruleset JSON (`gh api` / `gickup`) to `/var/lib/antikythera/metadata/`.
  - Encrypted backups replicated to **both** **Cloudflare R2 (with 30–90d WORM Bucket Locks)** **and** **Hetzner Storage Box (`hbox`)** (independent cloud provider against Cloudflare lockout).
  - Monthly automated `\$0`-egress restore drill (`git bundle verify` + bare-mirror clone + Restic verify → `ntfy` alert on any error).
- **`M1-Sunset` Cutover Hook**: During Phase 4 cutover (`x240` → `astrolabe`), `niks3` + R2 + `P-AkyPull` + bare mirrors stand up cleanly alongside v1's Attic; once cutover passes, v1 `atticd`, `cachix-watch-store-agent`, `secrets/ci/attic.yaml`, `SOPS_AGE_KEY` in GitHub Secrets, static `agy-git-deploy-key`, and all Backblaze B2 configuration are **100% deleted**.

---

## 3. Consequences
- **Positive**: Completes **Stage `3B` (All 3 Cross-Cutting Planes)** cleanly; achieves zero-eval `< 20 MiB` TUF-hardened autonomous updates across `x86_64` and `aarch64`; eliminates all static CI binary-cache & SOPS secrets from GitHub Actions; retires Backblaze B2, Attic, and Cachix watcher; hardens AI-agent GitHub permissions with strict Rulesets + `gitleaks` + `dix` PR diffs; and satisfies full `3-2-1-1-0` control-plane durability at `0 MiB` extra forge RAM.
- **Risks & Mitigations**:
  - `niks3` requires PostgreSQL on `astrolabe` (~40 MiB RAM) and a small custom NixOS service unit (or external `Mic92/niks3` module) → negligible on 11 GiB VPS (and cleanly reusable if `Forgejo` or other services ever need Postgres later), verified via Phase 4 QEMU VM tests.
  - `P-AkyPull` adds ~400 LOC Rust in `crates/aky-cli` → directly verified against our existing 1.87M-state Quint spec (`triadic_pull.qnt`), Rust unit tests, and Phase 4 QEMU rollback/crash fault-injection tests (`A-008`).

## 4. Links
- Realizes: [`ADR-0005`](ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md), [`ADR-0006`](ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md), [`ADR-0007`](ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md), [`triadic_pull.qnt`](../../v2/formal/quint/triadic_pull.qnt)
- Research & Benchmarks: [`RES-0017`](../research/RES-0017-gitops-tuf-binary-cache-and-repo-resilience.md), [`RES-0018`](../research/RES-0018-gitops-governance-agent-permissions-and-resilience.md)
- Integrates with: [`ADR-0011`](ADR-0011-trust-plane-sops-cedar-custody-and-pragmatic-capabilities.md), [`ADR-0012`](ADR-0012-mesh-fabric-tailscale-dual-ssh-and-split-horizon-tls.md)
