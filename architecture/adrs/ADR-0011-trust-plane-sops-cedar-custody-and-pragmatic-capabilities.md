---
id: ADR-0011
title: Stage 3B.1 — Trust Plane (Sealed sops-nix + Cedar Recipient Compiler, Multi-Recipient Custody & Break-Glass, and Pragmatic Layer-2 Capabilities)
type: adr
status: accepted
created: 2026-11-24
updated: 2026-11-24
domain: trust
tags: [adr, stage-3b, sops-nix, age, cedar, biscuit-auth, systemd-loadcredential, luks2, tpm2, lanzaboote, break-glass, emergency-ssh, oidc, generators]
rfd: null
assumptions: [A-004, A-005]
supersedes: null
superseded_by: null
summary: Ratifies Stage 3B.1 (L3+ + C1): (1) S-Sops — sealed Mic92/sops-nix (1 file per secret boundary, native templates & restartUnits, parameterized key path for impermanent vs WSL/standard disks) driven by aky secrets {sync, gen, audit} compiling .sops.yaml from Cedar and statically auditing ciphertext recipients; (2) Multi-recipient human root (Vaultwarden daily key + multiple offline cold break-glass age & emergency SSH keys) + LUKS2/TPM2-PIN/Lanzaboote on roaming laptops + zero-secret Live-ISO genesis; (3) C-Pragmatic — systemd LoadCredential= isolation, zero-daily-ceremony SSH (+ break-glass SSH key & optional zero-TOFU host certs), GitHub OIDC/CLI-scoped external tokens, and Eclipse Biscuit (biscuit-auth) for aky-owned offline-attenuatable capabilities.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Stage `3B.1`** (Trust Plane, implementing `ADR-0004` `L3+` and `ADR-0006` `C1`) based on the wide-spectrum empirical survey in [`RES-0015`](../research/RES-0015-trust-secrets-identity-and-capabilities.md) and explicit UX, manual-labor, and AI-agent (`QA-10`) evaluation:
1. **Layer 1 Secrets (`S-Sops`)**: Sealed `Mic92/sops-nix` (1 SOPS file per secret boundary, native `templates` + `restartUnits`/`reloadUnits` + `neededForUsers`, parameterized `config:sops-key-path` so impermanent VPS, standard-disk laptops/RPi, and diskless `NixOS-WSL` share one clean agent; drop-in `secrets-mock` for secretless QEMU tests) + outer `aky secrets {sync, gen, audit}` adapter compiling `.sops.yaml` from Cedar `L3+`, running idempotent secret generators, and statically auditing every ciphertext's `sops.age[].recipient` headers in `< 2 ms` (zero decryption keys in CI, zero domain strings in `aky-core`).
2. **Host & Human Key Custody + `C1` Break-Glass**: Multi-recipient `role:human-root` combining **1 convenient daily admin key in Vaultwarden** with **1+ independent cold offline break-glass `age` keys + an emergency break-glass SSH `ed25519` key** stored in multiple offline physical locations; **LUKS2 + TPM2-with-PIN + Lanzaboote Secure Boot (PCR 7) + printed recovery key** on roaming laptops; **zero production secrets on `Live-ISO`**; and explicit **re-key vs. Git-history value-rotation** checklists in `aky revoke`.
3. **Layer 2 Attenuated Capabilities (`C-Pragmatic`)**: Zero online Vault/CA daemon and zero daily SSH cert signing ceremony — **`systemd` `LoadCredential=`** + unit hardening for co-located services; zero-ceremony `ssh-agent` ed25519 over the mesh (+ offline emergency SSH public key + zero-TOFU host certs & command-restricted builder keys); **GitHub OIDC** & CLI-provisioned scoped tokens (`atticadm`, `gh`, per-bucket storage); and **Eclipse Biscuit (`biscuit-auth`)** for `aky`-owned offline-attenuatable capabilities (`C1` onboarding, `C5` AI epistemic zoom, subagent delegation).
<!-- abstract:end -->

# ADR-0011: Trust Plane — Secrets, Custody, Break-Glass & Pragmatic Attenuated Capabilities

