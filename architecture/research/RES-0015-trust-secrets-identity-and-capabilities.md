---
id: RES-0015
title: Stage 3B.1 Wide-Spectrum Research Dossier — Secrets at Rest, Host Key Custody, Break-Glass, and Attenuated Capabilities (L3+ & C1)
type: research
status: active
created: 2026-11-24
updated: 2026-11-24
domain: trust
tags: [research, stage-3b, secrets, sops-nix, agenix, ragenix, agenix-rekey, clan-vars, systemd-creds, biscuit, ucan, macaroons, openssh-certs, step-ca, tailscale-ssh, yubikey, fido2, shamir, tpm2, lanzaboote, luks2]
assumptions: [A-004, A-005]
summary: Broad, empirically grounded 2025–2026 survey of the full Stage 3B.1 solution space across 5 orthogonal dimensions: at-rest secret engines (6 contenders), physical host key custody & stolen-laptop threat modeling (LUKS2+TPM2+PIN+Lanzaboote), offline human root break-glass (4 mechanisms), Layer-2 attenuated capabilities & short-lived auth (7 contenders including OpenSSH certs, step-ca, Biscuit, UCAN, Macaroons, OIDC, systemd LoadCredential), and declarative secret generators.
---

<!-- abstract:start -->
## Executive Abstract

Wide-spectrum primary research dossier for **Stage `3B.1`** (`ADR-0004` `L3+` + `ADR-0006` `C1`). Audits v1's live secrets footprint ([`.sops.yaml`](../../.sops.yaml), [`modules/implementations/sops.nix`](../../modules/implementations/sops.nix)) and pinned upstream code (`Mic92/sops-nix`, `nixpkgs` crypto toolchain) alongside 2025–2026 ecosystem evidence across **all 5 trust-plane dimensions**, explicitly evaluating alternatives initially omitted (`agenix-rekey`, `ragenix`, `systemd-creds`/`LoadCredentialEncrypted`, `age-plugin-sss`, **OpenSSH Certificates**, **Smallstep `step-ca`**, **UCAN vs Macaroons vs Eclipse Biscuit**, and **LUKS2 + TPM2-PIN + Lanzaboote Secure Boot** physical threat modeling).
<!-- abstract:end -->

# `RES-0015`: Stage `3B.1` Trust Plane — Full Solution-Space Survey (`L3+` & `C1`)

## 1. Empirical Baseline from v1 On-Disk Audit
- **Live v1 inventory**: 25 encrypted YAML files under `secrets/` (`admin/`, `backup/`, `cachix/`, `ci/`, `hosts/`, `services/`, `ssh/`, `storage/`, `users/`, `wifi/`), using `age` keys persisted at `/persist/sops-nix/key.txt` (`astrolabe`, `x240`, `admin`, `github_actions`).
- **Pinned `nixpkgs` crypto toolchain (already cached on `astrolabe`)**: `sops 3.13.3`, `age 1.3.2`, `rage 0.12.1`, `ssh-to-age 1.3.0`, `age-plugin-yubikey 0.5.1`, `age-plugin-fido2-hmac 0.5.0`, `age-plugin-tpm 1.0.1`, `attic-client`.
- **Pinned `Mic92/sops-nix` inspected on disk**: Only **1** public flake input (`nixpkgs`; dev inputs isolated in `./dev/private`), 544 LOC Nix module + 1,656 LOC Go `sops-install-secrets` supporting atomic generation-switched `/run/secrets`, `neededForUsers`, `templates` + `placeholder`, `restartUnits`/`reloadUnits`, `useSystemdActivation`, and `age.plugins`.
- **Two real bugs discovered in v1**:
  1. **Blast-radius leak**: `.sops.yaml` catch-all `^secrets/.*$` → `*all` encrypted `secrets/services/*` (Vaultwarden/auth, Attic, monitoring), `secrets/backup/*`, `secrets/cachix/*`, `secrets/ssh/*`, and `secrets/users/*` to roaming laptop `x240`'s `age` key.
  2. **Break-glass circularity**: `devShells.sops-admin` fetched `SOPS_AGE_KEY` from Bitwarden/Vaultwarden — which runs on `astrolabe`, violating `C1` Zero-Infra Break-Glass if `astrolabe` is lost.

---

## 2. Dimension A — At-Rest Secret Storage & Runtime Activation (6 Contenders)

