# Contract: `home`

Declarative user home dotfile tree, XDG directory specifications, and session environment.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `home`
- **Description**: Declarative user home dotfile tree, XDG directory specifications, and session environment.
- **Definition File**: [`modules/contracts/home.nix`](../../modules/contracts/home.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        host__astrolabe["astrolabe"]:::hostNode
        host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__default_user(["default-user"]):::contractNode
        contract__home(["home"]):::contractNode
        contract__persistence(["persistence"]):::contractNode
        contract__secrets(["secrets"]):::contractNode
        contract__wayland(["wayland"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__hjem["hjem"]:::implNode
        impl__lw["lw"]:::implNode
    end

    subgraph Features["Features"]
        feature__foot["foot"]:::featureNode
        feature__git["git"]:::featureNode
        feature__helium["helium"]:::featureNode
        feature__labwc["labwc"]:::featureNode
        feature__locale["locale"]:::featureNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__home_enable[/"home.enable: boolean"/]:::optNode
        opt__home_shared[/"home.shared: submodule"/]:::optNode
        opt__home_users[/"home.users: attribute set of (submodule)"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__home_file{{"home.file"}}:::typeNode
        type__home_files{{"home.files"}}:::typeNode
        type__home_relativeHomePath{{"home.relativeHomePath"}}:::typeNode
        type__home_userHome{{"home.userHome"}}:::typeNode
        type__home_xdg{{"home.xdg"}}:::typeNode
    end


    host__astrolabe -->|"imports"| impl__lw
    host__astrolabe -->|"imports"| feature__git
    host__astrolabe -->|"imports"| feature__locale
    host__x240 -->|"imports"| impl__hjem
    host__x240 -->|"imports"| impl__lw
    host__x240 -->|"imports"| feature__foot
    host__x240 -->|"imports"| feature__git
    host__x240 -->|"imports"| feature__labwc
    host__x240 -->|"imports"| feature__locale
    impl__hjem -.->|"implements"| contract__home
    impl__lw -.->|"implements"| contract__default_user
    host__x240 -->|"consumes (wayland.enable)"| contract__wayland
    feature__foot -->|"consumes (home.shared, home.users)"| contract__home
    feature__foot -->|"consumes (persistence.users)"| contract__persistence
    feature__git -->|"consumes"| contract__default_user
    feature__git -->|"consumes (home.users, home.shared)"| contract__home
    feature__helium -->|"consumes (home.shared, home.users)"| contract__home
    feature__helium -->|"consumes (persistence.users)"| contract__persistence
    feature__labwc -->|"consumes (home.shared.xdg.config, home.users, home.shared)"| contract__home
    feature__labwc -->|"consumes (persistence.users)"| contract__persistence
    feature__labwc -->|"consumes (wayland.compositors.labwc, wayland.compositors)"| contract__wayland
    feature__locale -->|"consumes (home.shared.sessionVariables, home.shared)"| contract__home
    impl__hjem -->|"consumes (home.enable)"| contract__home
    impl__lw -->|"consumes (home.users)"| contract__home
    impl__lw -->|"consumes (persistence.users)"| contract__persistence
    impl__lw -->|"consumes (secrets.files.default-user-password-hash, secrets.files)"| contract__secrets
    contract__home --- opt__home_enable
    contract__home --- opt__home_shared
    contract__home --- opt__home_users
    contract__home --- type__home_file
    contract__home --- type__home_files
    contract__home --- type__home_relativeHomePath
    contract__home --- type__home_userHome
    contract__home --- type__home_xdg

classDef hostNode fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
classDef contractNode fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
classDef implNode fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
classDef featureNode fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
classDef libNode fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;
classDef optNode fill:#11111b,stroke:#fab387,stroke-width:1px,color:#cdd6f4;
classDef typeNode fill:#11111b,stroke:#f9e2af,stroke-width:1px,color:#cdd6f4;
classDef fnNode fill:#181825,stroke:#94e2d5,stroke-width:1px,color:#cdd6f4;
classDef pkgNode fill:#181825,stroke:#b4befe,stroke-width:1px,color:#cdd6f4;
classDef shellNode fill:#181825,stroke:#f5c2e7,stroke-width:1px,color:#cdd6f4;

```


## Option Schema Definitions

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.home.enable` | `boolean` | `1` | `1` | Whether to enable declarative user home dotfile and environment contract. |
| `options.home.shared` | `submodule` | `{ ... }` | `{ ... }` | Shared dotfile tree and environment configurations applied across all managed users. |
| `options.home.users` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem). |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`home.file`](../lib/home.md#home.file) | open submodule of attribute set of anything | [More →](../lib/home.md#home.file) |
| [`home.files`](../lib/home.md#home.files) | attribute set of (open submodule of attribute set of anything) | [More →](../lib/home.md#home.files) |
| [`home.relativeHomePath`](../lib/home.md#home.relativeHomePath) | Relative path within home directory (no leading '/' or '..') | [More →](../lib/home.md#home.relativeHomePath) |
| [`home.userHome`](../lib/home.md#home.userHome) | submodule | [More →](../lib/home.md#home.userHome) |
| [`home.xdg`](../lib/home.md#home.xdg) | submodule | [More →](../lib/home.md#home.xdg) |


### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.home.mkOption`](../lib/home.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/home.md#mkOption) |
| [`flake.lib.home.mkConfig`](../lib/home.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/home.md#mkConfig) |
| [`flake.lib.home.types`](../lib/home.md#types) | Contract option constructor / binding helper | [More →](../lib/home.md#types) |


## Implementations

Providers satisfying the `home` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`hjem`](../implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [More →](../implementations/hjem.md) |

## Contract Consumers

Modules configuring options under the `home` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

<details>
<summary><code><a href="../implementations/hjem.md">hjem</a></code></summary>

Configures options: `home.enable`

```nix
enable = home.enable;

packages = homeCfg.shared.packages ++ home.packages;

files = mapFiles (homeCfg.shared.files // home.files);

cache.files = mapFiles (homeCfg.shared.xdg.cache // home.xdg.cache);

config.files = mapFiles (homeCfg.shared.xdg.config // home.xdg.config);

data.files = mapFiles (homeCfg.shared.xdg.data // home.xdg.data);

state.files = mapFiles (homeCfg.shared.xdg.state // home.xdg.state);

environment.sessionVariables = homeCfg.shared.sessionVariables // home.sessionVariables;

systemd.services = homeCfg.shared.systemd.services // home.systemd.services;
```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: `home.users`

```nix
home.users.${cfg.username} = {};
```

</details>


### Features

<details>
<summary><code><a href="../features/foot.md">foot</a></code></summary>

Configures options: `home.shared`, `home.users`

```nix
home.shared = {
  xdg.config."foot/foot.ini" = {
    generator = lib.generators.toINI {};
    value = cfg.settings;
  };

  files = lib.mkIf cfg.server.enable {
    ".config/systemd/user/foot-server.service".source = servicePath;
    ".config/systemd/user/foot-server.socket".source = socketPath;
    ".config/systemd/user/graphical-session.target.wants/foot-server.socket".source = socketPath;
  };
};

home.users = lib.mapAttrs (userName: uCfg:
  lib.mkIf (uCfg.enable != false) {
    xdg.config."foot/foot.ini" = {
      generator = lib.generators.toINI {};
      value = lib.recursiveUpdate cfg.settings uCfg.settings;
    };
  })
```

</details>


<details>
<summary><code><a href="../features/git.md">git</a></code></summary>

Configures options: `home.users`, `home.shared`

```nix
home.shared.xdg.config."git/config" = {
  generator = lib.generators.toINI {};
  value = cfg.settings;
};

home.users = lib.mapAttrs (userName: uCfg:
  lib.mkIf (uCfg.enable != false) {
    xdg.config."git/config" = {
      generator = lib.generators.toINI {};
      value = lib.recursiveUpdate cfg.settings uCfg.settings;
    };
  })
```

</details>


<details>
<summary><code><a href="../features/helium.md">helium</a></code></summary>

Configures options: `home.shared`, `home.users`

```nix
home.shared = lib.mkIf (cfg.flags != []) {
  files = {
    ".config/helium-browser-flags.conf".text = lib.concatStringsSep "\n" cfg.flags;
  };
};

home.users = lib.mapAttrs (userName: uCfg:
  lib.mkIf (uCfg.flags != null) {
    files.".config/helium-browser-flags.conf".text = lib.concatStringsSep "\n" uCfg.flags;
  })
```

</details>


<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

Configures options: `home.shared.xdg.config`, `home.users`, `home.shared`

```nix
home.shared.xdg.config =
  (lib.optionalAttrs (cfg.rc != null) {
    "labwc/rc.xml".text = cfg.rc;
  })

home.users =
  lib.mapAttrs (userName: uCfg: {
    xdg.config =
      (lib.optionalAttrs (uCfg.rc != null) {
        "labwc/rc.xml".text = uCfg.rc;
      })
      // (lib.optionalAttrs (uCfg.environment != null) {
        "labwc/environment".text = uCfg.environment;
      });
  })
```

</details>


<details>
<summary><code><a href="../features/locale.md">locale</a></code></summary>

Configures options: `home.shared.sessionVariables`, `home.shared`

```nix
home.shared.sessionVariables =
  {
    LANG = cfg.defaultLocale;
  }
```

</details>

