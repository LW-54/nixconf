# Library: `testing`

Library helpers and constructors for the 'testing' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.testing`
- **Definition File**: [`modules/contracts/testing.nix`](../../modules/contracts/testing.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__testing_failedEvalChecks["testing.failedEvalChecks"]:::defaultNode
    urn__nixconf__ast__function__testing_mkTestScript["testing.mkTestScript"]:::defaultNode
    urn__nixconf__ast__function__testing_mkTtyLogin["testing.mkTtyLogin"]:::defaultNode
    urn__nixconf__ast__function__testing_selectChecks["testing.selectChecks"]:::defaultNode
    urn__nixconf__onto__lib__testing["testing"]:::defaultNode

    urn__nixconf__onto__lib__testing -->|outputs| urn__nixconf__ast__function__testing_failedEvalChecks
    urn__nixconf__onto__lib__testing -->|outputs| urn__nixconf__ast__function__testing_mkTestScript
    urn__nixconf__onto__lib__testing -->|outputs| urn__nixconf__ast__function__testing_mkTtyLogin
    urn__nixconf__onto__lib__testing -->|outputs| urn__nixconf__ast__function__testing_selectChecks


    click urn__nixconf__ast__function__testing_failedEvalChecks href "testing.md" "testing.failedEvalChecks"
    click urn__nixconf__ast__function__testing_mkTestScript href "testing.md" "testing.mkTestScript"
    click urn__nixconf__ast__function__testing_mkTtyLogin href "testing.md" "testing.mkTtyLogin"
    click urn__nixconf__ast__function__testing_selectChecks href "testing.md" "testing.selectChecks"
    click urn__nixconf__onto__lib__testing href "testing.md" "testing"

  %% Semantic Visual Classes
  classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
  classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
  classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
  classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
  classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
  classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
  classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
  classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
  classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
  classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
```

</details>

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

```nix
{ self, lib, pkgs, ... }: {
  example = self.lib.testing.failedEvalChecks;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.testing.failedEvalChecks;
  };
}
```

## Exported Symbols

<a id="failedEvalChecks"></a>
### `failedEvalChecks`

Returns the enabled evaluation checks whose assertion does not hold.

#### Inputs

- `evalChecks`: Attribute set of `testing.evalChecks` entries.

#### Type

```
failedEvalChecks :: AttrSet -> [{ name, message }]
```

#### Examples

```nix
failedEvalChecks config.testing.evalChecks
```

<a id="mkTestScript"></a>
### `mkTestScript`

Renders selected runtime checks into a NixOS test driver script, one subtest per check.

#### Inputs

- `checks`: Attribute set of `testing.checks` entries.
- `tier`: Tier name (`"vm"` or `"install"`).
- `label`: Optional prefix (usually the host name) for subtest titles.

#### Type

```
mkTestScript :: { checks, tier, label ? String } -> String
```

#### Examples

```nix
mkTestScript { checks = config.testing.checks; tier = "install"; label = "x240"; }
```

<a id="mkTtyLogin"></a>
### `mkTtyLogin`

Builds a test driver snippet that logs in on a virtual console with a password and verifies the session.

#### Inputs

- `user`: Account name to log in as.
- `password`: Plain-text password typed at the prompt.
- `tty`: Virtual console number (default: 2, leaving tty1 to greeters).

#### Type

```
mkTtyLogin :: { user, password, tty ? Int } -> String
```

#### Examples

```nix
mkTtyLogin { user = "alice"; password = config.testing.credentials.password; }
```

<a id="selectChecks"></a>
### `selectChecks`

Selects the enabled runtime checks for a tier, sorted by priority and name.

#### Inputs

- `checks`: Attribute set of `testing.checks` entries.
- `tier`: Tier name (`"vm"` or `"install"`).

#### Type

```
selectChecks :: { checks, tier } -> [AttrSet]
```

#### Examples

```nix
selectChecks { checks = config.testing.checks; tier = "vm"; }
```
