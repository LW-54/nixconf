# Primitives Architecture & Catalog

Foundational abstractions governing components across the repository, declared in [`primitives/`](../primitives/).

[← Back to Main README](../README.md)

## Overview

A primitive defines the grammar, options schema, and export lifecycle for a class of system components. The repository defines 6 symmetrical primitives evaluated across a two-pass module pipeline:

| Primitive | Description | Source File | Documentation |
| :--- | :--- | :--- | :--- |
| **`primitive`** | Meta-primitive defining how primitives are constructed and registered. | [`../primitives/primitive/default.nix`](../primitives/primitive/default.nix) | [Primitives Catalog](PRIMITIVES.md) |
| **`host`** | Declarative target host machines binding hardware, platform, and enabled features. | [`../primitives/host/default.nix`](../primitives/host/default.nix) | [Hosts Documentation](HOSTS.md) |
| **`contract`** | Abstract contract interfaces defining shared option schemas decoupled from backends. | [`../primitives/contract/default.nix`](../primitives/contract/default.nix) | [Contracts Documentation](CONTRACTS.md) |
| **`implementation`** | Concrete capability providers satisfying contract interfaces with services and packages. | [`../primitives/implementation.nix`](../primitives/implementation.nix) | [Implementations Documentation](IMPLEMENTATIONS.md) |
| **`feature`** | Reusable system configurations and desktop services consuming contracts. | [`../primitives/feature.nix`](../primitives/feature.nix) | [Features Documentation](FEATURES.md) |
| **`lib`** | Pure reusable helper functions, data types, calculations, and presets. | [`../primitives/lib.nix`](../primitives/lib.nix) | [Library Documentation](LIB.md) |

## Two-Pass Evaluation Pipeline

1. **Pass 1 (`primitives/`)**: Evaluates primitive declarations using `lib.evalModules`. Injects `option` constructors and `export` helpers via `_module.args`. Resolves `options.primitive` and synthesizes Pass 2 options and export hooks.
2. **Pass 2 (`meta/` + `modules/`)**: Evaluates domain infrastructure instances (`hosts/`, `contracts/`, `implementations/`, `features/`) and meta-tooling (`parts.nix`, `docs/`) with zero cyclic dependencies.
