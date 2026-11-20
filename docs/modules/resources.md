# Module: `resources`

Declarative compute tiering, cgroups v2 limits, OOM ordering, power-aware throttling, local disk volumes, and remote storage budgets.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.resources`
- **Provided by**: contract [`resources`](../contracts/resources.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `resources.disk` | `submodule` | `{ }` | `{ ... }` | System-wide local disk caps and minimum free-space headroom policies for journald and Nix. |
| `resources.enable` | `boolean` | `false` | `true` | Whether to enable declarative system resource allocation contract. |
| `resources.oom` | `submodule` | `{ }` | `{ ... }` | Host-wide `systemd-oomd` userspace out-of-memory killer configuration. |
| `resources.power` | `submodule` | `{ }` | `{ ... }` | Power-aware battery throttling and `deferOnBattery` gating configuration. |
| `resources.profile` | `Host workload profile preset (`server` or `workstation`).` | `"server"` | `"workstation"` | Host workload profile preset (`server` or `workstation`) seeding default tier weights and power policy. |
| `resources.storageBudgets` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Declarative capacity budgets and alerting thresholds for remote `storage.slices`. |
| `resources.tiers` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Workload resource tiers mapped directly to top-level systemd `.slice` units under `-.slice`. |
| `resources.units` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Per-systemd-unit resource allocations assigning `.service` or `.mount` units to workload tiers with optional overrides. |
| `resources.volumes` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Dedicated local disk space allocations, preallocated quota volumes, and unmounted space reservations. |
