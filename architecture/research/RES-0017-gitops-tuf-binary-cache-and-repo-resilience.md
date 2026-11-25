---
id: RES-0017
title: Stage 3B.3 Research — Triadic Autonomous Pull (C3 + TUF), Binary Caching, Multi-Arch CI, Security PRs & Repo Resilience
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: gitops
tags: [research, stage-3b3, gitops, tuf, comin, auto-upgrade, systemd-bless-boot, binary-cache, niks3, attic, celler, harmonia, cachix, aarch64, renovate, forgejo, git-mirror, a-008]
assumptions: [A-008, A-009]
summary: Wide-spectrum 2025-2026 theoretical, empirical, and practical research for Stage 3B.3 covering pull-based NixOS convergence with TUF supply-chain defense, binary cache backends and multi-arch aarch64 CI, automated security PR workflows (Vaultwarden/nixpkgs), and self-hosted Git mirrors — grounded in live astrolabe measurements and pinned nixpkgs 26.11 inspection.
---

<!-- abstract:start -->
## Executive Abstract

Surveys the full 2025–2026 design space for **Stage `3B.3` (`C3` Triadic Calibrated Autonomous Pull + TUF Supply-Chain Defense, Binary Cache, Multi-Arch `aarch64` CI, Automated Security PRs, and Self-Hosted Git Mirror)** against [`ADR-0005`](../adrs/ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md), the TLC-verified Quint protocol [`triadic_pull.qnt`](../../v2/formal/quint/triadic_pull.qnt) (`1,878,049` states), [`CHARTER.md`](../CHARTER.md) (`B > E > D > A > C`, `QA-06`, `QA-07`, `QA-08`, `QA-10`), and Assumption `A-008`.

