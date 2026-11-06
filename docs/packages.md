# Packages

Executable packages exported on `flake.packages`.

[← Back to Main README](../README.md)

<a id="antigravity"></a>
### `antigravity`

Google Antigravity

Provided by feature [`antigravity`](features/antigravity.md).

```bash
nix run .#antigravity
```

```bash
nix run github:LW-54/nixconf#antigravity
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
antigravity --help
```

Official Documentation: [https://github.com/jacopone/antigravity-nix](https://github.com/jacopone/antigravity-nix)

<a id="antigravity-cli"></a>
### `antigravity-cli`

Google Antigravity CLI - Describe what you need, and Antigravity handles the rest

Provided by feature [`antigravity`](features/antigravity.md).

```bash
nix run .#antigravity-cli
```

```bash
nix run github:LW-54/nixconf#antigravity-cli
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
antigravity --help
```

Official Documentation: [https://github.com/jacopone/antigravity-nix](https://github.com/jacopone/antigravity-nix)

<a id="antigravity-ide"></a>
### `antigravity-ide`

Google Antigravity IDE

Provided by feature [`antigravity`](features/antigravity.md).

```bash
nix run .#antigravity-ide
```

```bash
nix run github:LW-54/nixconf#antigravity-ide
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
antigravity-ide --help
```

Official Documentation: [https://github.com/jacopone/antigravity-nix](https://github.com/jacopone/antigravity-nix)

<a id="bw"></a>
### `bw`

Bitwarden CLI wrapper providing automated server configuration and session management.

Provided by feature [`bitwarden`](features/bitwarden.md).

```bash
nix run .#bw
```

```bash
nix run github:LW-54/nixconf#bw
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
bw --help
```

Official Documentation: [https://bitwarden.com/help/cli/](https://bitwarden.com/help/cli/)

<a id="docs"></a>
### `docs`

Unified documentation generator, validation test runner, and synchronization toolchain.

Provided by lib [`docs`](lib/docs.md).

```bash
nix run .#docs
```

```bash
nix run github:LW-54/nixconf#docs
```

#### Usage

Documentation generator and validator suite CLI.

```bash
# Write generated markdown documentation to repository tree
nix run .#docs -- --write

# Verify committed documentation matches evaluated specification
nix run .#docs -- --check

# List all generated documentation target files
nix run .#docs -- --list

# Export full semantic architecture graph as JSON
nix run .#docs -- --json

# Render Mermaid architecture diagram of a specific graph node
nix run .#docs -- --subgraph urn:nixconf:onto:contract:persistence
```

<a id="dolphin"></a>
### `dolphin`

Dolphin file manager wrapper bundled with QtWayland plugins and breeze theme assets.

Provided by feature [`dolphin`](features/dolphin.md).

```bash
nix run .#dolphin
```

```bash
nix run github:LW-54/nixconf#dolphin
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
dolphin --help
```

Official Documentation: [https://apps.kde.org/dolphin/](https://apps.kde.org/dolphin/)

<a id="foot"></a>
### `foot`

Application package foot.

Provided by feature [`foot`](features/foot.md).

```bash
nix run .#foot
```

```bash
nix run github:LW-54/nixconf#foot
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
foot --help
```

Official Documentation: [https://codeberg.org/dnkl/foot](https://codeberg.org/dnkl/foot)

<a id="git"></a>
### `git`

Application package git.

Provided by feature [`git`](features/git.md).

```bash
nix run .#git
```

```bash
nix run github:LW-54/nixconf#git
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
git --help
```

Official Documentation: [https://git-scm.com/doc](https://git-scm.com/doc)

<a id="nixconf-json"></a>
### `nixconf-json`

Exported Labeled Property Graph (LPG) representation of repository architecture in JSON format.

```bash
nix run .#nixconf-json
```

```bash
nix run github:LW-54/nixconf#nixconf-json
```

#### Usage

Semantic Code Property Graph JSON exporter. Directly outputs the complete graph containing all syntax, ontology, evaluation, and derivation nodes and edges.

```bash
# Query all package nodes with jq
nix run .#nixconf-json | jq '.nodes[] | select(.kind == "package")'
```