| Contender | Encryption & Layout | Flake Inputs | Re-keying & `C3` Pull Purity | Templates / `neededForUsers` / `restartUnits` | Declarative Generators | Real 2025–2026 Pitfalls & Trade-offs |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- |
| **`sops-nix` (Sealed) + `aky` Policy Compiler** | SOPS (`age` + hardware plugins); multi-key YAML/JSON/dotenv/binary. Plaintext YAML keys & recipient metadata. | **1** (`sops-nix` → `nixpkgs`) | `aky` generates `.sops.yaml` from Cedar & verifies actual ciphertext `sops.age[].recipient` headers statically in `<2 ms`; pure `C3` pull. | **All 3 native** (`templates`, `neededForUsers`, `restartUnits`/`reloadUnits`, `useSystemdActivation`). | Via `aky secrets gen` (optional thin wrapper). | - **Impermanence race**: using `/etc/ssh` host key via impermanence bind-mounts with `neededForUsers` breaks under stage-1 systemd-mount ordering. **Mitigation**: dedicated `/persist/sops-nix/key.txt` on `neededForBoot = true` (already proven in v1!).<br>- YAML key names are plaintext in Git.<br>- Non-NixOS uses raw `sops` CLI (no systemd hooks). |
| **`agenix-rekey` (`oddlama`) + `agenix`** | Pure `age`; master-encrypted sources → rekeyed per-host `.age` blobs (hides key names). | **2** (`agenix` + `agenix-rekey`) | `storageMode = "local"` commits per-host `.age` blobs → pure `C3` pull (`storageMode = "derivation"` is impure & breaks autonomous pull!). | `neededForUsers` (via `agenix`), **NO native templates** (needs `agenix-template` or custom scripts) and no built-in `restartUnits`. | **Built-in** (`generators` for random passwords, WireGuard keys, `.htpasswd`). | - Duplicates $N_{\text{hosts}} \times N_{\text{secrets}}$ rekeyed ciphertexts in Git.<br>- Hardware tokens (`age-plugin-fido2-hmac`) can trigger repeated physical touches across large rekeys.<br>- Requires migrating all 25 existing SOPS YAML files to ~80–120 `.age` files. |
| **`agenix` (`ryantm`)** | Pure `age`; 1 `.age` file per secret; manual `secrets.nix`. | **1** (`agenix`) | Manual `secrets.nix` maintenance; pure `C3` pull. | Minimal Bash/Nix activator; no native templates or `restartUnits`. | Manual. | - Clumsy multi-host rekeying without `agenix-rekey`; file explosion. |
| **`ragenix` (`yaxitech`)** | Rust drop-in CLI for `agenix` (`age` crate). | **1** (`ragenix`) | Same as `agenix`. | Same Nix module as `agenix`. | Manual. | - **Maintenance risk (`D`)**: low-velocity / maintenance mode in 2025–2026. |
| **`clan-core vars`** | Pluggable backend (defaults to `sops-nix`); folder-per-generator. | Heavy (`clan-core`) | Automated inside Clan inventory. | Delegates to backend. | **First-class** native generators. | - Framework lock-in incompatible with Antikythera's minimal pure-core architecture (`ADR-0008`/`ADR-0009`). |
| **Custom Pure-Rust `aky` `age` Activator + `systemd-creds`** | Pure `age` crate (Rust) + `systemd-creds encrypt` / `LoadCredentialEncrypted`. | **0** extra inputs | `aky`-managed; pure `C3` pull. | Must build & maintain early-boot `neededForUsers`, atomic tmpfs generations, templates, `restartUnits`, and `age-plugin-*` support ourselves. | Native in `aky`. | - **TPM2 PCR trap**: strict `LoadCredentialEncrypted` PCR sealing breaks on routine NixOS kernel/initrd upgrades (`status=243/CREDENTIAL`) unless re-sealed.<br>- **Impermanence trap**: host fallback key `/var/lib/systemd/credential.secret` must persist.<br>- High security-critical maintenance burden (`B`/`D` risk) for an early stage. |

**Key Structural Insight**: Because the secrets backend is **sealed behind one atomic Substrate Agent** (e.g. `secrets-sops` consuming `Partitioned` secret promises, with `secrets-mock` for QEMU tests), the choice between `sops-nix` and `agenix-rekey` / custom Rust activator is **cleanly encapsulated behind `Σ`**, while the **true non-negotiable one-way door** is making **Cedar `L3+` policies the single source of truth** that mechanically generates & audits ciphertext recipients (eliminating hand-maintained `.sops.yaml` / `secrets.nix` drift forever!).

---

## 3. Dimension B — Host Physical Key Custody & Stolen-Device Threat Model