## 1. Context & Problem Statement
Auditing v1 on disk ([`RES-0015`](../research/RES-0015-trust-secrets-identity-and-capabilities.md)) exposed two concrete security flaws alongside key UX constraints:
1. **Unchecked Blast-Radius Leak**: Hand-maintained `.sops.yaml` regex fallthrough (`^secrets/.*$` → `*all`) encrypted `astrolabe`'s production server secrets (Vaultwarden/auth, Attic, monitoring, backups, SSH, users) to roaming laptop `x240`.
2. **Break-Glass Circularity**: Fetching `SOPS_AGE_KEY` solely from Vaultwarden (hosted on `astrolabe`) violates `C1` Zero-Infra Break-Glass if `astrolabe` dies.
3. **UX, Zero-GUI & AI-Agent Mandate (`QA-10`)**: Day-to-day workflows must minimize manual GUI API-key clicking and daily re-signing rituals, allow convenient daily admin access via Vaultwarden while keeping cold offline recovery intact, and let AI agents (`agy`) inspect secret structure, verify recipients, refactor config templates, and run QEMU tests without ever touching plaintext secrets.
4. **Usage-Agnostic Core Mandate (`01cf1f3`)**: All SOPS, `age`, SSH, and Biscuit mechanics live strictly in outer adapters/agents — **zero** domain strings or secret-backend assumptions enter `aky-core` or `Aky/Spec/*`.

## 2. Decision Outcome

### 2.1 Fork `3B.1a` — Layer 1 Offline Root Identity & At-Rest Secrets (`S-Sops`)
- **Sealed `Mic92/sops-nix` Substrate Agent (`secrets-sops`)**:
  - Encapsulated behind raw `Partitioned` secret promises (`secret:need`, `secret:template`), swappable for `secrets-mock` in simulated QEMU/install test scopes (`C7`, `QA-02`) or a future secret backend with zero edits to service agents.
  - **1 SOPS file per secret boundary** (`secrets/<boundary>.yaml`, e.g. `secrets/vaultwarden.yaml`, `secrets/wifi-eduroam.yaml`): eliminates monolithic YAML merge conflicts, maps each file to exactly one Cedar audience, and preserves plaintext key names for zero-key AI inspection (`QA-10`).
  - **Parameterized Key Path (`QA-03`)**: `secrets-sops` consumes `config:sops-key-path` as a promise (`/persist/sops-nix/key.txt` on impermanent `neededForBoot = true` hosts to avoid stage-1 `/etc/ssh` bind-mount races; `/var/lib/sops-nix/key.txt` on standard-disk laptops, `aarch64` RPi, and diskless `NixOS-WSL`).
  - **Native `sops.templates` + `restartUnits`/`reloadUnits` + `neededForUsers`**: Enables non-secret template refactors by `agy` with zero decryption keys, automatic service reloads on rotation, and early-boot user password hashes.
  - **Standalone Non-NixOS Support (`QA-09`)**: Standard `sops` + `age` CLI tools (delivered via `W-Std` standalone packages / `aky secrets`) operate identically on non-NixOS Linux, WSL, and rescue environments without NixOS modules.
- **Outer `aky secrets` Tooling (Strictly Above `aky-core`)**:
  - `aky secrets sync`: Compiles `.sops.yaml` deterministically from the Cedar `L3+` Boolean policy graph and invokes `sops updatekeys` — zero hand-maintained regex fallthroughs.
  - `aky secrets audit`: Parses plaintext `sops.age[].recipient` headers across `secrets/**/*.yaml` in `< 2 ms` (zero decryption keys, zero Nix eval) and hard-fails CI on any unauthorized or missing recipient.
  - `aky secrets gen`: Executes declarative, idempotent local generators (random passwords, WireGuard/mesh keys, Attic signing keys, restic passwords, admin tokens) writing directly into SOPS files — eliminating manual `openssl rand` copy-pasting.
  - `aky revoke <principal>`: Computes exact mechanical blast radius from Cedar `L3+` and outputs a two-phase rotation checklist explicitly distinguishing **re-keying** (`aky secrets sync`, blocking future access) from **mandatory underlying value rotation** (required because Git history retains historical ciphertexts encrypted to the compromised key!).

### 2.2 Host Custody, Multi-Recipient Human Root & Emergency Break-Glass (`C1`)
- **Multi-Recipient Human Root (`role:human-root`)**: Every secret encrypts simultaneously to:
  1. **Daily admin key**: stored conveniently in **Vaultwarden** (accessible via `rbw`/`bw` shell hook for zero-friction day-to-day administration), AND
  2. **Cold offline break-glass key(s)**: 1+ independent offline `age` private keys stored across multiple physical locations (e.g., encrypted USB + printed paper QR / offline Shamir) with zero Vaultwarden/VPS/GitHub dependency.
