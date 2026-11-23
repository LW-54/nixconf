# Packages

Executable packages exported on `flake.packages`.

[← Back to Main README](../README.md)

<a id="agy"></a>
### `agy`

Google Antigravity CLI - Describe what you need, and Antigravity handles the rest

Provided by feature [`antigravity`](features/antigravity.md).

```bash
nix run .#agy
```

```bash
nix run github:LW-54/nixconf#agy
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
agy --help
```

Official Documentation: [https://github.com/jacopone/antigravity-nix](https://github.com/jacopone/antigravity-nix)

<a id="agy-api"></a>
### `agy-api`

Google Antigravity CLI - Describe what you need, and Antigravity handles the rest

Provided by feature [`antigravity`](features/antigravity.md).

```bash
nix run .#agy-api
```

```bash
nix run github:LW-54/nixconf#agy-api
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
agy-api --help
```

Official Documentation: [https://github.com/jacopone/antigravity-nix](https://github.com/jacopone/antigravity-nix)

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

<a id="attic-bootstrap"></a>
### `attic-bootstrap`

One-command Attic binary cache and GitHub Actions SOPS bootstrap helper.

Provided by feature [`attic`](features/attic.md).

```bash
nix run .#attic-bootstrap
```

```bash
nix run github:LW-54/nixconf#attic-bootstrap
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
attic-bootstrap --help
```

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

<a id="ci"></a>
### `ci`

GitHub Actions CI workflow synchronization and drift verification CLI

Provided by lib [`ci`](lib/ci.md).

```bash
nix run .#ci
```

```bash
nix run github:LW-54/nixconf#ci
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
nixconf-ci --help
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

<a id="menu"></a>
### `menu`

Interactive fuzzy command palette and task runner dynamically derived from nixconf flake outputs.

```bash
nix run .#menu
```

```bash
nix run github:LW-54/nixconf#menu
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
menu --help
```

<a id="micro"></a>
### `micro`

Modern and intuitive terminal-based text editor

Provided by feature [`micro`](features/micro.md).

```bash
nix run .#micro
```

```bash
nix run github:LW-54/nixconf#micro
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
micro --help
```

Official Documentation: [https://micro-editor.github.io](https://micro-editor.github.io)

<a id="prof"></a>
### `prof`

General-purpose Nix and command profiler with transparent nix PATH shim, SVG flamegraphs, Speedscope timelines, cache-diff, and CI telemetry.

```bash
nix run .#prof
```

```bash
nix run github:LW-54/nixconf#prof
```

#### Usage

Profile any Nix command, script, or pre-commit hook with full eval flamegraphs and Gantt timelines:

```bash
# Trace any command or script (auto-profiles all nested nix calls)
nixprof trace -- ./.githooks/pre-commit

# Statistical multi-run benchmark via hyperfine
nixprof bench --runs 5 "nix flake check --no-build"

# Native CPU profiling via samply (Firefox Profiler UI)
nixprof native -- nix eval .#nixosConfigurations.x240.config.system.build.toplevel.drvPath

# Derivation cache-invalidation matrix + nix-diff root causes
nixprof cache-diff --flake-all --mutate README.md --mutate modules/features/foot.nix

# GitHub Actions workflow/job/step telemetry
nixprof ci

# Side-by-side comparison of two saved reports
nixprof compare before.json after.json
```

<a id="storage"></a>
### `storage`

Declarative multi-provider storage reconciler and drift checker across all fleet hosts.

Provided by contract [`storage`](contracts/storage.md).

```bash
nix run .#storage
```

```bash
nix run github:LW-54/nixconf#storage
```

#### Usage

Inspect declared storage topology, audit SOPS secrets, and reconcile Hetzner Storage Box API state.

```bash
# List evaluated providers, instances, shared/per-host slices, and endpoints
nix run .#storage -- --list

# Verify SOPS secrets and Hetzner Storage Box API state (read-only)
nix develop .#storage-admin --command nixconf-storage --check

# Reconcile Hetzner subaccounts, snapshot plans, and encrypted SOPS secrets
nix develop .#storage-admin --command nixconf-storage --write
```

<a id="test"></a>
### `test`

Runs test tiers (eval, inspect, vm, install), multi-node scenarios, and interactive test VMs.

```bash
nix run .#test
```

```bash
nix run github:LW-54/nixconf#test
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
nixconf-test --help
```

<a id="zed"></a>
### `zed`

High-performance, multiplayer code editor from the creators of Atom and Tree-sitter

Provided by feature [`zed`](features/zed.md).

```bash
nix run .#zed
```

```bash
nix run github:LW-54/nixconf#zed
```

#### Help & Documentation

Display command-line flags and subcommands:

```bash
zeditor --help
```

Official Documentation: [https://zed.dev](https://zed.dev)