| Device Class | Physical Custody Threat | Recommended Host Root Key Custody |
| :--- | :--- | :--- |
| **VPS (`astrolabe`)** | Remote compromise / datacenter access (no unattended physical theft by casual thief; impermanent root; often no dTPM). | Dedicated `age` private key at `/persist/sops-nix/key.txt` (`0400`, `neededForBoot = true`), backed up encrypted strictly to offline human root keys (never to laptops). |
| **Roaming Laptops (`x240`, ZenBook Duo, TUF)** | **Casual theft + Evil Maid + bus-sniffing / FaulTPM**. Pure zero-PIN TPM2 auto-unlock is **broken** against physical fault/bus attacks! | **LUKS2 full-disk encryption** + `systemd-cryptenroll --tpm2-with-pin=yes` (requiring a PIN on boot!) + **Lanzaboote Secure Boot (PCR 7)** where UEFI supports it + printed/offline LUKS recovery key. Host `age` key lives inside LUKS-encrypted `/persist` (never unencrypted on disk; optionally further wrapped via `age-plugin-tpm` where dTPM exists). |
| **Chromebook / ARM RPi** | Varies (no dTPM on RPi; Crostini/ChromeOS verified boot on Chromebook). | LUKS2 passphrase on RPi (or minimal blast-radius attribute tags excluding sensitive server secrets via Cedar `L3+`!); Chromebook carries strictly `posture:roaming` / non-vault secrets. |
| **Ephemeral `Live-ISO`** | Public/portable USB stick (`C1` Zero-Trust Genesis). | **ZERO** production private keys or secrets. Fresh target generates its own keypair on local `/persist`, displays public key/fingerprint for human verification, admin commits public key + attributes to Git & rekeys, target converges to $g_0$. |

---

## 4. Dimension C — Offline Human Root Custody & Zero-Infra Break-Glass (`C1`)

All options eliminate v1's **Bitwarden/Vaultwarden circular dependency**:

| Mechanism | Strengths | Weaknesses / Operational Notes |
| :--- | :--- | :--- |
| **`age-plugin-yubikey` (PIV ECC P-256)** | Official, mature, hardware-isolated private key (never touches host RAM/disk); supported natively by `sops` & `age`. | Single hardware key is an SPOF unless enrolled in **pairs** (primary + spare YubiKey) or paired with an offline cold passphrase/paper fallback. |
| **`age-plugin-fido2-hmac` (WebAuthn/FIDO2)** | Works with generic FIDO2 security keys (not just YubiKey PIV); supports PIN + touch. | Non-clonable device seed; requires independent fallback recipient; repeated touch prompts during batch rekeys. |
| **`age-plugin-sss` (Shamir $K$-of-$N$)** | Zero single point of failure (e.g., 2-of-3 or 3-of-5 across YubiKey + paper + encrypted USB + trusted person). | Higher operational ceremony & error risk during high-stress crisis recovery; plugin itself is newer/niche. *(Note: standard offline Shamir via `banana-split` / SLIP-39 wrapping a plain `age` key avoids coupling runtime `sops` to `age-plugin-sss`!)* |
| **Passphrase-Protected Offline `age` Key + Paper QR (`qrencode`) / Encrypted USB** | Zero hardware lock-in, works on any bare Linux Live-ISO with zero plugins (`C1` Break-Glass gold standard!), trivially composable with a YubiKey as a second `role:human-root` recipient! | Daily use requires passphrase entry (unless paired with YubiKey for daily use while keeping paper/USB purely for cold break-glass). |

---

## 5. Dimension D — Layer 2 Attenuated Capabilities, Short-Lived Auth & Isolation (7 Contenders)

