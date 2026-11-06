# Feature: `user`

Normal user account helper functions and querying utilities.

[← Back to Features Documentation](README.md) | [← Back to Main README](../../README.md)

- **Feature**: `user`
- **Definition File**: [`modules/features/user.nix`](../../modules/features/user.nix)

## Outputs

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`forNormalUsers`](../lib/user.md#forNormalUsers) | `forNormalUsers :: Config -> (String -> AttrSet -> AttrSet) -> AttrSet` | Maps an attribute set generation function across all normal users. | [More →](../lib/user.md#forNormalUsers) |
| [`normalUserNames`](../lib/user.md#normalUserNames) | `normalUserNames :: Config -> [String]` | Returns list of usernames for all normal users on the system. | [More →](../lib/user.md#normalUserNames) |
| [`normalUsers`](../lib/user.md#normalUsers) | `normalUsers :: Config -> AttrSet` | Filters `config.users.users` down to normal human user accounts (`isNormalUser = true`). | [More →](../lib/user.md#normalUsers) |
