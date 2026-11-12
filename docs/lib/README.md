# Library

Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.

[← Back to Main README](../../README.md)

## Specification

- **Declared as**: `lib.<name>` in any flake-parts module under `modules/` or `primitives/`
- **Primitive definition**: [`primitives/lib/default.nix`](../../primitives/lib/default.nix)
- **Instances**: 16

## Option Schema (`lib.<name>`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `description` | `string` | **required** | Formal description of this primitive instance. |
| `symbols` | `attribute set of raw value` | `{ }` | Exported library functions and values under flake.lib.<name>.<symbol>. |

## Declaration Example

Smallest declaration in the repository, [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix):

```nix
{lib, ...}: {
  contract.default-user = {
    description = "Default primary user account identification, credentials, and configuration injection.";

    options = {
      enable = lib.mkEnableOption "system default user contract" // {default = true;};

      username = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "Username of the default user account.";
      };

      githubUsername = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "GitHub username of the default user.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        example = "alice@example.com";
        description = "Primary email address associated with the default user.";
      };

      fullName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "Alice Smith";
        description = "Display name / GECOS description of the default user.";
      };
    };
  };
}
```

## Catalog

| Library Namespace | Description | Exported Functions | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`backup`](backup.md) | Library helpers and constructors for the 'backup' contract. | [`defaultPruneOpts`](backup.md#defaultPruneOpts), [`defaultTimerConfig`](backup.md#defaultTimerConfig), [`mkConfig`](backup.md#mkConfig), [`mkOption`](backup.md#mkOption) | [`modules/contracts/backup.nix`](../../modules/contracts/backup.nix) | [More →](backup.md) |
| [`bitwarden`](bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [`mkShell`](bitwarden.md#mkShell), [`mkValue`](bitwarden.md#mkValue) | [`modules/features/bitwarden.nix`](../../modules/features/bitwarden.nix) | [More →](bitwarden.md) |
| [`ci`](ci.md) | Continuous integration workflow helpers, YAML serialization, and derivation collection utilities. | [`collectBuildables`](ci.md#collectBuildables), [`fromYAML`](ci.md#fromYAML), [`toYAML`](ci.md#toYAML) | [`meta/ci/lib.nix`](../../meta/ci/lib.nix) | [More →](ci.md) |
| [`default-user`](default-user.md) | Library helpers and constructors for the 'default-user' contract. | — | [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix) | [More →](default-user.md) |
| [`disko`](disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`mkLayout`](disko.md#mkLayout) | [`modules/features/disko.nix`](../../modules/features/disko.nix) | [More →](disko.md) |
| [`docs`](docs.md) | Documentation generator turning the `docs` page registry, primitive metadata, and the architecture graph into markdown. | [`audit`](docs.md#audit), [`generateAll`](docs.md#generateAll), [`relPath`](docs.md#relPath) | [`meta/docs/render.nix`](../../meta/docs/render.nix) | [More →](docs.md) |
| [`graph`](graph.md) | Canonical Semantic Code Property Graph (CPG) framework, algebraic calculus, and architectural projection functors. | [`backwardSlice`](graph.md#backwardSlice), [`buildCPG`](graph.md#buildCPG), [`buildGraph`](graph.md#buildGraph), [`buildSpine`](graph.md#buildSpine), [`buildSpineGraph`](graph.md#buildSpineGraph), [`filterGraph`](graph.md#filterGraph), [`findConsumers`](graph.md#findConsumers), [`findImplementers`](graph.md#findImplementers), [`findOptionFlows`](graph.md#findOptionFlows), [`forwardSlice`](graph.md#forwardSlice), [`getNeighborhood`](graph.md#getNeighborhood), [`getOptionValue`](graph.md#getOptionValue), [`query`](graph.md#query), [`render`](graph.md#render), [`renderEntity`](graph.md#renderEntity), [`renderMatrix`](graph.md#renderMatrix), [`renderMermaid`](graph.md#renderMermaid), [`renderTable`](graph.md#renderTable), [`renderTree`](graph.md#renderTree), [`toArchitectureLPG`](graph.md#toArchitectureLPG) | [`meta/graph/default.nix`](../../meta/graph/default.nix) | [More →](graph.md) |
| [`home`](home.md) | Library helpers and constructors for the 'home' contract. | [`mkConfig`](home.md#mkConfig), [`mkOption`](home.md#mkOption), [`types`](home.md#types) | [`modules/contracts/home.nix`](../../modules/contracts/home.nix) | [More →](home.md) |
| [`lw`](lw.md) | Primary human user account orchestration and identity provisioning. | [`email`](lw.md#email), [`githubUsername`](lw.md#githubUsername), [`username`](lw.md#username) | [`modules/implementations/lw.nix`](../../modules/implementations/lw.nix) | [More →](lw.md) |
| [`persistence`](persistence.md) | Library helpers and constructors for the 'persistence' contract. | [`entries`](persistence.md#entries), [`mkConfig`](persistence.md#mkConfig), [`mkOption`](persistence.md#mkOption), [`types`](persistence.md#types) | [`modules/contracts/persistence.nix`](../../modules/contracts/persistence.nix) | [More →](persistence.md) |
| [`primitive`](primitive.md) | Primitives framework helper functions, option constructors, and utilities. | [`check`](primitive.md#check), [`option`](primitive.md#option), [`output`](primitive.md#output), [`parser`](primitive.md#parser), [`schemas`](primitive.md#schemas), [`unwrapLib`](primitive.md#unwrapLib) | [`primitives/primitive/default.nix`](../../primitives/primitive/default.nix) | [More →](primitive.md) |
| [`reverse-proxy`](reverse-proxy.md) | Library helpers and constructors for the 'reverse-proxy' contract. | [`mkConfig`](reverse-proxy.md#mkConfig), [`mkOption`](reverse-proxy.md#mkOption), [`types`](reverse-proxy.md#types) | [`modules/contracts/reverse-proxy.nix`](../../modules/contracts/reverse-proxy.nix) | [More →](reverse-proxy.md) |
| [`secrets`](secrets.md) | Library helpers and constructors for the 'secrets' contract. | [`mkConfig`](secrets.md#mkConfig), [`mkOption`](secrets.md#mkOption), [`types`](secrets.md#types) | [`modules/contracts/secrets.nix`](../../modules/contracts/secrets.nix) | [More →](secrets.md) |
| [`sops`](sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`mkHostShell`](sops.md#mkHostShell), [`mkTestSecrets`](sops.md#mkTestSecrets) | [`modules/implementations/sops.nix`](../../modules/implementations/sops.nix) | [More →](sops.md) |
| [`user`](user.md) | Normal user account helper functions and querying utilities. | [`forNormalUsers`](user.md#forNormalUsers), [`normalUserNames`](user.md#normalUserNames), [`normalUsers`](user.md#normalUsers) | [`modules/features/user.nix`](../../modules/features/user.nix) | [More →](user.md) |
| [`wayland`](wayland.md) | Library helpers and constructors for the 'wayland' contract. | [`mkConfig`](wayland.md#mkConfig), [`mkOption`](wayland.md#mkOption), [`types`](wayland.md#types) | [`modules/contracts/wayland.nix`](../../modules/contracts/wayland.nix) | [More →](wayland.md) |
