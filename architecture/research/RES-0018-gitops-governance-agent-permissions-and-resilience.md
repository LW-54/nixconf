---
id: RES-0018
title: Stage 3B.3c Literature Review — GitOps Governance, PR UX, AI Agent GitHub Permissions & 3-2-1-1-0 Resilience
type: research
status: active
created: 2026-11-25
updated: 2026-11-25
domain: gitops
tags: [research, stage-3b3, gitops, governance, trunk-based-development, rulesets, github-app, deploy-key, ai-agent-security, pre-commit, dix, gittuf, 3-2-1-1-0, backup, cloudflare-r2]
assumptions: [A-004, A-008]
summary: Dedicated 2025-2026 theoretical and practical literature review covering GitOps change-control methodology (OpenGitOps, TBD, linear history, NixOS dix PR diffs, stratified pre-commit vs CI), AI coding agent GitHub permissions and prompt-injection defenses (GitHub Rulesets, GitHub Apps vs Deploy Keys, sensitive-path gates, solo-repo self-approval mechanics), CNCF gittuf evaluation, and full 3-2-1-1-0 control-plane redundancy including GitHub metadata backups and Cloudflare R2 WORM Bucket Locks.
---

<!-- abstract:start -->
## Executive Abstract

Conducts a dedicated 2025–2026 theoretical and empirical literature review completing **Stage `3B.3`** before ratifying `ADR-0013`. Directly audits v1's [`.githooks/pre-commit`](../../.githooks/pre-commit) and [`modules/features/antigravity/remote-control.nix`](../../modules/features/antigravity/remote-control.nix) against modern GitOps & AI-agent security standards (**OpenGitOps**, **Trunk-Based Development**, **SLSA Level 3**, **GitHub Repository Rulesets**, **CNCF `gittuf`**, and the **3-2-1-1-0** backup rule).

**Four critical findings surfaced**:
1. **v1 Agent Deploy-Key Blind Spot**: While v1's systemd sandbox for `agy-remote-control.service` is strong (`ProtectSystem=strict`, `InaccessiblePaths`), giving an AI agent a static repo-wide SSH **Write Deploy Key** allows pushing to *any* unprotected branch (including our future `calibrated` TUF manifest branch!), leaves weak audit attribution, and prevents distinct bot-author PR workflows. Modern 2025–2026 defense combines **GitHub Repository Rulesets** (free on public repos for branch/tag rulesets: locking `main` and `calibrated` with zero deploy-key/agent bypass) + **strict identity separation** (human `LW-54` vs AI agent vs CI updater) + **CI sensitive-path guards** protecting `.github/workflows/**`, `v2/policies/**`, `v2/formal/**`, `secrets/**`, and `AGENTS.md` from prompt-injection poisoning.
2. **Solo-Repo PR Self-Approval Catch-22**: GitHub prohibits a PR author from approving their own PR — meaning enforcing `Require review from Code Owners` on a personal repo locks *you* out of your own PRs, **whereas** when an AI agent or update bot authors a PR under a distinct **GitHub App identity (`[bot]`)**, you (`LW-54`) *can* formally review and approve it while keeping human PRs frictionless via required status checks + PR-only `main` ruleset.
3. **High-Signal NixOS PR UX & Stratified Verification**: Pinned `nixpkgs` (`1d06008`) already includes **`dix 3.0.0`**, **`gitleaks 8.30.1`**, **`lefthook 2.2.2`**, **`sbomnix 1.9.0`**, **`gickup 0.10.45`**, and **`gittuf 0.16.0`**. Posting automatic **`dix` closure diffs + `aky` Cedar/SOPS blast-radius summaries** as a PR comment turns infrastructure PR review into a 5-second visual diff, while splitting local pre-commit (`< 3–10 s`: formatting, `gitleaks`, `aky check`, `aky secrets audit`, changed-host eval) from untrusted zero-secret PR CI and trusted `main`-only calibration eliminates redundant slowness.
4. **Full 3-2-1-1-0 Redundancy & GitHub Metadata Gap**: A bare Git mirror preserves 100% of Git objects (`main`, `calibrated`, tags) at `0 MiB` idle RAM, but does *not* capture GitHub Issues, PR discussions, Releases, or Ruleset configs. Adding a `0 MiB`-idle daily JSON exporter (`gh api` / `gickup`) + multi-provider off-VPS replication (**Cloudflare R2 with WORM Bucket Locks** + **Hetzner Storage Box**) + periodic automated restore drills (`-0-`) closes correlated GitHub + VPS + Cloudflare failure modes without paying `150–350 MiB` RAM for a stateful web forge.
<!-- abstract:end -->

