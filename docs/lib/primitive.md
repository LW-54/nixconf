# Library Namespace: `flake.lib.primitive`

Primitives framework helper functions, option constructors, and utilities.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.primitive`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.primitive
  example = self.lib.primitive.unwrapLib;
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
    # Access exported helpers from inputs.nixconf.lib.primitive
    example = nixconf.lib.primitive.unwrapLib;
  };
}
```

## Exported Symbols

<a id="unwrapLib"></a>
### `unwrapLib`

Unwraps documented symbols from an attribute set, extracting `.value` if present or stripping `.docstring` metadata.



#### Inputs

- `attrs`: Attribute set containing documented symbol definitions.


#### Type

```
unwrapLib :: AttrSet -> AttrSet
```





<a id="check"></a>
### `check`

Generic validation check constructors, predicates, and style specification verifiers.





#### Type

```
check :: AttrSet

# Values
- `cleanMsg msg`: Normalizes multiline messages into single-line strings.
- `recordTodo diag`: Standard diagnostic constructor emitting evaluation warnings.
- `validOption args`: Validates individual NixOS option declarations.
- `validOptions inst`: Validates all options in a contract or submodule tree.
- `validFunction args`: Validates RFC 145 function docstrings and parameter drift.
- `validDocstring args`: Validates symbol docstring summaries and signatures.
- `validSymbols inst`: Validates all symbols in a library instance.
- `validMeta inst`: Validates metadata descriptions on packages and shells.
- `mkCheck predicate [message]`: Constructs a custom check from a predicate function.
- `hasAttr attr [message]`: Validates that an attribute exists on the instance.
- `hasAttrs attr [message]`: Validates that an attribute exists and is an attribute set.
- `hasNonEmptyAttrs attr [message]`: Validates that an attribute is a non-empty attribute set.
- `hasString attr [message]`: Validates that an attribute is a non-empty string.
- `hasFunction attr [message]`: Validates that an attribute is a function.
- `any checkList [message]`: Validates that at least one check passes.
- `all checkList [message]`: Validates that all checks pass.
```





<a id="option"></a>
### `option`

Pre-configured option constructors for primitive definitions with automatic descriptions and functor override support.





#### Type

```
option :: AttrSet
```





<a id="output"></a>
### `output`

Pre-configured output generator helpers for aggregating flake outputs.





#### Type

```
output :: AttrSet
```





<a id="parser"></a>
### `parser`

Pure-Nix RFC 145 docstring parser utilities for functions and library symbols.





#### Type

```
parser :: AttrSet

# Values
- `stripLeadingIndentation text`: Strips common indentation whitespace.
- `parseDocstring rawComment`: Parses structured RFC 145 docstring sections.
```




