# Library Namespace: `flake.lib.docsMermaid`

Declarative Mermaid flowchart diagram visualizer with custom styling.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.docsMermaid`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.docsMermaid
  example = self.lib.docsMermaid.renderMermaid;
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
    # Access exported helpers from inputs.nixconf.lib.docsMermaid
    example = nixconf.lib.docsMermaid.renderMermaid;
  };
}
```

## Exported Symbols

<a id="renderMermaid"></a>
### `renderMermaid`

Renders a typed graph data structure into formatted Mermaid flowchart syntax.



#### Inputs

- `args`: Graph attribute set or options containing graph, direction, raw, and subgraphs.


#### Type

```
renderMermaid :: AttrSet -> String
```


#### Examples

```nix
renderMermaid {
  graph = {
    nodes = {};
    edges = [];
  };
  direction = "TD";
}
```



<a id="sanitizeId"></a>
### `sanitizeId`

Sanitizes an arbitrary node identifier into a valid Mermaid identifier.



#### Inputs

- `id`: Raw identifier string containing punctuation or spaces.


#### Type

```
sanitizeId :: String -> String
```


#### Examples

```nix
sanitizeId "contract:reverse-proxy"
```



<a id="renderConceptualDiagram"></a>
### `renderConceptualDiagram`

Conceptual 5-node architecture diagram template rendered in Mermaid syntax.





#### Type

```
renderConceptualDiagram :: String
```




