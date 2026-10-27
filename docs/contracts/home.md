# Contract: `home`

Declarative user home dotfile tree, XDG directory specifications, and session environment.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `home`
- **Description**: Declarative user home dotfile tree, XDG directory specifications, and session environment.
- **Definition File**: [`modules/contracts/home.nix`](../../modules/contracts/home.nix)

## Architecture Diagram

flowchart LR
  urn__nixconf__ast__module__foot["nixosModule/foot"]:::defaultNode
    urn__nixconf__ast__module__git["nixosModule/git"]:::defaultNode
    urn__nixconf__ast__module__hjem["nixosModule/hjem"]:::defaultNode
    urn__nixconf__ast__module__labwc["nixosModule/labwc"]:::defaultNode
    urn__nixconf__ast__module__locale["nixosModule/locale"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__option__home_enable[/"home.enable"/]:::optNode
    urn__nixconf__ast__option__home_shared[/"home.shared"/]:::optNode
    urn__nixconf__ast__option__home_users[/"home.users"/]:::optNode
    urn__nixconf__ast__type__home_file[["home.file"]]:::typeNode
    urn__nixconf__ast__type__home_files[["home.files"]]:::typeNode
    urn__nixconf__ast__type__home_relativeHomePath[["home.relativeHomePath"]]:::typeNode
    urn__nixconf__ast__type__home_userHome[["home.userHome"]]:::typeNode
    urn__nixconf__ast__type__home_xdg[["home.xdg"]]:::typeNode
    urn__nixconf__drv__devShell__github_ssh>"devShell/github-ssh"]:::devShellNode
    urn__nixconf__drv__package__foot[("package/foot")]:::pkgNode
    urn__nixconf__drv__package__git[("package/git")]:::pkgNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__foot -->|"dependsOn"| urn__nixconf__drv__package__foot
    urn__nixconf__ast__module__foot -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__foot -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__foot -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__foot -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__git -->|"dependsOn"| urn__nixconf__drv__package__git
    urn__nixconf__ast__module__git -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__git -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__git -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__git -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__git -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__git -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__hjem -. "reads" .-> urn__nixconf__ast__option__home_enable
    urn__nixconf__ast__module__hjem -. "reads" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__hjem -. "reads" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__hjem -. "writes = true" .-> urn__nixconf__ast__option__home_enable
    urn__nixconf__ast__module__labwc -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__labwc -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__labwc -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__labwc -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__locale -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__locale -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__locale -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__lw -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__lw -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__lw -. "writes = "<set>"" .-> urn__nixconf__ast__option__home_users
    urn__nixconf__ast__option__home_shared -->|"typedBy"| urn__nixconf__ast__type__home_userHome
    urn__nixconf__ast__option__home_shared -->|"typedBy"| urn__nixconf__ast__type__home_xdg
    urn__nixconf__ast__option__home_users -->|"typedBy"| urn__nixconf__ast__type__home_userHome
    urn__nixconf__ast__option__home_users -->|"typedBy"| urn__nixconf__ast__type__home_xdg
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__option__home_enable
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__option__home_shared
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__option__home_users
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__type__home_file
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__type__home_files
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__type__home_relativeHomePath
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__type__home_userHome
    urn__nixconf__onto__contract__home -->|"declares"| urn__nixconf__ast__type__home_xdg
    urn__nixconf__onto__feature__foot -->|"outputs"| urn__nixconf__ast__module__foot
    urn__nixconf__onto__feature__foot -->|"outputs"| urn__nixconf__drv__package__foot
    urn__nixconf__onto__feature__foot -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__ast__module__git
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__drv__devShell__github_ssh
    urn__nixconf__onto__feature__git -->|"outputs"| urn__nixconf__drv__package__git
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"outputs"| urn__nixconf__ast__module__labwc
    urn__nixconf__onto__feature__labwc -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -. "consumes" .-> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__locale -->|"outputs"| urn__nixconf__ast__module__locale
    urn__nixconf__onto__feature__locale -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__host__astrolabe -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -. "consumes" .-> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__implementation__hjem -->|"outputs"| urn__nixconf__ast__module__hjem
    urn__nixconf__onto__implementation__hjem -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem == "implements" ==> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem == "implements" ==> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__lw


    click urn__nixconf__ast__module__foot href "../modules/foot.md" "foot"
    click urn__nixconf__ast__module__git href "../modules/git.md" "git"
    click urn__nixconf__ast__module__hjem href "../modules/hjem.md" "hjem"
    click urn__nixconf__ast__module__labwc href "../modules/labwc.md" "labwc"
    click urn__nixconf__ast__module__locale href "../modules/locale.md" "locale"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__drv__devShell__github_ssh href "../DEVSHELLS.md#github-ssh" "github-ssh"
    click urn__nixconf__drv__package__foot href "../PACKAGES.md#foot" "foot"
    click urn__nixconf__drv__package__git href "../PACKAGES.md#git" "git"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__hjem href "../implementations/hjem.md" "hjem"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"

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


## Option Schema Definitions

| Option | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.home.enable` | `boolean` | `` | `1` | Whether to enable declarative user home dotfile and environment contract. |
| `options.home.shared` | `submodule` | `{ ... }` | `{ ... }` | Shared dotfile tree and environment configurations applied across all managed users. |
| `options.home.users` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem). |

## Outputs

### Custom Submodule Types

| Type | Description | Details |
| :--- | :--- | :--- |
| [`home.file`](../lib/home.md#home.file) | open submodule of attribute set of anything | [More →](../lib/home.md#home.file) |
| [`home.files`](../lib/home.md#home.files) | attribute set of (open submodule of attribute set of anything) | [More →](../lib/home.md#home.files) |
| [`home.relativeHomePath`](../lib/home.md#home.relativeHomePath) | Relative path within home directory (no leading '/' or '..') | [More →](../lib/home.md#home.relativeHomePath) |
| [`home.userHome`](../lib/home.md#home.userHome) | submodule | [More →](../lib/home.md#home.userHome) |
| [`home.xdg`](../lib/home.md#home.xdg) | submodule | [More →](../lib/home.md#home.xdg) |

### Library Helpers

| Symbol | Description | Details |
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

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Features

<details>
<summary><code><a href="../features/foot.md">foot</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/foot.md">foot</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/git.md">git</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/git.md">git</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/locale.md">locale</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

