# Documentation Pipeline Reference

Pure-Nix documentation generation architecture, Labeled Property Graph (LPG) IR, and CLI toolchain.

[← Back to Main README](../README.md)

## Architecture Overview

The documentation generator is implemented as a pure-Nix evaluation pipeline structured into modular components:

- [`primitives/primitive/lib/check.nix`](../primitives/primitive/lib/check.nix): Formal specification checks and verification assertions.
- [`meta/docs/parser.nix`](../meta/docs/parser.nix): RFC 145 docstring parser extracting summaries, argument inputs, types, and examples.
- [`meta/docs/graph/`](../meta/docs/graph): LPG property graph builder synthesizing `nixconf.json`.
- [`meta/docs/mermaid.nix`](../meta/docs/mermaid.nix): Declarative Mermaid diagram visualizer with custom styling.
- [`meta/docs/markdown/`](../meta/docs/markdown): Markdown synthesizers generating the repository documentation suite.
- [`meta/docs/cli.nix`](../meta/docs/cli.nix): CLI application wrapper providing `nix run .#docs`.

## Command Reference

```bash
# Synchronize all documentation files directly into working tree
nix run .#docs -- --write

# Verify that documentation suite is synchronized (non-blocking)
nix run .#docs -- --check

# Inspect evaluated LPG property graph in JSON format
nix run .#docs -- --json
```
