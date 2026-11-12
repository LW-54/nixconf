# Documentation System

How the documentation is generated from code, and where to declare the documentation that cannot be inferred.

[← Back to Main README](../README.md)

> [!TIP]
> **Documentation Health**: **100.0%** (164/164 items documented).
> See the full [Documentation Coverage & Quality Audit](coverage.md).

## Principles

- **Structure comes from code.** Pages, catalogs, option schemas, relationships, diagrams, source links, and examples are computed from primitives, evaluated option declarations, module definition locations, and the architecture graph.
- **Prose lives next to code.** Anything that cannot be inferred (guides, curated examples, module descriptions, extra facts) is declared in parallel namespaces (`docs.pages`, `docs.sections`) right next to the code it describes.
- **Minimal page and section model.** A page is strictly a `path` and a set of `sections`. A section is strictly an `order` and a markdown template function (`content = ctx: ...`).
- **No special cases.** A new primitive, instance, module, package, or shell is documented automatically; the generic renderer never names a specific instance.

## Pipeline

- Pass 1 (`primitives/`) exports parallel `docs.pages` for each primitive and its instances via deferred modules.
- Pass 2 modules declare instances; operational configurations remain 100% pure and unpolluted.
- `meta/graph` builds the Semantic Code Property Graph used for relationships, diagrams, and node links.
- `meta/docs` turns the page registry (`config.docs.pages`) into markdown; `nix run .#docs -- --write` writes it and `checks.docs` keeps it in sync.

Generator sources:

| File | Role |
| :--- | :--- |
| [`meta/docs/audit.nix`](../meta/docs/audit.nix) | Documentation Quality & Coverage Audit Engine Analyzes repository docstrings, schema options, library symbols, and primitives. Evaluates purely on AST and Onto spine in < 0.4s without forcing host fixpoints. |
| [`meta/docs/cli.nix`](../meta/docs/cli.nix) | `nix run .#docs` CLI and the `checks.docs` flake check. Command-line flags are declared once in `commands` and reused for `--help` and the docs page. |
| [`meta/docs/lib/context.nix`](../meta/docs/lib/context.nix) | Context engine: builds the per-page evaluation and querying context (`ctx`) passed to section rendering functions. |
| [`meta/docs/lib/install.nix`](../meta/docs/lib/install.nix) | Shared host installation & deployment guide renderer. Used by both README.md (generic template) and host pages (targeted host). |
| [`meta/docs/lib/markdown.nix`](../meta/docs/lib/markdown.nix) | Markdown toolkit shared by every page: relative links, tables, code blocks, collapsible details, ASCII trees, and compact value rendering (`ctx.md`). |
| [`meta/docs/lib/outputs.nix`](../meta/docs/lib/outputs.nix) | Helpers for documenting non-primitive flake outputs: NixOS modules, packages, and development shells. |
| [`meta/docs/options.nix`](../meta/docs/options.nix) | Schema of the documentation registry: `docs.pages` (pages made of sections), `docs.sections.<kind>` (instance page templates), and `docs.project` metadata. |
| [`meta/docs/pages/coverage.nix`](../meta/docs/pages/coverage.nix) | Documentation Composition & Synthesis Engine Automatically synthesizes docs/coverage.md (Quality & Coverage Dashboard) and injects the condensed health status card into docs/documentation.md. |
| [`meta/docs/pages/devshells.nix`](../meta/docs/pages/devshells.nix) | Documentation page for interactive development shells (docs/devshells.md). |
| [`meta/docs/pages/guide.nix`](../meta/docs/pages/guide.nix) | Developer guide of the documentation system itself (docs/documentation.md): how pages are generated and where to put hand-written documentation. |
| [`meta/docs/pages/modules.nix`](../meta/docs/pages/modules.nix) | Documentation pages for NixOS modules: catalog page (docs/modules/README.md) and individual module pages (docs/modules/<name>.md). |
| [`meta/docs/pages/packages.nix`](../meta/docs/pages/packages.nix) | Documentation page for executable packages (docs/packages.md). |
| [`meta/docs/pages/readme.nix`](../meta/docs/pages/readme.nix) | Root repository README.md declaration. |
| [`meta/docs/render.nix`](../meta/docs/render.nix) | Rendering engine: renders sections in order, and exposes `lib.docs.generateAll`. |

Modules currently contributing pages or cross-primitive sections:

