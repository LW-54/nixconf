# Library Namespace: `flake.lib.docsParser`

Pure-Nix RFC 145 docstring parser utilities for functions and library symbols.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.docsParser`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.docsParser
  example = self.lib.docsParser.parseDocstring;
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
    # Access exported helpers from inputs.nixconf.lib.docsParser
    example = nixconf.lib.docsParser.parseDocstring;
  };
}
```

## Exported Symbols

<a id="parseDocstring"></a>
### `parseDocstring`

Parses an RFC 145 docstring into structured sections (summary, body, inputs, type, examples).



#### Inputs

- `rawComment`: Raw multiline comment text or null.


#### Type

```
parseDocstring :: NullOr String -> NullOr AttrSet
```


#### Examples

```nix
parseDocstring "Summary sentence."
```



<a id="stripLeadingIndentation"></a>
### `stripLeadingIndentation`

Determines common leading whitespace indentation to strip from docstring lines.



#### Inputs

- `text`: Raw text containing indentation.


#### Type

```
stripLeadingIndentation :: String -> String
```


#### Examples

```nix
stripLeadingIndentation "  hello\n  world"
```