| Boundary / Threat | Contenders Evaluated | Empirical Verdict |
| :--- | :--- | :--- |
| **1. Co-located host daemons** (`vaultwarden`, `caddy`, `grafana`, `rclone`, `attic`) | Plain `/run/secrets` (`0400` owner) vs. **`systemd` `LoadCredential=`** (`$CREDENTIALS_DIRECTORY`) vs. `LoadCredentialEncrypted` | **`systemd` `LoadCredential=`** + `ProtectSystem=strict` / `PrivateTmp` / `NoNewPrivileges` / `DynamicUser` gives strict per-service kernel isolation from `/run/secrets/*` **without** `LoadCredentialEncrypted`'s TPM2 kernel-upgrade PCR fragility. |
| **2. SSH, Git push, & remote Nix builders (`ssh-ng://`)** | Static `authorized_keys` vs. **Offline OpenSSH Certificates (`ssh-keygen -s` + `TrustedUserCAKeys`, `-V +1h`, `-O force-command=...`)** vs. **Smallstep `step-ca`** (~30 MB Go OIDC→SSH/X.509 CA) vs. **Tailscale SSH** | - **Offline OpenSSH Certificates (`TrustedUserCAKeys`)**: **0 extra daemon, 0 RAM, 100% offline-verifiable**, time-bounded + command-restricted (`-O force-command=...`), native to `sshd`, `git`, and `nix copy` / opportunistic TUF remote builder! Ideal universal baseline + break-glass.<br>- **`step-ca`**: Lightweight (~30 MB) and great for automated OIDC→short-lived SSH/mTLS certs, *if* we want zero-touch automated cert minting later — adds one online service (cannot replace offline break-glass).<br>- **Tailscale SSH**: Deferred to `3B.2` (mesh choice); can layer on top for daily convenience if Tailscale/Headscale is chosen, **never** as sole access (`QA-07`). |
| **3. `aky`-owned offline-attenuatable capabilities** (AI epistemic zoom `C5`, Live-ISO single-host enrollment `C1`, future `aky` RPC/pull attestation) | **Eclipse Biscuit (`biscuit-auth` 6.x)** vs. **Macaroons** vs. **UCAN** | - **Macaroons**: Symmetric HMAC → requires sharing root secret across verifiers (fails decentralized multi-host verification!).<br>- **UCAN**: W3C DID / IPFS-oriented, heavier spec churn, weaker embedded policy language.<br>- **Eclipse Biscuit (`biscuit-auth`)**: Asymmetric Ed25519 + embedded Datalog, Rust-first, Wasm-ready, sub-ms offline verification, cryptographically enforces our exact Lean 4 theorems (`attenuation_monotonic`, `delegation_never_exceeds_delegator`, `delegation_respects_delegatee_forbid`)! |
| **4. External SaaS / CI boundaries** (GitHub Actions, Attic cache, B2/R2/GDrive) | Long-lived static PATs/keys vs. **Platform-native scoped credentials** | **GitHub OIDC** (ephemeral CI tokens wherever supported) + repo-scoped deploy keys (already working for `agy`!) + **Attic scoped JWTs** (push-only vs pull-only per cache) + per-bucket storage tokens, all modeled as resources in Cedar for mechanical blast-radius revocation. |
| **5. Heavy online secret brokers** | **OpenBao / HashiCorp Vault / SPIFFE-SPIRE** | **Rejected**: Heavy RAM/ops overhead + unseal ceremony on impermanent cold reboots directly violates `QA-07` and `D` (Low Maintenance). |

---

## 6. Day-to-Day UX, Manual Labor & AI-Agent Friendliness (`QA-10`) Deep Comparison

Dropping non-decisive tie-breakers (input count and one-time v1 migration) and evaluating strictly on **human manual labor**, **eliminating GUI clicking**, and **AI-agent (`agy`) workflow**:

### 6.1 `sops-nix` + `aky` vs. `agenix-rekey` (`storageMode = "local"`)
- **Automated Secret Generation (Zero Manual `openssl rand` / GUI Copying)**:
  - `agenix-rekey` ships built-in `agenix generate` (great UX!).
  - `sops-nix` lacks built-in generators, so pairing `sops-nix` with a thin **`aky secrets gen`** declarative generator command delivers identical zero-manual-creation UX for internal secrets (DB passwords, WireGuard/mesh keys, Attic signing keys, restic passwords, admin tokens).
- **Config Templating & Service Reload (`rclone.conf`, `vaultwarden.env`, `grafana.ini`)**:
  - **`sops-nix`**: First-class native `sops.templates` + `placeholder` + `restartUnits`/`reloadUnits`. Editing non-secret parts of a templated config requires **zero decryption keys** — `agy` can edit templates and run secretless QEMU VM tests autonomously!
  - **`agenix-rekey`**: No native multi-secret template engine or `restartUnits`. Requires custom systemd `ExecStartPre` glue, a 3rd project (`agenix-template`), or generator-baked templates (which force human master-key re-runs even for non-secret config edits).
- **AI-Agent Friendliness & `A2` Zero-Nix Alignment**:
  - **`sops-nix` (1 file per secret boundary, e.g. `secrets/vaultwarden.yaml`)**: Avoids monolithic YAML merge conflicts, keeps every file aligned to ONE Cedar audience, lets `agy` read key names & verify recipients statically in `2 ms` (zero keys, zero Nix eval!), and decouples secrets verification from Nix evaluation.
  - **`agenix-rekey`**: Couples recipient discovery to full NixOS `nixosConfigurations` evaluation (`agenix-rekey.configure`), hides internal key structure inside opaque `.age` blobs, and forces a human master-key `agenix rekey` round-trip before the flake even builds when host/secret assignments change.
