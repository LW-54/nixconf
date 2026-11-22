# Module: `agy`

NixOS module exported by feature 'antigravity'.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.agy`
- **Provided by**: feature [`antigravity`](../features/antigravity.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `agy.config.enable` | `boolean` | `true` | `true` | Whether to enable declarative Antigravity CLI settings, rules, and MCP configuration. |
| `agy.config.mcpServers` | `attribute set of anything` | `{ }` | — | Declarative MCP server definitions serialized to `~/.gemini/config/mcp_config.json` when non-empty. |
| `agy.config.rules` | `attribute set of strings concatenated with "\n"` | `{ }` | — | Declarative named Markdown sections rendered into global `GEMINI.md` rules. |
| `agy.config.settings` | `attribute set of anything` | `{ }` | — | Declarative `~/.gemini/antigravity-cli/settings.json` attributes merged over defaults. |
| `agy.config.users` | `attribute set of (submodule)` | `{ }` | — | Per-user Antigravity configuration overrides. |
| `agy.enable` | `boolean` | `true` | `true` | Whether to enable Antigravity CLI (agy). |
| `agy.package` | `package` | `<derivation google-antigravity-cli-1.5.0-5269980577660928>` | — | Antigravity CLI package to install. |
