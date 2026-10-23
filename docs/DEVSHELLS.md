# DevShells Documentation

Master registry of interactive environments exported on `flake.devShells`.

[← Back to Main README](../README.md)

## Exported Development Shells

<a id="github-ssh"></a>
### `github-ssh`

Development shell configured with Bitwarden-authenticated GitHub SSH deploy keys.

```bash
nix develop .#github-ssh
```


<a id="master-ssh"></a>
### `master-ssh`

Administrative development shell configured with Bitwarden-managed master SSH private keys.

```bash
nix develop .#master-ssh
```


<a id="sops-admin"></a>
### `sops-admin`

Administrative secret editing shell with Bitwarden-authenticated master SOPS age key.

```bash
nix develop .#sops-admin
```


<a id="sops-host"></a>
### `sops-host`

Host-level development shell configured to decrypt local host SOPS secrets.

```bash
nix develop .#sops-host
```

