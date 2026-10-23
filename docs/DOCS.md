# Documentation Pipeline Reference

Pure-Nix documentation generation architecture, Labeled Property Graph (LPG) IR, and CLI toolchain.

[← Back to Main README](../README.md)

## Architecture Overview

The documentation generator is implemented as a pure-Nix evaluation pipeline structured into modular components:

- [`modules/meta/docs/spec/`](../modules/meta/docs/spec): Formal schemas, node types, edge kinds, and verification assertions.
- [`modules/meta/docs/parser.nix`](../modules/meta/docs/parser.nix): RFC 145 docstring parser extracting summaries, argument inputs, types, and examples.
- [`modules/meta/docs/graph/`](../modules/meta/docs/graph): LPG property graph builder synthesizing `nixconf.json`.
- [`modules/meta/docs/mermaid.nix`](../modules/meta/docs/mermaid.nix): Declarative Mermaid diagram visualizer with custom styling.
- [`modules/meta/docs/markdown/`](../modules/meta/docs/markdown): Markdown synthesizers generating the repository documentation suite.
- [`modules/meta/docs/cli.nix`](../modules/meta/docs/cli.nix): CLI application wrapper providing `nix run .#docs`.

## Command Reference

```bash
# Synchronize all documentation files directly into working tree
nix run .#docs -- --write

# Verify that documentation suite is synchronized (non-blocking)
nix run .#docs -- --check

# Verify documentation with zero-debt enforcement
nix run .#docs -- --check --strict

# Inspect evaluated LPG property graph in JSON format
nix run .#docs -- --json
```
