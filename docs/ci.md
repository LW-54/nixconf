# Continuous Integration & Automation

Declarative GitHub Actions workflow compilation, Cachix binary cache synchronization, and drift verification engine.

[← Back to Main README](../README.md)

## Overview

CI workflows in `nixconf` are declared natively in pure Nix under `config.workflow.<name>` rather than being hand-maintained in YAML. Workflows are:
1. **Declarative**: Expressed as Nix attribute sets or inline YAML parsed via [`ci`](lib/ci.md) (`lib.ci.fromYAML`).
2. **Linted & Validated**: Validated at build time with `actionlint` and formatted with `yamlfmt` via `lib.ci.toYAML`.
3. **Drift-Protected**: The flake check `checks.ci` validates that `.github/workflows/*.yml` in the working tree match evaluated Nix specifications.

## CLI Usage (`ci`)

The repository exports a dedicated `ci` package (packages.md#ci) to synchronize and verify GitHub Actions workflows:

```bash
# Verify that committed workflows match evaluated Nix specifications (used in CI)
nix run .#ci -- --check

# Compile and synchronize workflows into .github/workflows/ (removing stale ones)
nix run .#ci -- --write
```

## Declared Workflows

| Workflow | Target File | Description |
| :--- | :--- | :--- |
| **`build`** | `.github/workflows/build.yml` | CI & Binary Cache Push |
| **`host-tests`** | `.github/workflows/host-tests.yml` | Host Verification & VM Tests |

### Workflow Details

- **`build`** ([`meta/ci/build.nix`](../meta/ci/build.nix)): Runs on pull requests and pushes to `main`. Executes formatting (`lint`), meta checks (`schemas`, `docs`, `ci`), per-host verification & toplevel builds (`host`), and a single-eval batched `packages-and-shells` job in full parallel while caching `~/.cache/nix` and pushing to the `lw-54` Cachix binary cache.
- **`host-tests`** ([`meta/ci/host-tests.nix`](../meta/ci/host-tests.nix)): Parallelized matrix verification executing `vm-tests`, `install-tests`, and `static-tests` as independent concurrent jobs via direct `nix build` targets, with `~/.cache/nix` caching, disk-change detection, and 4h install cooldowns.

## Library Reference

CI compilation and reflection utilities are exposed under the pure library namespace:

- **[flake.lib.ci](lib/ci.md)**: Documented functions including `fromYAML`, `toYAML`, and `collectBuildables`.
