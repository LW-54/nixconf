# Library Namespace: `flake.lib.graph`

Canonical Semantic Code Property Graph (CPG) framework, algebraic calculus, and architectural projection functors.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.graph`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.graph
  example = self.lib.graph.backwardSlice;
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
    # Access exported helpers from inputs.nixconf.lib.graph
    example = nixconf.lib.graph.backwardSlice;
  };
}
```

## Exported Symbols

<a id="backwardSlice"></a>
### `backwardSlice`

Computes a backward program slice along incoming edges up to maxDepth.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `nodeId`: Canonical identifier of the target node.
- `maxDepth`: Maximum traversal depth (defaults to 10).
- `layers`: List of CPG strata to traverse (optional, defaults to all).
- `relations`: Optional list of specific relations to filter traversal (defaults to null for all).


#### Type

```
backwardSlice :: AttrSet -> AttrSet
```





<a id="buildCPG"></a>
### `buildCPG`

Extracts and constructs the unified Semantic Code Property Graph (CPG) merging Ontological, AST, Evaluation/PDG, and Derivation strata.



#### Inputs

- `system`: Architecture target system string (defaults to "x86_64-linux").


#### Type

```
buildCPG :: AttrSet -> AttrSet
```





<a id="buildGraph"></a>
### `buildGraph`

Builds the complete macro architectural graph directly from evaluated flake declarations.



#### Inputs

- `system`: Architecture target system string (defaults to "x86_64-linux").


#### Type

```
buildGraph :: AttrSet -> AttrSet
```





<a id="filterGraph"></a>
### `filterGraph`

Filters a labeled property graph by applying node and edge predicate functions.



#### Inputs

- `nodeFilter`: Predicate function filtering nodes by attributes (defaults to keeping all nodes).
- `edgeFilter`: Predicate function filtering edges by attributes (defaults to keeping all edges).
- `graph`: The input labeled property graph attribute set.


#### Type

```
filterGraph :: AttrSet -> AttrSet -> AttrSet
```





<a id="findConsumers"></a>
### `findConsumers`

Finds all consumer instances defining options or sending data into a target contract.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `contractId`: Canonical identifier of the contract (e.g. "persistence" or "contract:persistence").


#### Type

```
findConsumers :: AttrSet -> AttrSet
```





<a id="findImplementers"></a>
### `findImplementers`

Finds all active implementers fulfilling a target contract.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `contractId`: Canonical identifier of the contract (e.g. "persistence" or "contract:persistence").


#### Type

```
findImplementers :: AttrSet -> AttrSet
```





<a id="findOptionFlows"></a>
### `findOptionFlows`

Extracts the dataflow channels and writer/reader nodes for a specific option path.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `optionPath`: Option path string (e.g. "secrets.files").


#### Type

```
findOptionFlows :: AttrSet -> AttrSet
```





<a id="forwardSlice"></a>
### `forwardSlice`

Computes a forward program slice along outgoing edges up to maxDepth.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `nodeId`: Canonical identifier of the starting node.
- `maxDepth`: Maximum traversal depth (defaults to 10).
- `layers`: List of CPG strata to traverse (optional, defaults to all).
- `relations`: Optional list of specific relations to filter traversal (defaults to null for all).


#### Type

```
forwardSlice :: AttrSet -> AttrSet
```





<a id="getNeighborhood"></a>
### `getNeighborhood`

Extracts an undirected k-hop neighborhood surrounding a center node up to the specified traversal depth.



#### Inputs

- `depth`: Graph traversal depth radius (defaults to 1).
- `graph`: The complete labeled property graph attribute set.
- `nodeId`: Canonical identifier of the center node.


#### Type

```
getNeighborhood :: AttrSet -> AttrSet
```





<a id="getOptionValue"></a>
### `getOptionValue`

Retrieves the scalar resolved value for a contract option on a specific host from the CPG.



#### Inputs

- `cpg`: Semantic Code Property Graph attribute set.
- `host`: Host identifier string.
- `optionPath`: Option path string (e.g. "default-user.username").


#### Type

```
getOptionValue :: AttrSet -> Any
```





<a id="toArchitectureLPG"></a>
### `toArchitectureLPG`

Projects the fine-grained Semantic CPG into the macro architectural graph (LPG).



#### Inputs

- `cpg`: The evaluated Semantic Code Property Graph attribute set.


#### Type

```
toArchitectureLPG :: AttrSet -> AttrSet
```




