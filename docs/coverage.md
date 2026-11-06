# Documentation Coverage & Quality Audit

Automated quality and completeness audit tracking documentation health across primitives, library symbols, and schema options.

[← Back to Documentation Guide](documentation.md) | [← Back to Main README](../README.md)

## Health Overview

> [!WARNING]
> **Documentation Health**: **90.6%** (146/161 items documented, **15 warnings**).
> Missing or incomplete docstrings are cataloged in the registry below.


| Metric | Value | Description |
| :--- | :--- | :--- |
| **Overall Health Score** | `90.6%` | Percentage of audited entities satisfying documentation completeness criteria. |
| **Total Audited Items** | `161` | Combined count of primitives, exported library functions/symbols, and schema options. |
| **Fully Documented** | `146` | Entities with valid, non-placeholder descriptions and type signatures. |
| **Audit Warnings** | `15` | Entities requiring docstrings, option descriptions, or type signatures. |

## Category Breakdown

| Subsystem | Documented | Total | Health | Warnings |
| :--- | :--- | :--- | :--- | :--- |
| **Primitives (Hosts, Features, Contracts, Libs)** | 58 | 64 | `90.6%` | ⚠️ `6` |
| **Library Symbols & Functions** | 53 | 62 | `85.4%` | ⚠️ `9` |
| **Primitive Schema Options** | 35 | 35 | `100.0%` | ✅ None |

## Missing Documentation Registry

The following entities have missing or incomplete documentation:

| Category | Entity Target | Source File | Missing Field | Remediation |
| :--- | :--- | :--- | :--- | :--- |
| `primitives` | `primitive.contract` | [`primitives/contract/default.nix`](../primitives/contract/default.nix) | **description** | Add 'description = "...";' to primitive.contract |
| `primitives` | `primitive.feature` | [`primitives/feature.nix`](../primitives/feature.nix) | **description** | Add 'description = "...";' to primitive.feature |
| `primitives` | `primitive.host` | [`primitives/host/default.nix`](../primitives/host/default.nix) | **description** | Add 'description = "...";' to primitive.host |
| `primitives` | `primitive.implementation` | [`primitives/implementation/default.nix`](../primitives/implementation/default.nix) | **description** | Add 'description = "...";' to primitive.implementation |
| `primitives` | `primitive.lib` | [`primitives/lib.nix`](../primitives/lib.nix) | **description** | Add 'description = "...";' to primitive.lib |
| `primitives` | `primitive.primitive` | [`primitives/primitive/default.nix`](../primitives/primitive/default.nix) | **description** | Add 'description = "...";' to primitive.primitive |
| `symbols` | `lib.home.types` | [`modules/contracts/home.nix`](../modules/contracts/home.nix) | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.home.types |
| `symbols` | `lib.options._type` | *unknown* | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.options._type |
| `symbols` | `lib.options.default` | *unknown* | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.options.default |
| `symbols` | `lib.options.description` | *unknown* | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.options.description |
| `symbols` | `lib.options.type` | *unknown* | **type signature (# Type)** | Add '# Type' section to docstring of lib.options.type |
| `symbols` | `lib.persistence.types` | [`modules/contracts/persistence.nix`](../modules/contracts/persistence.nix) | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.persistence.types |
| `symbols` | `lib.reverse-proxy.types` | [`modules/contracts/reverse-proxy.nix`](../modules/contracts/reverse-proxy.nix) | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.reverse-proxy.types |
| `symbols` | `lib.secrets.types` | [`modules/contracts/secrets.nix`](../modules/contracts/secrets.nix) | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.secrets.types |
| `symbols` | `lib.wayland.types` | [`modules/contracts/wayland.nix`](../modules/contracts/wayland.nix) | **docstring** | Add docstring with '# Inputs' and '# Type' to lib.wayland.types |

## Remediation Guide

To resolve documentation warnings and achieve 100% health:

### 1. Documenting Primitives & Features
Add a clear `description` string explaining what the component provides:
```nix
feature.myFeature = {
  description = "Brief summary of what this system feature configures.";
  ...
};
```

### 2. Documenting Library Functions & Symbols
Provide a markdown `# Docstring` including `# Inputs`, `# Type`, and `# Examples`:
```nix
lib.myLib = {
  symbols.myFunction = {
    docstring = \'\'
      Calculates something useful.

      # Inputs
      `x`: Description of parameter x.

      # Type
      ```
      myFunction :: Int -> String
      ```
    \'\';
    value = x: toString x;
  };
};
```

### 3. Documenting Schema Options
Ensure every `lib.mkOption` declaration has an explanatory `description`:
```nix
myOption = lib.mkOption {
  type = lib.types.str;
  description = "Human-readable description of this configuration knob.";
};
```