- [`primitives/contract/docs.nix`](../primitives/contract/docs.nix)
- [`primitives/feature/docs.nix`](../primitives/feature/docs.nix)
- [`primitives/host/docs.nix`](../primitives/host/docs.nix)
- [`primitives/implementation/docs.nix`](../primitives/implementation/docs.nix)
- [`primitives/lib/docs.nix`](../primitives/lib/docs.nix)
- [`primitives/primitive/docs.nix`](../primitives/primitive/docs.nix)
- [`meta/tests/docs.nix`](../meta/tests/docs.nix)
- [`meta/graph/docs.nix`](../meta/graph/docs.nix)
- [`meta/docs/pages/readme.nix`](../meta/docs/pages/readme.nix)
- [`meta/docs/pages/packages.nix`](../meta/docs/pages/packages.nix)
- [`meta/docs/pages/modules.nix`](../meta/docs/pages/modules.nix)
- [`meta/docs/pages/guide.nix`](../meta/docs/pages/guide.nix)
- [`meta/docs/pages/devshells.nix`](../meta/docs/pages/devshells.nix)
- [`meta/docs/pages/coverage.nix`](../meta/docs/pages/coverage.nix)
- [`meta/docs/cli.nix`](../meta/docs/cli.nix)
- [`meta/ci/docs.nix`](../meta/ci/docs.nix)
- [`modules/features/tack.nix`](../modules/features/tack.nix)
- [`modules/features/disko.nix`](../modules/features/disko.nix)
- [`modules/contracts/persistence.nix`](../modules/contracts/persistence.nix)

## Writing Documentation

### Enrich the pages of a primitive

A module can add a section to every instance page of a primitive via `docs.sections.<kind>`. The body receives the page context (`ctx.name`, `ctx.instance`, `ctx.graph`, `ctx.md`, `ctx.instanceLink`, ...) and may return `null` to skip:

```nix
docs.sections.host.storage = {
  order = 45;
  content = ctx:
    let devices = ((ctx.config.flake.nixosConfigurations.${ctx.name} or {}).config or {}).disko.devices or {};
    in if devices == {} then null else ''
      ## Storage Layout

      ...
    '';
};
```

### Add a page

```nix
docs.pages.troubleshooting = {
  path = "docs/troubleshooting.md";
  sections = {
    header = {
      order = 10;
      content = ''
        # Troubleshooting

        Common failures and how to fix them.
      '';
    };
  };
};
```

## Command Reference

| Command | Description |
| :--- | :--- |
| `nix run .#docs -- --write` | Write the generated documentation (README.md, docs/**/*.md) to the working tree and delete stale pages. |
| `nix run .#docs -- --check` | Verify that the working tree matches evaluated documentation. Prints 1-line health summary if coverage < 100%. |
| `nix run .#docs -- --strict` | Enforce 100% documentation coverage. When combined with --check, exits 1 on any documentation warning. |
| `nix run .#docs -- --health` | Print documentation health metrics, coverage percentage, and itemized warning count. |
| `nix run .#docs -- --list` | List the files produced by the generator. |
| `nix run .#docs -- --help` | Show this help message. |

The `docs` flake check (part of `nix flake check`) verifies that committed documentation is bit-for-bit synchronized with Nix evaluation.

## Option Reference

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `docs.pages` | `attribute set of (submodule)` | `{ }` | Registry of generated documentation pages keyed by page id. Any flake-parts module may contribute pages or sections. |
| `docs.pages.<name>.path` | `string` | **required** | Output file path relative to repo root (e.g. 'docs/hosts/x240.md' or 'README.md'). |
| `docs.pages.<name>.sections` | `(attribute set of (submodule)) or list of (submodule)` | `{ }` | Sections composing the page body. |
| `docs.project.flakeRef` | `string` | `"github:LW-54/nixconf"` | Public flake reference of this repository used in copy-paste snippets (e.g. `github:owner/repo`). |
| `docs.project.name` | `string` | `"❄️ nixconf"` | Project name rendered as README title. |
| `docs.project.tagline` | `string` | `"Declarative multi-host infrastructure, contracts, and modular NixOS configuration repository powered by pure-Nix evaluation."` | One-line project summary rendered below the README title. |
| `docs.project.url` | `string` | `"https://github.com/LW-54/nixconf"` | Git clone URL of this repository. |
| `docs.sections` | `attribute set of attribute set of (submodule)` | `{ }` | Section templates added to every instance page of a primitive, keyed by primitive kind (or target page id). |
| `docs.sections.<name>.<name>.body` | `null or string or function that evaluates to a(n) (null or string)` | `null` | Markdown template string or function (ctx -> str \| null). Alias for content. |
| `docs.sections.<name>.<name>.content` | `null or string or function that evaluates to a(n) (null or string)` | `null` | Markdown template string or function (ctx -> str \| null). |
| `docs.sections.<name>.<name>.order` | `signed integer` | `100` | Visual sort order within the page. |
| `docs.strict` | `boolean` | `false` | Enforce 100% documentation coverage and fail checks on any documentation warning. |