**Four pivotal empirical & 2025–2026 ecosystem findings reshaped the design space**:
1. **Local Nix Eval Peak RSS Disqualifies Target-Side Eval on Constrained Hosts (Measured Empirically on `astrolabe`)**: Evaluating even our minimal 4-agent `v2` skeleton consumes **`661.7 MiB` peak RSS (`11.62 s`)**, and production `v1` `astrolabe` consumes **`905.9 MiB` peak RSS (`17.20 s`)** — whereas fetching a pre-built store path / `.narinfo` metadata consumes **`18.6 MiB` peak RSS (`0.25 s`)**, a **48.7× RAM reduction and 68.8× speedup**. Neither `nlewo/comin` (external Go flake input; Issue #8 *"Avoid Nix evaluation on the target"* still unresolved; no native TUF anti-rollback/anti-freeze; no `test` → `α` survival probe → rollback transaction) nor `system.autoUpgrade` satisfies our formal `triadic_pull.qnt` invariants on 1–4 GiB ARM boards and roaming laptops.
2. **Native NixOS `bootCounting` + `systemd-bless-boot` Exists in Pinned `nixpkgs 26.11`**: Inspected [`systemd-boot.nix`](/nix/store/p7yx739q7ips4f9a1a26k509id1kd85i-source/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L421-L439) directly — `boot.loader.systemd-boot.bootCounting.{enable,tries}` is built into our pinned `nixpkgs`, directly realizing `triadic_pull.qnt`'s `hostCrashMidSwitch` kernel-panic / power-loss recovery invariant alongside Lanzaboote (`ADR-0011`).
3. **2026 Binary Cache Shift (`Mic92/niks3 1.16.0` vs `attic` / `celler` vs `harmonia 3.3.0`)**: Upstream `zhaofengli/attic` (pinned `2026-07-06` in `nixpkgs`) has slower upstream velocity (sparking the `celler` Rust-daemon fork), while **`Mic92/niks3` (`v1.16.0` already in pinned `nixpkgs`)** introduced direct-to-S3 reads/uploads (zero SPOF on `astrolabe`, zero `astrolabe` 100 GiB disk consumption — currently 52% full), reference-tracking GC (PostgreSQL metadata), and **native GitHub Actions OIDC** — completely eliminating `SOPS_AGE_KEY`, `ATTIC_TOKEN`, and `CACHIX_AUTH_TOKEN` from CI and freeing `101 MiB` RAM by retiring `cachix-watch-store-agent`. Meanwhile, v1 already has **Backblaze B2 (`eu-central-003`)** configured (`\$0.007/GB/mo` + 3× free egress), and **Cloudflare R2** offers `10 GB` free + `\$0` egress.
4. **Native Free `aarch64` CI (`ubuntu-24.04-arm`) Has No `/dev/kvm`**: GitHub Actions provides free 4-vCPU Ampere `ubuntu-24.04-arm` runners on public repos for native ARM64 builds (`eval-rpi`, `inspect-rpi`, `rpi` toplevel + `sdImage`, `aky` ARM64), eliminating slow QEMU emulation — while Azure ARM64 lacks nested `/dev/kvm`, cleanly stratifying KVM VM tests to `x86_64` (`ubuntu-latest`) and native closure builds to `ubuntu-24.04-arm`.
<!-- abstract:end -->

# RES-0017: Triadic Autonomous Pull (`C3` + TUF), Binary Caching, Multi-Arch CI, Security PRs & Repo Resilience

---

## 1. Empirical Baseline: v1 Audit & Live `astrolabe` Benchmarks

### 1.1 v1 State Inspected on Disk
- **CI Workflows** ([`.github/workflows/build.yml`](../../.github/workflows/build.yml), [`.github/workflows/host-tests.yml`](../../.github/workflows/host-tests.yml)):
  - Strong `.narinfo` cache-skip pattern (`~49 s` CI wall time on hits) + automated `README.md` cache-isolation probe (`meta/ci/build.nix`).
  - Dual-pushes every artifact to **both** self-hosted Attic (`https://cache.adje.app/nixconf`) **and** Cachix (`https://lw-54.cachix.org`), plus runs `cachix-watch-store-agent` (`101 MiB` RSS) on `astrolabe`.
  - Requires `SOPS_AGE_KEY` in GitHub Secrets **solely** to decrypt [`secrets/ci/attic.yaml`](../../secrets/ci/attic.yaml) (the only file in `secrets/ci/`) + static `CACHIX_AUTH_TOKEN`.
  - Strictly `x86_64-linux` only; zero automated security/flake update PRs; zero host pull convergence (`just switch` is manual).
- **Live `astrolabe` Resource & Storage Measurements (2026-11-25)**:
  - `atticd.service`: active, `MemoryCurrent = 45.3 MiB`, `MemoryPeak = 539.1 MiB`, SQLite + local disk storage (`/var/lib/atticd/storage`).
  - Root/store filesystem (`/dev/mapper/system-root` backing `/nix` & `/persist`): **`51 GiB / 100 GiB (52% used)`** with only 2 hosts (`astrolabe`, `x240`) — before adding `zenbook`, `tuf`, `chromebook`, `rpi`, `wsl`, and `live-iso` (8 total targets).
  - Existing cloud object storage in [`modules/contracts/storage/providers.nix`](../../modules/contracts/storage/providers.nix): **Backblaze B2** (`eu-central-003`, `https://s3.eu-central-003.backblazeb2.com`), **Hetzner Storage Box** (`hbox`), **Google Drive** (`gdrive`).
  - Existing `nixpkgs` channel in [`.tack/pins.lock.json`](../../.tack/pins.lock.json): tracks **`NixOS/nixpkgs/nixos-unstable`**.

### 1.2 Empirical Experiment (`EXP-0010` Inline): Local Target Nix Eval vs. Zero-Eval Pre-Built Pull
Measured via Python `os.wait4` (`ru_maxrss`) on `astrolabe` (2026-11-25, `--no-eval-cache` cold evaluation matching a fresh Git commit pull):

| Workload | Exit Code | Wall Time | Peak RSS | Ratio vs. Zero-Eval |
| :--- | :---: | ---: | ---: | ---: |
| `nix eval ./v2#nixosConfigurations.astrolabe...toplevel.outPath` *(4-agent minimal skeleton)* | `0` | `11.62 s` | **`661.7 MiB`** | `35.6× RAM` / `46.5× time` |
| `nix eval .#nixosConfigurations.astrolabe...toplevel.outPath` *(full v1 production host)* | `0` | `17.20 s` | **`905.9 MiB`** | **`48.7× RAM` / `68.8× time`** |
| `curl -fsS https://cache.adje.app/nixconf/nix-cache-info` *(zero-eval metadata fetch)* | `0` | **`0.25 s`** | **`18.6 MiB`** | `1.0×` baseline |

> **Engineering Conclusion**: Any pull engine that evaluates NixOS flakes on the target host (`comin`, `system.autoUpgrade`) inflicts a `660–906+ MiB` RAM spike (and higher for desktop hosts with KDE/Hyprland/Wayland closures) on every commit check — risking OOM kills on `1–2 GiB` Raspberry Pi nodes and draining battery/CPU on roaming laptops. Decoupling **Evaluation/Build (CI)** from **Verification/Fetch/Switch (Host)** eliminates this entire class of failures.

### 1.3 Pinned `nixpkgs` (`1d06008`, `26.11`) Verified Inventory
| Tool / Package | Pinned Version | NixOS Module in `nixpkgs`? | Notes |
| :--- | :--- | :---: | :--- |
| `comin` | **missing** | No | Requires external Go flake input (`nlewo/comin`) |
| `system.autoUpgrade` | built-in (`26.11`) | Yes (`tasks/auto-upgrade.nix`) | Runs local `nixos-rebuild` on timer |
| `boot.loader.systemd-boot.bootCounting` | built-in (`26.11`) | Yes (`systemd-boot.nix:421`) | UAPI boot counting + `systemd-bless-boot.service`! |
| `attic-server` / `attic-client` | `0-unstable-2026-07-06` | Yes (`services.atticd`) | Hydra-tested (`nixosTests.atticd`), Nix 2.34, SQLite or Postgres, local or S3 |
| `niks3` (`Mic92/niks3`) | **`1.16.0`** | No *(external flake or ~35-LOC unit)* | Direct S3 reads/uploads, Postgres GC tracking, native GitHub Actions OIDC |
| `harmonia` | `3.3.0` | Yes (`services.harmonia`) | Serves local `/nix/store` + new `harmonia.gc` |
| `cachix` | `1.12.1` | Yes | 5 GB free public SaaS; \$29+/mo paid |
| `celler` | **missing** | No | Community Attic fork dropping `libnixstore` C++ FFI |
| `deploy-rs` / `colmena` | `1.0.0` / `0.5.0` | N/A (CLI) | Push-based SSH deployment tools |
| `nix-fast-build` / `nixos-rebuild-ng` | `2.0.4` / `26.11` | N/A (CLI) | Fast parallel eval/build & modern Python rebuild |
| `forgejo` | `17.0.1` | Yes (`services.forgejo`) | Full self-hosted forge (~150–450 MiB RAM idle→active) |
| `cgit` / `stagit` | `1.3.1` / `1.3` | Yes (`services.cgit`) | `0 MiB` idle RAM read-only web UI over bare Git |
| `soft-serve` | `0.12.4` | No | **Sunsetted by Charmbracelet** — avoid new dependency |
| `radicle` | present | Yes (`services.radicle`) | P2P Git (`rad` CLI paradigm shift) |
| `renovate` / `nix-update` | `44.181.0` / `1.16.0` | N/A | Automated dependency update tooling |
| `minisign` / `cosign` | `0.12` / `3.1.3` | N/A | Cryptographic signing (Rust `ed25519-dalek` also native in `aky`) |

---

## 2. Dimension 1 — Autonomous Pull Convergence & TUF Supply-Chain Defense (`C3`)

### 2.1 Theoretical Grounding: Mapping The Update Framework (TUF) to NixOS + `triadic_pull.qnt`
Nix's content-addressed NAR hashes + `trusted-public-keys` authenticate **what** a binary closure contains, **NOT** repository-level metadata freshness or ordering. A compromised Git host, binary cache mirror, or MITM relay can execute three classical TUF attacks:
1. **Rollback Attack**: Serve an older, validly-signed Git commit or closure containing a patched-since CVE (e.g., an older Vaultwarden build).
2. **Freeze Attack**: Indefinitely replay the last valid metadata so hosts silently stop receiving security patches.
3. **Mix-and-Match Attack**: Combine host A's new closure with host B's old closure or mismatch source commit vs. prebuilt store path.

Our TLC-verified Quint specification ([`v2/formal/quint/triadic_pull.qnt`](../../v2/formal/quint/triadic_pull.qnt), `1,878,049` states, 0 invariant violations) proves 4 safety invariants (`invNeverActivatesForged`, `invCommittedAlwaysHealthy`, `invMonotonicHealthyLineage`, `invLockMatchesPending`) require five concrete mechanisms:
1. **Signed Atomic Fleet Snapshot (`calibration.json` + Ed25519 `.sig`)**: `{ epoch, git_rev, issued_at, expires_at, hosts: { <id>: { system, toplevel } } }` — prevents mix-and-match and eliminates local target Nix evaluation.
2. **Persisted Monotonic Watermark (`max_seen_epoch`)**: Stored atomically on `/persist/var/lib/aky/pull-state.json` (or `/var/lib/aky/pull-state.json` on non-impermanent hosts); rejects `epoch <= max_seen_epoch` (anti-rollback), with bounded step or `role:human-root` signed `epoch_reset` defeating fast-forward attacks if an online CI key were ever compromised.
3. **Bounded Freshness Window ($\Delta t$)**: Checks `now <= expires_at` and `now - issued_at <= max_staleness`; raises `aky_pull_freeze_alert = 1` to observability/alerting if stale (anti-freeze).
4. **Shared Local Serialization Lock (`flock /run/aky-switch.lock`)**: Cleanly serializes background `aky pull` against interactive `L3+` human `aky switch`.
5. **Two-Phase Self-Assessing Switch + Crash Recovery**:
   - Fetch closure with `--max-jobs 0` (**cache-hit-only**, zero accidental local compilation).
   - Activate via `<new>/bin/switch-to-configuration test` (does **not** overwrite boot default yet!).
   - Execute host's declared **Tri-Purpose Survival Probes ($\alpha$)** (`sshd`, `tailscaled`, critical systemd units, core local HTTP endpoints like `vaultwarden`/`caddy`).
   - **Pass**: `nix-env -p /nix/var/nix/profiles/system --set <new>` + `<new>/bin/switch-to-configuration boot` (with `boot.loader.systemd-boot.bootCounting.enable = true` so even a post-reboot kernel panic auto-falls back via `systemd-bless-boot`!), commit `last_healthy` & `FOLLOWS` provenance.
   - **Fail**: Atomic rollback `<last_healthy>/bin/switch-to-configuration test`, advance `max_seen_epoch = bad_epoch` (preventing crash-loops), increment `rollback_count`, emit alert!
   - **Mid-switch power loss**: Bootloader still points to `last_healthy`, tmpfs `/run/aky-switch.lock` clears on boot → boots straight back into `last_healthy`.

### 2.2 Full Contender Comparison

| Contender | Target RAM | TUF Anti-Rollback / Anti-Freeze | Health-Gated Auto-Rollback ($\alpha$) | Crash-Safe Boot Counting | Host Proper-Time Conditions (AC / Unmetered / Manual) | Mirror Failover | Deps / Maintenance |
| :--- | ---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **`P-AkyPull`** *(Thin ~400-LOC Rust `aky pull` timer + signed `calibration.json` on orphan `calibrated` branch/HTTPS)* | **`~20 MiB`** *(0 Nix eval!)* | **Full native** *(Ed25519 + persisted `max_seen_epoch` + $\Delta t$ alert)* | **Full native** *(`test` → $\alpha$ probes → `boot` or atomic rollback)* | **Native** *(`systemd-boot.bootCounting` + `test` before `boot`)* | **Full native** *(declared per host: unattended VPS/RPi, AC+unmetered or manual laptops, off on ISO)* | **Full native** *(GitHub Raw → self-hosted mirror over Tailnet)* | **0 new flake inputs** *(lives in existing `crates/aky-cli`, Ed25519 via `ed25519-dalek`)* |
| **`P-Comin`** *(`nlewo/comin` external Go daemon)* | `660–906+ MiB` *(local Nix eval!)* | Partial *(GPG/SSH commit sig only — vulnerable to replay/rollback & freeze)* | **No** *(runs `switch` directly; `postDeploymentCommand` is post-hoc only)* | Manual only | Partial *(polling only; no AC/metered-Wi-Fi gate)* | Yes *(multi-remote)* | External Go flake input (not in `nixpkgs`); separate CLI/metrics/state |
| **`P-AutoUpgrade`** *(built-in `system.autoUpgrade`)* | `660–906+ MiB` *(local Nix eval!)* | **None** | **None** | Optional `bootCounting` | Timer schedule only | **No** | Built into `nixpkgs` |
| **`P-Push`** *(`colmena` / `deploy-rs`)* | Low on target | **None** | `deploy-rs` magic-rollback (push-only; slower upstream) | Optional | **Fails on sleeping/NAT laptops**; violates `ADR-0005` `C3` | Manual | In `nixpkgs` *(optional human interactive tool only)* |
| **`P-Hybrid`** *(`comin` on VPS/laptops + custom script on RPi)* | High on VPS/laptops, low on RPi | Split / incomplete | Missing on `astrolabe` (highest-risk host!) | Split | Split | Split | Violates `X1` / `QA-03` uniformity (2 deployment stacks to test & maintain) |

**Key UX & AI-Agent (`QA-10`) Note for `P-AkyPull`**:
- **Zero GUI clicks**: CI automatically publishes signed `calibration.json` to orphan branch `refs/heads/calibrated` (auto-mirrored to our self-hosted Git mirror!) after `main` passes all checks and cache pushes.
- **Dual-Authority Break-Glass**: Hosts accept signatures from **either** (a) the `main`-only CI Snapshot Ed25519 key **or** (b) `role:human-root`'s offline Ed25519 key (allowing full fleet convergence from our self-hosted mirror if GitHub goes down!).
- **Interactive Escape Hatch (`L3+`)**: `aky switch` acquires the exact same `/run/aky-switch.lock` and uses the same `test` → $\alpha$ → `boot` pipeline; `aky status --json` exposes exact epoch, closure, staleness, freeze alert, and rollback history to humans and AI agents.

---

## 3. Dimension 2 — Binary Cache Backend & Multi-Arch (`x86_64` + `aarch64`) Build Plane

### 3.1 Binary Cache Contenders (2026 Landscape)

| Contender | Storage / Read Path | CI Push Auth (Secrets Eliminated?) | `astrolabe` RAM / Disk Impact | Survives `astrolabe` Wipe / Reboot? | Dedup & GC | Upstream Health (2026) | Est. Monthly Cost |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| **`BC-Niks3-R2`** *(`Mic92/niks3 1.16.0` on `astrolabe` + Postgres + Cloudflare R2)* | **Direct R2 CDN reads** & presigned uploads *(bypasses `astrolabe`!)* | **Native GitHub OIDC!** *(0 static push tokens; **eliminates `SOPS_AGE_KEY` & `CACHIX_AUTH_TOKEN` from CI!**)* | `~25 MiB` `niks3-server` + `~40 MiB` Postgres; **`0 GiB` blob disk on VPS!** *(retiring `atticd` + `cachix-watch-store` saves `~146–640 MiB` peak RSS!)* | **YES** *(reads stay 100% online even if `astrolabe` is powered off / reinstalling from Live-ISO!)* | Reference-tracking GC over S3 *(whole-NAR; no sub-NAR chunking)* | **Very active** (`Mic92`, `v1.16.0` in `nixpkgs`, `niks3-action`) | **\$0** (≤10 GB R2 free + \$0 egress); ~\$0.15/mo at 20 GB |
| **`BC-Niks3-B2`** *(`Mic92/niks3 1.16.0` on `astrolabe` + Postgres + existing Backblaze B2 `eu-central-003`)* | **Direct B2 S3 reads** & presigned uploads *(uses existing B2 account — zero new cloud vendor!)* | **Native GitHub OIDC!** *(same zero-CI-secret win!)* | Same (`~65 MiB` total RSS, **`0 GiB` blob disk on VPS!**) | **YES** | Reference-tracking GC over S3 | **Very active** | **~\$0.07–0.21/mo** (`\$0.007/GB`, 3× free egress; \$0 via Cloudflare Bandwidth Alliance) |
| **`BC-AtticB2`** *(`atticd` SQLite on `astrolabe` + existing Backblaze B2 S3 backend)* | Presigned B2 redirects via `atticd` on `astrolabe` | Static RS256 JWT (`secrets/ci/attic.yaml` + `SOPS_AGE_KEY` in GitHub Secrets) | `45 MiB` idle / `539 MiB` peak RSS, **no Postgres**, **`0 GiB` blob disk on VPS!** | Partial *(blobs survive wipe, but reads pause while `astrolabe` is down)* | **Global content-defined chunking (50–60% savings)** + LRU GC *(note: high small-object PUT/GET count; B2 transactions are free)* | In `nixpkgs` (`2026-07-06`, Nix 2.34), slower upstream; `celler` fork exists | **~\$0.05–0.14/mo** (B2 storage) |
| **`BC-AtticLocal`** *(current v1: `atticd` SQLite + local disk on `astrolabe` + Cachix backup)* | Proxied through `astrolabe` local disk | Static RS256 JWT + `SOPS_AGE_KEY` + `CACHIX_AUTH_TOKEN` | `45–539 MiB` Attic + `101 MiB` Cachix watcher; **eats `astrolabe` 100 GiB disk (already 52% full!)** | **No** *(VPS wipe loses Attic; Cachix capped at 5 GB)* | Global chunking + LRU GC | Same as above | **\$0** |
| **`BC-Harmonia`** *(`harmonia 3.3.0` serving `/nix/store`)* | Direct from host `/nix/store` | Requires SSH `nix copy` with **`trusted-users` (root-equivalent on `astrolabe`!)** | Pollutes `astrolabe` `/nix/store` with 8 hosts + `aarch64` paths | No | Local Nix GC | Very active (`nix-community`) | **\$0** *(best saved for `3C.1` LAN/Tailnet peer cache on TUF laptop!)* |
| **`BC-Cachix`** *(SaaS only)* | Cachix Cloud CDN | Static `CACHIX_AUTH_TOKEN` | `0 MiB` / `0 GiB` on `astrolabe` | Yes | Managed LRU GC | Very active | **\$0** (5 GB cap — too tight for `x86_64`+`aarch64`+8 hosts+Rust/Lean!) / **\$29+/mo** paid |

> **Architectural Synergy (`ADR-0002` / `QA-02`)**: Because binary cache is an Agent offering `+b: binary-cache(url, pubkey)`, any host or CI consumer only binds `-b: binary-cache`. Swapping `atticd` ↔ `niks3` ↔ `celler` (or running Attic + NikS3 side-by-side during `M1-Sunset` cutover) requires zero edits to host definitions.
> **Critical Security Discovery**: Choosing **`BC-Niks3` (B2 or R2)** + a `main`-only GitHub Environment `CALIBRATION_SIGNING_KEY` **removes `SOPS_AGE_KEY`, `ATTIC_TOKEN`, and `CACHIX_AUTH_TOKEN` from GitHub Actions completely** — PR workflows touch **zero secrets**, and `github_actions` is eliminated as a SOPS age recipient!

### 3.2 Multi-Arch (`x86_64-linux` + `aarch64-linux`) CI & Builder Matrix
| Build Plane | `x86_64-linux` (incl. KVM VM Tests) | `aarch64-linux` (RPi / ARM Chromebook) | Cost & Maintenance |
| :--- | :--- | :--- | :--- |
| **`CI-GHA-MultiArch`** *(GitHub Actions `ubuntu-latest` + native 4-vCPU `ubuntu-24.04-arm` + `.narinfo` cache-skip)* | Full `aky check`, `schemas`, `eval`, `inspect`, **KVM `vm`/`install`**, Rust/Lean/Quint gates, builds all `x86_64` toplevels/packages | **Native 4-vCPU Ampere ARM64** runs `eval-rpi`, `inspect-rpi`, `aky` ARM64, builds `rpi` toplevel + `sdImage` natively (no QEMU binfmt!). *Note: Azure ARM64 lacks `/dev/kvm`, so runtime service VM tests run on `x86_64` shared capability agents + on-device $\alpha$ probes.* | **\$0** on public repo; already integrated; zero runner maintenance! |
| **`CI-Garnix`** *(Managed Nix SaaS)* | Automatic flake eval/build + hot store | Automatic native `aarch64` | Free public / paid private; less flexible for custom Lean/Quint/TUF `calibration.json` publishing |
| **`CI-BuildbotNix`** *(Self-hosted)* | Requires self-hosted `x86_64` workers | Requires always-on self-hosted `aarch64` worker | High ops burden (`D` penalty) on 11 GiB VPS |
| **`3C.1` Bridge (Opportunistic Local Builders)** | Optional **TUF gaming laptop** (AC + idle over Tailscale) for fast local `aky build` iteration | Optional **RPi** or TUF binfmt for local iteration | Pure optimization layer in `3C.1` (`A-009`); never blocks always-on CI! |

---

## 4. Dimension 3 — Automated Security & Dependency PRs (`Vaultwarden` + Base OS)

1. **Channel Strategy for Vaultwarden & Security Freshness**:
   - v1 already tracks **`nixpkgs/nixos-unstable`** globally (so Vaultwarden, Tailscale, Caddy, OpenSSH, Linux kernel, and `niks3` receive upstream patches and Bitwarden client-compatibility updates immediately without waiting weeks for `nixos-stable` backport PRs, while hitting `cache.nixos.org` for ~99% of packages).
   - Alternative: split **`nixpkgs` (`nixos-stable`) + `nixpkgs-unstable` overlay** for fast-moving security/client apps (`vaultwarden`, `tailscale`). Cost: 2× `nixpkgs` eval footprint (~1.4 GiB) + overlay drift maintenance, whereas single `nixos-unstable` gated by KVM `vm-astrolabe` + `P-AkyPull` $\alpha$ auto-rollback delivers maximum cache sharing and zero overlay lag.
2. **PR Automation Tooling (Verified 2025–2026 Behavior)**:
   - **`Renovate` Hosted GitHub App (`nix` manager) — Critical Limitation Verified**: For normal branch-tracking flakes (`nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"`), Renovate's `nix` manager **cannot** split individual inputs into separate PRs — it only runs an all-or-nothing `lockFileMaintenance` PR! A broken desktop flake (`noctalia`/`helium`) would block `nixpkgs`/`vaultwarden` security patches.
   - **Targeted GHA Flake Updater (`U-SplitGHA`: `Mic92/update-flake-inputs` or clean native `nix flake update` workflow + scoped GitHub App token)**:
     - **Daily security track**: isolated PR updating **only `nixpkgs`** (`vaultwarden`, `tailscale`, `caddy`, `openssh`, kernel) — never blocked by third-party desktop flakes!
     - **Weekly auxiliary track**: separate PRs per auxiliary flake (`sops-nix`, `hjem`, `impermanence`, `disko`, `crane`, `noctalia`, `antigravity-nix`, `helium`).
     - **Scoped GitHub App (`actions/create-github-app-token`, 1h ephemeral JWT)** — solves the `GITHUB_TOKEN` anti-loop rule so bot PRs natively trigger `on: pull_request` CI + auto-merge with zero long-lived personal PAT!
     - **Rust & GHA coverage**: GitHub built-in **Dependabot** (zero third-party app!) handles `v2/Cargo.lock` + `.github/workflows` pinned SHA bumps, while CI runs `cargo-deny check advisories` (Rust CVEs) + optional weekly **`sbomnix` / `vulnxscan`** (Nix-patch-aware CVE alert to `ntfy`, avoiding `vulnix`'s unpatched false positives).
   - **`DeterminateSystems/update-flake-lock`**: Clean single-PR updater (simpler than per-input PRs, same single-PR head-of-line blocking unless invoked in two separate jobs: one for `inputs: nixpkgs`, one for all others!).
3. **Auto-Merge Safety Gate (`QA-06`)**:
   - **`Auto-Tiered` *(Recommended)***: Daily `nixpkgs` PRs **auto-merge automatically ONLY after 100% of required CI passes** (`aky check`, `schemas`, `eval-*`, `inspect-*`, **KVM `vm-astrolabe` booting real Vaultwarden + Caddy**, `aarch64` build) + send `ntfy` digest, backed at runtime by `P-AkyPull` $\alpha$ auto-rollback + `bootCounting`. Third-party flakes, `Cargo.lock`, and GHA action bumps stay **human/AI-reviewed** so unvetted third-party code never merges silently.
   - **`Auto-All`**: Auto-merges every green PR (higher third-party supply-chain exposure).
   - **`Manual-Review`**: Bot opens + pre-tests/pre-caches all PRs; human clicks merge on every PR (slower Vaultwarden CVE response if busy/traveling).

---

## 5. Dimension 4 — Self-Hosted Git Mirror & Sovereign Resilience (`C1` Break-Glass)

| Contender | Idle / Active RAM on `astrolabe` | Mirrors Code + `calibrated` Branch? | Mirrors Issues / PRs / Web UI? | Zero-GUI Declarative Setup & Maintenance | Break-Glass Pull Compatibility |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **`G-BareMirror`** *(`git clone --mirror` + `systemd` timer on `astrolabe` & future `rpi` + static Caddy `zone:mesh` export of `calibration.json` + Tailscale SSH)* | **`0 MiB` idle** / `~20 MiB` transient | **Yes** *(all branches, tags, `calibrated` TUF branch — 100% standard Git)* | No *(optional `0 MiB` `cgit` or static `stagit` anytime)* | **100% pure NixOS systemd timer** (`0` DB, `0` web CVEs, `0` secrets for public pull; trivial R2/Hetzner backup) | **100% native**: Caddy serves static `https://mirror.astrolabe.<tailnet>.ts.net/calibrated/calibration.json` + `.sig`; push via Tailscale SSH if GitHub dies |
| **`G-Forgejo`** *(`forgejo 17.0.1` in `nixpkgs`, Tailnet-only `zone:mesh`, reuses `BC-Niks3` Postgres)* | `130–190 MiB` idle / `300–450 MiB` active | **Yes** *(built-in pull mirror)* | **Yes** *(mirrors GitHub Issues, PRs, Releases, Wiki + mobile/web UI + instant drop-in forge if leaving GitHub!)* | Declarative via `services.forgejo` + systemd oneshot calling local Forgejo REST API (`curl /api/v1/repos/migrate`, zero GUI clicks), but maintains stateful web app + DB schema upgrades | **100% native** (HTTPS raw + Git SSH); keep `forgejo-runner` disabled to avoid 1–2 GiB spikes |
| **`G-Tangled`** *(`tangled.org` ATProto Knot server)* | `~40 MiB` | Requires multi-push (not pull mirror) | AppView federated via ATProto | External flake + ATProto DID/PDS dependency | Non-standard identity coupling for break-glass |
| **`G-SoftServe`** | `~25 MiB` | Yes | TUI only | **Sunsetted by Charmbracelet — rejected** | Partial |
| **`G-Radicle`** | `~50 MiB` | P2P protocol (`rad`) | Read-only web; non-standard Git refs | High UX paradigm shift | Requires `rad` on every node |

---

## 6. Stage `3B.3` Decision Pacing

- **Turn `3B.3a` *(Ratified 2026-11-25)***:
  1. **`P-AkyPull`** ratified (zero-eval Rust `aky pull` + TUF signed `calibration.json` + $\alpha$ survival-probe auto-rollback + `systemd-boot.bootCounting` + shared `flock` with `aky switch`).
  2. **`BC-Niks3` + Cloudflare R2** ratified (retiring Backblaze B2 completely across the stack, retiring `atticd` + `cachix-watch-store-agent`, using native GitHub OIDC + free `ubuntu-24.04-arm` multi-arch CI).
- **Turn `3B.3b` *(Active Now)***:
  3. **Fork `3B.3b-1`**: Automated Security & Dependency PR Pipeline (`U-SplitGHA` + `Auto-Tiered` vs `U-Renovate` vs `Manual-Review`).
  4. **Fork `3B.3b-2`**: Self-Hosted Git Mirror (`G-BareMirror` vs `G-Forgejo`) & `M1-Sunset` Cutover Hooks.