# RES-0018: GitOps Governance, PR UX, AI Agent Permissions & 3-2-1-1-0 Resilience

---

## 1. On-Disk Audit of v1 Git & Agent Setup

### 1.1 Existing v1 Strengths & Gaps
- **[`.githooks/pre-commit`](../../.githooks/pre-commit)**:
  - *Strengths*: Fast staged `alejandra` (~0.1s), single-process Nix eval sharing memoized `nixpkgs`, telemetry recording (`precommit-metrics.json`), `actionlint` on CI edits.
  - *Gaps*: (1) Hardcodes `eval-astrolabe` and `eval-x240` (breaks dynamic fleet scaling); (2) zero secret-leak scanning (`gitleaks` / plaintext `secrets/` check); (3) zero commit-message convention check; (4) zero `aky check` / Rust / Cedar boundary validation; (5) rewrites and auto-stages 169 generated Markdown docs on every Nix commit (to be addressed with `A-012` in Stage `3C.3`).
- **[`modules/features/antigravity/remote-control.nix`](../../modules/features/antigravity/remote-control.nix#L165-L332)**:
  - *Strengths*: Excellent local OS hardening (`ProtectSystem=strict`, `CapabilityBoundingSet=""`, `NoNewPrivileges=true`, `InaccessiblePaths` hiding `~/.ssh`, `~/.config/sops`, `~/.config/gh`, `/var/lib/vaultwarden`, `/var/lib/sops-nix`, `/root`).
  - *Gaps*: Authenticates to GitHub via a **static, non-expiring repo-wide SSH Write Deploy Key** (`secrets/hosts/astrolabe/agent-git.yaml`). Without explicit branch rulesets on *every* sensitive ref (`main`, `calibrated`), a write deploy key can push directly to `calibrated` or create arbitrary refs; it has no distinct GitHub App actor identity and cannot natively open PRs via GitHub API.

### 1.2 Pinned `nixpkgs` (`1d06008`) Governance Tooling Inventory
| Package | Pinned Version | Role |
| :--- | :---: | :--- |
| `dix` | `3.0.0` | Ultra-fast Rust NixOS closure diff (for automated PR diff comments!) |
| `nvd` | `0.2.4` | Classic NixOS version diff alternative |
| `gitleaks` | `8.30.1` | Fast pre-commit & CI plaintext credential / API key leak scanner |
| `lefthook` | `2.2.2` | Fast parallel Git hook runner (optional over thin bash/Rust hook) |
| `gh` | `2.103.3` | GitHub CLI for PRs, ruleset inspection, & metadata API backup |
| `gickup` | `0.10.45` | Declarative multi-target Git mirror / backup tool |
| `sbomnix` | `1.9.0` | Nix-patch-aware SBOM & `vulnxscan` CVE scanner |
| `gittuf` | `0.16.0` | CNCF/OpenSSF TUF-inside-Git branch-rule enforcement |
| `jujutsu` (`jj`) | `0.46.0` | Optional stacked-diff VCS frontend compatible with standard Git remotes |

---

## 2. Pillar 1 — GitOps Change-Control Methodology & PR UX

### 2.1 Theoretical Grounding (OpenGitOps, DORA / Trunk-Based Development, SLSA)
Modern 2025–2026 GitOps literature converges on **five structural laws** for a production infrastructure repository operated by a human maintainer + autonomous AI agents + automated update bots:
1. **Strict Trunk-Based Development (TBD) with Short-Lived Branches**: No long-lived `dev` or `staging` branches (which cause merge-conflict rot and drift). `main` is the single calibrated trunk. Large changes decompose into small sequential PRs (or optional stacked PRs via `jj` / Git).
2. **Enforced Branch Taxonomy & Linear History**:
   - Human branches: `feat/<slug>`, `fix/<slug>`, `refactor/<slug>`, `chore/<slug>`, `docs/<slug>`, `design/<slug>`.
   - Autonomous AI agent branches: **`agent/<slug>`** (clearly separated in rulesets, CI labels, and audit logs!).
   - Automated dependency bots: **`bot/<slug>`** (e.g., `bot/update-nixpkgs`).
   - **Linear History** (squash or fast-forward rebase merge) + **Conventional Commits** (`<type>: <description>`, no parenthetical scopes) so `git log --first-parent main` is a clean `FOLLOWS` causal chain that `git bisect` can pinpoint in $O(\log N)$.
3. **Cryptographic Attribution (SSH Commit Signing)**:
   - Human commits signed via native Git SSH signing (`gpg.format = ssh`, zero GPG keyring pain, verified against in-repo `allowed_signers`!).
   - Bot/Agent commits explicitly attributed to their machine identity (never spoofing human SSH signatures).
4. **High-Signal Automated PR Telemetry (`QA-10` Human Clarity + AI Determinism)**:
   - Every PR automatically receives **one updated summary comment** containing:
     - **`dix` closure diff** (`dix diff <base> <head>`) per affected host (exact package version bumps + closure size delta),
     - **`aky` Boundary & Blast-Radius Diff**: changed exterior promises ($\Pi_{\text{ext}}$), new/modified ports, Cedar authority changes, SOPS recipient changes, and systemd unit diffs,
     - **Sensitive-Path Warning Banner** if touching `.github/workflows/**`, `v2/policies/**`, `v2/formal/**`, `secrets/**`, or `AGENTS.md` / `.claude/**` / `.gemini/**`.
5. **Safe Pre-Merge Live Staging (Zero Trunk Pollution)**:
   - To test a change on live hardware (`x240` or `astrolabe`) *before* merging to `main`, the operator runs `aky switch --test` locally on the feature branch (acquires `/run/aky-switch.lock`, runs `switch-to-configuration test` + local $\alpha$ probes without altering boot default, then merges the PR once verified).

### 2.2 Three-Tier Verification Stratification (Pre-Commit vs. PR CI vs. Post-Merge `main`)
Eliminates both *slow local friction* and *untested gaps*:

| Tier | Trigger & Latency | Security Context | Exact Checks Executed |
| :--- | :--- | :--- | :--- |
| **1. Local Pre-Commit** (`aky hook pre-commit` / `lefthook`) | On `git commit` (**`< 1–10 s`**) | Local workstation / agent sandbox | `< 1 s`: staged `alejandra` / `rustfmt`, `gitleaks protect --staged`, `aky check` (`2.4 ms`), `aky secrets audit` (`< 2 ms`, verifies zero unencrypted files in `secrets/` & SOPS header ↔ Cedar match), commit-msg `<type>: <desc>` check.<br>`~6–10 s` *(only when `.nix`/agent files staged)*: `schemas` + dynamically discovered affected-host `eval`. |
| **2. Pull Request CI** (`on: pull_request`) | Every PR push (**`~1–4 min` cached**) | **Untrusted — ZERO secrets!** | Full `aky check`, `schemas`, `eval-*`, `inspect-*`, **`dix` PR diff comment**, KVM `vm-*` on affected hosts, native `ubuntu-24.04-arm` `aarch64` build, `cargo test`/`clippy`/`cargo-deny`, path-filtered Lean 4 & Quint checks, `README.md` cache-isolation guard, sensitive-path labeler, agent-branch policy check. |
| **3. Post-Merge `main` CI** (`on: push: [main]`) | Only after PR merge | **Trusted (`main`-only Environment + OIDC)** | Builds any uncached outputs, pushes to Cloudflare R2 via **`BC-Niks3` OIDC** (`ref:refs/heads/main`), signs & publishes TUF `calibration.json` + `.sig` to ruleset-locked **`calibrated`** branch, runs `install-*` disk tests on disk-diff/cooldown. |

---

## 3. Pillar 2 — GitHub Permissions & AI Coding Agent Security (`L3+`)

### 3.1 2025–2026 Threat Model for AI Agents in Self-Deploying GitOps Repos
Recent security literature identifies **four primary AI-agent repository attack vectors**:
1. **Direct Branch / TUF Poisoning**: An agent with broad write credentials pushes directly to `main` or to the TUF manifest branch `calibrated`.
2. **Workflow Poisoning**: A prompt-injected agent modifies `.github/workflows/*.yml` in a PR to exfiltrate secrets or bypass tests. *(Mitigated at two layers: (a) **ZERO secrets** exist in `pull_request` workflows thanks to `BC-Niks3` OIDC + `main`-only Environment; (b) CI sensitive-path gate blocks auto-merge and flags human review on any `.github/workflows/**` diff!)*
3. **Instruction / Context Poisoning**: Prompt injection via `AGENTS.md`, `.gemini/**`, or external dependencies trying to sneak in backdoors or exfiltrate local secrets (`gitleaks` pre-commit + systemd `InaccessiblePaths` + sensitive-path PR gate).
4. **Privilege / Identity Confusion**: Sharing a human PAT/SSH identity lets an agent impersonate the human maintainer in audit logs or self-approve changes.

### 3.2 GitHub Free (Public Repo) Ruleset Capabilities — Verified Facts
- **Available FREE on public repos**: Branch & Tag **Repository Rulesets** (require PR, require status checks, require linear history, require signed commits, restrict creations/updates/deletions/force-pushes, actor bypass lists, `CODEOWNERS`).
- **Enterprise/Private-only (NOT available on Free public repos)**: Native GitHub **Push Rulesets** (server-side file-path/extension blocking on push) → cleanly compensated by our **required CI check** (`policy-guard`) verifying branch-actor rules and sensitive-path labels before merge!
- **Solo-Repo Self-Approval Catch-22**: Enabling `Require 1 approving review` / `Require review from Code Owners` globally on `main` blocks *your own* human PRs because GitHub forbids authors from approving their own PRs!
  - **Clean Solo-Repo Resolution**:
    - **`main` Ruleset**: `Require a pull request before merging` + `Require all status checks to pass` + `Require linear history` + `Block force-pushes & deletions` + `Require approving reviews = 0` *(so human `LW-54` PRs merge smoothly once CI is green without locking yourself out!)*, with **bypass list = `LW-54` admin emergency-only** (NEVER agents or deploy keys!).
    - **AND why can't an AI agent merge its own PR when `required reviews = 0`?** Because **the agent's credential literally lacks merge permission** (or is blocked by GitHub App `Pull requests: write` + `main` Ruleset requiring merge-permission / CI blocking auto-merge on `agent/**` PRs, OR using a **deploy key** which has ZERO GitHub API access to merge anything!).
    - **`calibrated` Ruleset (CRITICAL!)**: `Restrict creations`, `Restrict updates`, `Restrict deletions`, `Block force-pushes` — **Bypass list = ONLY `aky-calibrator[bot]` (the `main`-only post-merge CI GitHub App!)**. Not `aky-agent`, not deploy keys, not `U-SplitGHA`, not even accidental local `git push` can write to `calibrated`!

### 3.3 Comparing the Two Clean Agent-Permission Architectures

| Dimension | **`Perm-AgentApp`** *(Dedicated Scoped GitHub App `aky-agent[bot]` + `aky-ops[bot]` for CI)* | **`Perm-SplitMinimal`** *(Hardened SSH Deploy Key for Local Agent + 1 Scoped GitHub App `aky-ops[bot]` for CI)* |
| :--- | :--- | :--- |
| **Local AI Agent Capabilities** | Pushes branches (`agent/**` / `feat/**`) **AND** opens/updates structured Draft/Ready PRs (`gh pr create`) via 1h ephemeral GitHub App tokens (`aky git-cred`); **zero merge permission** on `main` (`main` ruleset + CI blocks auto-merge on agent PRs; `calibrated` locked!) | **SSH `git push` ONLY** to non-protected branches (`agent/**` / `feat/**`); **ZERO GitHub API token** (literally cannot create/edit/comment/merge PRs, issues, or labels!) |
| **Human UX & Review Flow** | Agent finishes work → pushes `agent/<slug>` → **automatically opens clean PR** with summary + triggers `dix` diff comment → you review & click Merge (you CAN click "Approve" since `aky-agent[bot]` is the PR author!) | Agent finishes work → pushes `agent/<slug>` → prints compare URL → you click 1-click "Create Pull Request" in GitHub UI (or run `gh pr create` from your workstation) |
| **Blast Radius if Agent Prompt-Injected** | Very small: 1h expiring token, single repo `LW-54/nixconf`, locked out of `main` & `calibrated`, cannot merge PRs; *could* open spam PRs/comments until revoked | **Absolute minimum**: zero GitHub API access at all; locked out of `main` & `calibrated` by Rulesets; *could* only push non-protected feature branches |
| **Credential Lifecycle & Setup** | 2 tiny GitHub Apps (1 for local agent, 1 for CI updater + `calibrated` push); auto-expiring 1h JWTs (best audit trail: `[bot]` actor) | 1 existing SSH Deploy Key (already works on `astrolabe`!) + 1 tiny GitHub App strictly inside CI (`U-SplitGHA` + `calibrated` push) |

### 3.4 Evaluating CNCF `gittuf 0.16.0` (TUF-Inside-Git)
`gittuf` stores TUF branch/key-delegation policies inside `refs/gittuf/*` so mirrors verify history independently of GitHub. However:
- `P-AkyPull` **already** enforces end-to-end TUF verification (`calibration.json` Ed25519 signature + persisted monotonic `max_seen_epoch` + staleness $\Delta t$ + Nix `trusted-public-keys`) at the deployment boundary — so even total GitHub + mirror compromise cannot forge, downgrade, or silently freeze hosts.
- Running `gittuf` on a solo repo adds extra push ceremony (`gittuf rsl record`) for minimal extra protection over `P-AkyPull` + SSH-signed commits + GitHub Rulesets.
- **Recommendation**: **Defer `gittuf`** cleanly unless the repo grows to multi-maintainer governance in the future.

---

## 4. Pillar 3 — Extra Backup & Redundancy Analysis (`3-2-1-1-0` Control Plane)

### 4.1 Classifying Every GitOps Control-Plane Asset (`ADR-0004` `S2+`)
| Asset | `S2+` Class | Current Risk if Lost | `3-2-1-1-0` Protection Strategy |
| :--- | :--- | :--- | :--- |
| **Git Repository** (`main`, `design/v2`, `calibrated`, tags) | `Irreplaceable` | Total IaC & history loss | **5 copies / 3+ media**: (1) GitHub, (2) `astrolabe` live bare mirror (15m timer), (3) `rpi` live bare mirror + workstation clones, (4) **Cloudflare R2** encrypted backup (**WORM Bucket Lock 30–90d**!), (5) **Hetzner Storage Box (`hbox`)** encrypted backup (independent cloud vendor if Cloudflare locks account!) |
| **GitHub Metadata** (Issues, PR discussions, Reviews, Releases, Ruleset JSON) | `Irreplaceable` | Lost architectural context & PR audit trail *(missed by bare `git clone --mirror`!)* | **Daily `0 MiB`-idle systemd timer** exporting Issues/PRs/Releases/Rulesets JSON via `gh api` / `gickup` into `/var/lib/git-mirror/metadata/` → swept into R2 (WORM) + Hetzner Box backups! |
| **Binary Cache** (`BC-Niks3` on Cloudflare R2) | `Ephemeral` *(Derived)* | Zero data loss (slower rebuild until re-warmed) | **No backup needed** — 100% deterministically reconstructible from Git + `cache.nixos.org`; hosts gracefully continue running active generation during any R2 outage. |
| **Signing & Custody Keys** (`role:human-root` `age`, break-glass SSH, Human Root TUF Ed25519 key, R2/Hetzner creds) | `Irreplaceable` | Lockout or TUF fast-forward unrecoverability | Stored in **Vaultwarden** (daily UX) **+** **Offline Air-Gapped Break-Glass Kit** (printed/USB, `ADR-0011`), with TUF **two-role separation** (online `main`-only CI Snapshot key vs offline Human Root key that can revoke/rotate CI key or reset `max_seen_epoch`). |
| **Restore Verification (`-0-`)** | Invariant | Silent backup corruption | **Monthly automated restore drill** (`\$0` egress on Cloudflare R2!): verify `git bundle verify`, bare-mirror clone, and Restic snapshot integrity check → `ntfy` alert on any error. |

---

## 5. Addendum — Repo Rename (`LW-54/antikythera`), Fleet-Wide Offline Mirrors & Forge Alternatives Survey

### 5.1 Canonical Repository Identity & Measured Repo Size
- **Repository Name**: **`LW-54/antikythera`** (aligned with `ADR-0008`; parameterized across `niks3` OIDC `bound_subject`, GitHub Apps, and mirror URLs).
- **Measured Packed Size (`git count-objects -vH`, 2026-11-25)**: **`2.27 MiB` packed** (`10.13 MiB` loose objects pre-GC).
- **Fleet-Wide Offline Mirror Capability**: Because a bare mirror is only `~3–15 MiB` on disk and `0 MiB` idle RAM, every host with non-ephemeral storage (`astrolabe`, `x240`, `zenbook`, `tuf`, `rpi`, `wsl` — excluding read-only `live-iso`) automatically syncs a local bare mirror (`/var/lib/antikythera/repo.git`) in lockstep with `P-AkyPull` / timer ticks. This gives every node **100% offline history, offline `aky check` / `aky switch`, and fleet-wide decentralized redundancy**.

### 5.2 Are There Lighter Self-Hosted Full Forges Than Forgejo? (2026 Verdict)
| Contender | Pinned `nixpkgs` (`1d06008`) | Idle RAM | Full GitHub Replacement (PRs / Issues / CI)? | 2026 Security & Maintenance Verdict |
| :--- | :---: | ---: | :---: | :--- |
| **`Forgejo`** | `17.0.1` | `130–190 MiB` *(active `~350 MiB`)* | **Yes** (Web UI, PRs, Issues, **Forgejo Actions ~95% `.github/workflows` compatible!**) | **Lightest actively maintained, security-patched full self-hosted forge.** Reuses `BC-Niks3` Postgres; *caveat*: standard pull-mirror syncs Git refs only (not live GitHub issues/PRs without companion API export). |
| **`Gogs`** | **missing (removed)** | `30–50 MiB` | Basic PRs/Issues | **Disqualified (`B`/`D`)**: Stalled upstream; accumulated critical RCE/SSRF flaws including **CISA KEV `CVE-2025-8110`**. |
| **`cgit` / `stagit` / `legit` / `klaus`** | `1.3.1` / `1.3` / `1.2.0` / `3.0.1` | `0–20 MiB` | **No** (read-only code browsers only) | Useful only as static viewers; cannot replace GitHub PR/Issue workflows. |
| **`SourceHut`** | partial | `50–100 MiB` | Email-patch (`git send-email`) | Poor ergonomic fit for PR-based AI coding agents (`QA-10`). |
| **`git-bug`** | `0.11.0` | `0 MiB` | Decentralized issues in Git refs (CLI/TUI + GitHub bridge) | Interesting optional issue-archival bridge, not a PR/CI forge. |

### 5.3 Hosted Secondary Forges: Codeberg vs. GitLab.com
| Secondary Hosted Forge | Cost & Quota | Mirroring | Drop-In CI Failover | Trade-Offs |
| :--- | :--- | :--- | :--- | :--- |
| **Codeberg** *(EU non-profit running Forgejo)* | **\$0** (FOSS public repos; 750 MiB soft cap vs our `2.3 MiB` repo) | Native pull-mirror OR 3-line GHA push-mirror | Forgejo Actions (**~95% `.github/workflows` compatible**; short hosted alpha timeouts, attach self-hosted runner if permanent) | **Zero VPS RAM/maintenance, non-profit EU, exact 1:1 Forgejo parity** (trivial to self-host Forgejo later if ever desired). |
| **GitLab.com Free** | **\$0** (10 GiB storage; 5-user group cap) | Native pull/push mirror | 400 free CI mins/mo incl. `saas-linux-small-arm64`, **but requires maintaining a separate `.gitlab-ci.yml`** | Dual-CI YAML drift (`D` penalty) + corporate SaaS API/account restrictions; lower leverage than Codeberg for a GitHub Actions repo. |

---

## 6. Final Stage `3B.3` Confirmation Fork

With `P-AkyPull`, `BC-Niks3` (Cloudflare R2), `U-SplitGHA` + `Auto-Tiered`, `Perm-AgentApp`, strict PR-only `main` + locked `calibrated` Rulesets, `3-2-1-1-0` backups (R2 WORM + Hetzner Box + daily GitHub metadata JSON + monthly restore drill), canonical repo **`LW-54/antikythera`**, and **fleet-wide `~3–15 MiB` offline bare mirrors** all locked in — only the **GitHub-replacement mirror tier** remains to finalize `ADR-0013`:
1. **`M-FleetBare + Codeberg`** *(Recommended)*: Fleet-wide offline bare mirrors + `astrolabe` `0 MiB` static `calibrated/` + automatic mirror to **Codeberg** (`0 MiB` VPS RAM, non-profit Forgejo, ~95% workflow parity, spin up self-hosted Forgejo later only if ever wanted).
2. **`M-FleetBare + Live Forgejo`**: Fleet-wide offline bare mirrors + always-on self-hosted **`services.forgejo`** (`17.0.1`, Tailnet-only `zone:mesh`, reusing `niks3`'s Postgres, ~`130–190 MiB` idle RAM, `forgejo-runner` off until needed) for 100% sovereign instant GitHub replacement.
3. **`M-FleetBare Only`**: Fleet-wide offline bare mirrors + `astrolabe` static `calibrated/` + R2 WORM + Hetzner Box + metadata JSON only (`0 MiB` RAM, zero extra accounts; deploy `services.forgejo` or Codeberg on demand only if GitHub actually fails permanently).
