# Primitives

First-class structural primitives governing repository architecture, typing, and outputs.

[← Back to Main README](../../README.md)

## Catalog

| Primitive | Description | Instances | Definition |
| :--- | :--- | :--- | :--- |
| [`contract`](../contracts/README.md) | Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation. | 8 | [`primitives/contract/default.nix`](../../primitives/contract/default.nix) |
| [`feature`](../features/README.md) | Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system. | 27 | [`primitives/feature/default.nix`](../../primitives/feature/default.nix) |
| [`host`](../hosts/README.md) | Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems. | 2 | [`primitives/host/default.nix`](../../primitives/host/default.nix) |
| [`implementation`](../implementations/README.md) | Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations. | 8 | [`primitives/implementation/default.nix`](../../primitives/implementation/default.nix) |
| [`lib`](../lib/README.md) | Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository. | 16 | [`primitives/lib/default.nix`](../../primitives/lib/default.nix) |