- **Emergency Break-Glass SSH Key**: An independent offline `ed25519` SSH keypair whose **public key** is declaratively baked into `authorizedKeys` on managed hosts (key-only SSH, `PasswordAuthentication = false`, `PermitRootLogin = "no"`) and whose **private key** lives in the exact same offline break-glass kit as the cold `age` key — preventing lockout during mesh, Vaultwarden, or daily-laptop failure with zero daily labor.
- **Physical Host Custody**:
  - **VPS (`astrolabe`)**: `/persist/sops-nix/key.txt` (`0400`, `neededForBoot = true`), encrypted backup under `role:human-root` only.
  - **Roaming Laptops (`x240`, ZenBook Duo, TUF)**: **LUKS2 full-disk encryption** + `systemd-cryptenroll --tpm2-with-pin=yes` (mitigating bus-sniffing / `FaulTPM` attacks against zero-PIN TPM auto-unlock!) + **Lanzaboote Secure Boot (PCR 7)** where supported + offline printed LUKS recovery key; host `age` key lives inside LUKS-encrypted `/persist`.
  - **Ephemeral `Live-ISO`**: Zero production keys or secrets baked in; new hosts generate a local keypair on `/persist`, verify fingerprint with admin, register public key + attributes into Git, rekey, and converge to $g_0$.

### 2.3 Fork `3B.1b` — Layer 2 Attenuated Capabilities & Isolation (`C-Pragmatic`)
- **Co-Located Host Services**: **`systemd` `LoadCredential=`** (`$CREDENTIALS_DIRECTORY`) + unit hardening (`ProtectSystem=strict`, `PrivateTmp`, `NoNewPrivileges`, `DynamicUser` where applicable) — zero ambient `/run/secrets` visibility between sibling daemons, zero manual labor, and zero `LoadCredentialEncrypted` TPM-PCR kernel-upgrade breakage.
- **Daily SSH & Remote Builders**: Zero daily signing ceremony — normal `ed25519` keys in `ssh-agent` over the mesh (optionally paired with mesh-native SSH in Stage `3B.2`), emergency offline SSH key for break-glass, optional long-lived **OpenSSH Host Certificates** (killing TOFU prompts on impermanent reinstalls), and command-restricted keys/certs (`nix-store --serve`) for opportunistic remote Nix builders (e.g., TUF laptop on AC).
- **External CI / Cache / Cloud Credentials**: **GitHub OIDC** wherever supported (0 static keys) + CLI-provisioned narrow tokens (`atticadm make-token`, `gh repo deploy-key`, per-bucket storage credentials) tracked as Cedar resources — minimizing web GUI clicks.
- **`aky`-Owned Attenuated Capabilities**: **Eclipse Biscuit (`biscuit-auth` 6.x, Ed25519 Datalog)** for `C1` single-host enrollment, `C5` read-only AI epistemic zoom, and offline subagent attenuation — zero online broker daemon, 0 RAM on `astrolabe`, offline-verifiable, matching our proved Lean 4 delegation theorems (`attenuation_monotonic`, `delegation_never_exceeds_delegator`, `delegation_respects_delegatee_forbid`).

## 3. Requirements Compliance Audit (`CHARTER.md`, `ADR-0004`, `ADR-0006`)
| Requirement / Scenario | Compliance Status | Verification Mechanism |
| :--- | :---: | :--- |
| **Priority `B > E > D > A > C`** | **PASS** | Offline cold boot (`B`), templates/generators/Biscuit (`E`), 1 clean input & 0 online CA/Vault daemon (`D`), pure core + `<2 ms` audit (`A`/`C`). |
| **`QA-02` Swappability & Multi-Instance** | **PASS** | `secrets-sops` sealed behind `Partitioned` promises; drop-in `secrets-mock` for QEMU tests (`C7`). |
| **`QA-03` Exotic Targets (`WSL`, `RPi`, `ISO`, `Chromebook`)** | **PASS** | Parameterized `config:sops-key-path` (no hardcoded `/persist`), native `aarch64` `sops-nix`, zero-secret `Live-ISO`. |
| **`QA-07` Offline Vitality & Graceful Degradation** | **PASS** | Zero online Vault/CA/OIDC dependency at boot or during network partition; offline break-glass `age` + SSH keys. |
| **`QA-09` Standalone Portability (`nix run`)** | **PASS** | Standard `sops`/`age` CLI works on any non-NixOS Linux/WSL/macOS via `W-Std` packages without NixOS modules. |
| **`QA-10` AI Friendliness & Least Privilege** | **PASS** | Cedar `forbid` blocks `actor:ai-agent` from prod secrets; `agy` inspects plaintext YAML keys & recipients in `<2 ms`, edits templates freely, and runs secretless QEMU tests. |
| **Usage-Agnostic Core (`01cf1f3`)** | **PASS** | Zero SOPS/`age`/SSH/Biscuit logic enters `aky-core` or `Aky/Spec/*`; all trust adapters sit above the pure kernel. |

## 4. Links
- Research Dossier: [`RES-0015`](../research/RES-0015-trust-secrets-identity-and-capabilities.md)
- Foundation: [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md), [`ADR-0006`](ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md), [`ADR-0007`](ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md)
- Next Stage: **Stage `3B.2` — Mesh Network Fabric (`A-006`)**
