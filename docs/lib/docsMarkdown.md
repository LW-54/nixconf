# Library Namespace: `flake.lib.docsMarkdown`

Markdown documentation rendering engine for Nixconf architecture.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.docsMarkdown`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.docsMarkdown
  example = self.lib.docsMarkdown.generateAll;
}
```

### External Usage

When consuming this flake as an input in another `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixconf.url = "github:LW-54/nixconf";
  };

  outputs = { self, nixpkgs, nixconf, ... }: {
    # Access exported helpers from inputs.nixconf.lib.docsMarkdown
    example = nixconf.lib.docsMarkdown.generateAll;
  };
}
```

## Exported Symbols

<a id="generateAll"></a>
### `generateAll`

Generates all markdown documentation files for hosts, contracts, implementations, features, modules, and lib symbols.



#### Inputs

- `cpg`: Evaluated Semantic Code Property Graph (optional).
- `graph`: Evaluated documentation graph (optional).
- `system`: Target host platform system (default: "x86_64-linux").


#### Type

```
generateAll :: AttrSet -> AttrSet
```





<a id="renderReadme"></a>
### `renderReadme`

Renders the repository root README.md documentation file.



#### Inputs

- `graph`: Evaluated documentation graph.


#### Type

```
renderReadme :: AttrSet -> String
```




