# Development Shells

Interactive environments exported on `flake.devShells`.

[← Back to Main README](../README.md)

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
