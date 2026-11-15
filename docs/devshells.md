# Development Shells

Interactive environments exported on `flake.devShells`.

[← Back to Main README](../README.md)

<a id="default"></a>
### `default`

Development shell default.

```bash
nix develop .#default
```

```bash
nix develop github:LW-54/nixconf#default
```

<a id="github-cli"></a>
### `github-cli`

Development shell configured with GitHub CLI (gh) and SOPS-encrypted GH_TOKEN.

Provided by feature [`git`](features/git.md).

```bash
nix develop .#github-cli
```

```bash
nix develop github:LW-54/nixconf#github-cli
```

#### Usage

Development shell configured with the GitHub CLI (`gh`) and a SOPS-backed `GH_TOKEN`.

Unlocks the master SOPS age key via Bitwarden (item `c2352759-f5e3-40af-a797-89bd86e230d2`) if `SOPS_AGE_KEY` is not already set, decrypts `token` from `secrets/admin/github.yaml`, and exports `GH_TOKEN`.

<a id="github-ssh"></a>
### `github-ssh`

Development shell configured with Bitwarden-authenticated GitHub SSH deploy keys.

Provided by feature [`git`](features/git.md).

```bash
nix develop .#github-ssh
```

```bash
nix develop github:LW-54/nixconf#github-ssh
```

#### Usage

Development shell configured with Bitwarden-authenticated GitHub deploy keys.

Loads the GitHub deploy key from Bitwarden item `334fd4e6-1911-4017-9232-9463e6b70e21` into a secure temporary file in `$TMPDIR` (mode `0600`) and exports `GIT_SSH_COMMAND` to use it with `IdentitiesOnly=yes`. The temporary key file is automatically removed on shell exit via `trap`.

<a id="master-ssh"></a>
### `master-ssh`

Administrative development shell configured with Bitwarden-managed master SSH private keys.

Provided by feature [`ssh`](features/ssh.md).

```bash
nix develop .#master-ssh
```

```bash
nix develop github:LW-54/nixconf#master-ssh
```

#### Usage

Administrative shell configured with the master SSH deployment key.

Extracts the master deployment identity (`6b22304d-b9cf-43ca-a483-3c97ceca6717`) from Bitwarden and exports `GIT_SSH_COMMAND` for remote machine deployment, maintenance, and cluster orchestration.

<a id="sops-admin"></a>
### `sops-admin`

Administrative secret editing shell with Bitwarden-authenticated master SOPS age key.

Provided by implementation [`sops`](implementations/sops.md).

```bash
nix develop .#sops-admin
```

```bash
nix develop github:LW-54/nixconf#sops-admin
```

#### Usage

Operational administration shell containing `sops` and age decryption keys.

Used to inspect, edit, and re-key encrypted repository secrets in `modules/secrets/secrets.yaml`:

```bash
# Edit secrets file
sops modules/secrets/secrets.yaml

# Update keys across file
sops updatekeys modules/secrets/secrets.yaml
```

<a id="sops-host"></a>
### `sops-host`

Host-level development shell configured to decrypt local host SOPS secrets.

Provided by implementation [`sops`](implementations/sops.md).

```bash
nix develop .#sops-host
```

```bash
nix develop github:LW-54/nixconf#sops-host
```

#### Usage

Operational host inspection shell configured with the host's local age key.

Reads the age private key from `/persist/sops-nix/key.txt` (prompting for `sudo` if the key file is restricted) and exports `SOPS_AGE_KEY` so host secrets can be directly inspected, decrypted, and verified on the machine without requiring administrative Bitwarden master vault credentials:

```bash
# Inspect and decrypt all secrets in file
sops -d modules/secrets/secrets.yaml

# Extract a specific secret value
sops -d --extract '["default-user-password-hash"]' modules/secrets/secrets.yaml
```

<a id="storage-admin"></a>
### `storage-admin`

Administrative storage reconciliation shell unlocking SOPS_AGE_KEY via Bitwarden and exposing nixconf-storage.

Provided by contract [`storage`](contracts/storage.md).

```bash
nix develop .#storage-admin
```

```bash
nix develop github:LW-54/nixconf#storage-admin
```

#### Usage

Administrative shell for inspecting, reconciling, and bootstrapping declarative storage infrastructure.

```bash
# Enter shell (unlocks SOPS_AGE_KEY via Bitwarden)
nix develop .#storage-admin

# Inspect fleet providers and resolved slices
nixconf-storage --list

# Verify SOPS secrets and Hetzner Storage Box API drift
nixconf-storage --check

# Reconcile Hetzner subaccounts, snapshot plans, and missing SOPS secrets
nixconf-storage --write
```