- **Human Admin Key UX (Multi-Recipient `role:human-root`)**:
  - Both support **multi-recipient encryption**: **1 convenient daily key stored in Vaultwarden** (for zero-friction day-to-day CLI use via `rbw`/`bw`) **+ 1+ independent cold offline break-glass `age` keys** stored in multiple offline physical locations (encrypted USB + paper QR / Shamir), preserving daily UX while guaranteeing `C1` resurrection even if Vaultwarden/VPS is totally lost.

### 6.2 Layer 2 Daily UX Friction & Manual Labor
- **Daily Human SSH**: Raw `ssh-keygen -s -V +8h` creates painful daily manual re-signing friction (pushing users to extend lifetimes to 30–365d, which undermines short-lived security). `step-ca` eliminates manual signing via `step ssh login` OIDC browser popups, but introduces a CA daemon + daily browser rollover that breaks headless terminals/scripts unless wrapped carefully. **Lowest-friction baseline**: normal `ed25519` keys via `ssh-agent` over the mesh (optionally layered with mesh-native SSH in `3B.2`), reserving OpenSSH certificates only for **zero-daily-ceremony automation** (long-lived SSH **host** certs eliminating TOFU prompts on impermanent reinstalls, and command-restricted keys/certs for remote Nix builders) — plus offline break-glass SSH.
- **Zero-GUI External Credentials**: Prefer **GitHub OIDC** (0 static keys) and CLI-scriptable provisioning (`atticadm make-token`, `gh repo deploy-key`, provider CLIs) over manual web GUIs; track all issued tokens in Cedar for mechanical `aky blast-radius` rotation instructions.
- **AI-Agent & `aky` Capabilities**: **Eclipse Biscuit (`biscuit-auth`)** requires 0 online daemon and 0 browser popups — human mints a scoped token via CLI once, and `agy` can monotonically attenuate it offline for subagents.

---

## 7. Open Architectural Trade-offs Ready for Ratification
With the full space mapped (including UX, manual labor, and `QA-10` agent-friendliness), **Stage `3B.1`** cleanly boils down to **2 tightly related design decisions**:
1. **Fork `3B.1a` (Layer 1 At-Rest Secret Engine + Automated Generators + Multi-Recipient Human Root)**:
   - **`S-Sops` *(Recommended)***: Sealed `sops-nix` (1 file per secret boundary, native `templates` + `restartUnits` + `neededForUsers`) + **`aky secrets {sync, gen, audit}`** (Cedar→`.sops.yaml` compiler, idempotent secret generators, 2 ms zero-Nix ciphertext recipient audit) + multi-recipient human root (Vaultwarden daily key + multiple offline cold break-glass keys).
   - **`S-AgenixRekey`**: Sealed `agenix` + `agenix-rekey` (`storageMode = "local"`, built-in `agenix generate`, hides key names, no native multi-secret templates/`restartUnits`, couples rekeying to NixOS eval).
   - **`S-CustomAge`**: Zero-input pure-Rust `age` activator + systemd `LoadCredential` (full custom maintenance of boot activation/templates/reloads).
2. **Fork `3B.1b` (Layer 2 Attenuated Capabilities & Short-Lived Auth Stack)**:
   - **`C-Pragmatic` *(Recommended — Zero Daily Ceremony)***: `systemd LoadCredential=` (service isolation) + zero-daily-ceremony SSH (`ssh-agent` over mesh + optional mesh SSH in `3B.2` + zero-TOFU SSH host certs & command-restricted builder keys + offline break-glass) + CLI/OIDC-first external credentials (GitHub OIDC, `atticadm` scoped JWTs, `gh` deploy keys) + **Eclipse Biscuit (`biscuit-auth`)** for `aky`-owned offline-attenuatable capabilities (`C1` onboarding, `C5` AI zoom, subagent delegation).
   - **`C-StepCA`**: Everything in `C-Pragmatic` **plus** self-hosted **`step-ca`** (~30 MB Go daemon on `astrolabe` + OIDC) for automated 12–24h short-lived SSH user certs & internal mTLS certs (at the cost of a CA daemon + daily browser OIDC rollover).
   - **`C-OfflineSSHCA`**: Manual offline `ssh-keygen -s` user cert signing (30–90d window) instead of `step-ca` or `ssh-agent` keys.
