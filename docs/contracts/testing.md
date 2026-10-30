# Contract: `testing`

Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `testing`
- **Description**: Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets.
- **Definition File**: [`modules/contracts/testing.nix`](../../modules/contracts/testing.nix)

## Architecture Diagram

```mermaid
flowchart LR
  urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__greetd["nixosModule/greetd"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__nixos_test["nixosModule/nixos-test"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__option__testing_checks[/"testing.checks"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_hashedPassword[/"testing.credentials.hashedPassword"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_password[/"testing.credentials.password"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshHostPrivateKey[/"testing.credentials.sshHostPrivateKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshHostPublicKey[/"testing.credentials.sshHostPublicKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshPrivateKey[/"testing.credentials.sshPrivateKey"/]:::optNode
    urn__nixconf__ast__option__testing_credentials_sshPublicKey[/"testing.credentials.sshPublicKey"/]:::optNode
    urn__nixconf__ast__option__testing_enable[/"testing.enable"/]:::optNode
    urn__nixconf__ast__option__testing_evalChecks[/"testing.evalChecks"/]:::optNode
    urn__nixconf__ast__option__testing_install_enable[/"testing.install.enable"/]:::optNode
    urn__nixconf__ast__option__testing_name[/"testing.name"/]:::optNode
    urn__nixconf__ast__option__testing_vm_allowedFailedUnits[/"testing.vm.allowedFailedUnits"/]:::optNode
    urn__nixconf__ast__option__testing_vm_cores[/"testing.vm.cores"/]:::optNode
    urn__nixconf__ast__option__testing_vm_enable[/"testing.vm.enable"/]:::optNode
    urn__nixconf__ast__option__testing_vm_memorySize[/"testing.vm.memorySize"/]:::optNode
    urn__nixconf__ast__option__testing_vm_sshForwardPort[/"testing.vm.sshForwardPort"/]:::optNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin["devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__sops_host["devShell/sops-host"]:::devShellNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__testing{{"testing"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__greetd("greetd"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__nixos_test["nixos-test"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__greetd -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__impermanence -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__testing_evalChecks
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__testing_checks
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_checks
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_hashedPassword
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_password
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshHostPrivateKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshHostPublicKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshPrivateKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_credentials_sshPublicKey
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_evalChecks
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_install_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_name
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_allowedFailedUnits
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_cores
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_enable
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_memorySize
    urn__nixconf__onto__contract__testing -->|declares| urn__nixconf__ast__option__testing_vm_sshForwardPort
    urn__nixconf__onto__feature__greetd -->|outputs| urn__nixconf__ast__module__greetd
    urn__nixconf__onto__feature__greetd -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__nixos_test -->|outputs| urn__nixconf__ast__module__nixos_test
    urn__nixconf__onto__implementation__nixos_test ==>|implements| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_admin
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_host
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__nixos_test
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__sops


    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__greetd href "../modules/greetd.md" "greetd"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__nixos_test href "../modules/nixos-test.md" "nixos-test"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__drv__devShell__master_ssh href "../DEVSHELLS.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../DEVSHELLS.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__sops_host href "../DEVSHELLS.md#sops-host" "sops-host"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__testing href "../contracts/testing.md" "testing"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__greetd href "../features/greetd.md" "greetd"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__nixos_test href "../implementations/nixos-test.md" "nixos-test"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"

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


## Option Schema Definitions

| Option | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.testing.checks` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Named runtime checks contributed by modules, executed by the NixOS test driver against the booted host. Every host importing a module automatically inherits its checks. |
| `options.testing.credentials.hashedPassword` | `string` | `$y$j9T$wLgKY231.8j.ciV2MfEXe1$P0k5j3bCwHgnwW0Ive3w4knrgpiA4TzhCYLAnHvDZ51` | *none* | Crypt(3) hash of `testing.credentials.password`, used as the stand-in for password hash secrets. |
| `options.testing.credentials.password` | `string` | `test` | *none* | Plain-text password that test stand-in password hashes resolve to. |
| `options.testing.credentials.sshHostPrivateKey` | `string` | `-----BEGIN OPENSSH PRIVATE KEY----- b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW QyNTUxOQAAACAz0F5hFTFS5nhUcmnyjFVoDw5L/P7kQU8JnBA2rWczAwAAAIhWlP99VpT/ fQAAAAtzc2gtZWQyNTUxOQAAACAz0F5hFTFS5nhUcmnyjFVoDw5L/P7kQU8JnBA2rWczAw AAAEDE1rlcMC0s0X3TKVZAOVavZOywwkXw8tO5dLObxaCMEDPQXmEVMVLmeFRyafKMVWgP Dkv8/uRBTwmcEDatZzMDAAAAAAECAwQF -----END OPENSSH PRIVATE KEY----- ` | *none* | Private half of the stand-in SSH host key, used as the stand-in for host key secrets. |
| `options.testing.credentials.sshHostPublicKey` | `string` | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPQXmEVMVLmeFRyafKMVWgPDkv8/uRBTwmcEDatZzMD snakeoil` | *none* | Public half of the stand-in SSH host key, used to verify host key provisioning. |
| `options.testing.credentials.sshPrivateKey` | `string` | `-----BEGIN EC PRIVATE KEY----- MHcCAQEEIObLW92AqkWunJXowVR2Z5/+yVPBaFHnEedDk5WJxk/BoAoGCCqGSM49 AwEHoUQDQgAEQiVI+I+3gv+17KN0RFLHKh5Vj71vc75eSOkyMsxFxbFsTNEMTLjV uKFxOelIgsiZJXKZNCX0FBmrfpCkKklCcg== -----END EC PRIVATE KEY----- ` | *none* | Private half of the test client key, used by remote checks to log in over SSH. |
| `options.testing.credentials.sshPublicKey` | `string` | `ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEIlSPiPt4L/teyjdERSxyoeVY+9b3O+XkjpMjLMRcWxbEzRDEy41bihcTnpSILImSVymTQl9BQZq36QpCpJQnI= snakeoil` | *none* | Public half of the test client key, used as the stand-in for authorized key secrets. |
| `options.testing.enable` | `boolean` | `` | `1` | Whether to enable test mode; only set inside generated test variants so modules can swap real secrets and hardware for stand-ins. |
| `options.testing.evalChecks` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Named evaluation-time checks over the host configuration. They run in seconds without building anything (`nix flake check --no-build`), and all failures are reported together. |
| `options.testing.install.enable` | `boolean` | `` | *none* | Whether the `install` tier (partition the real disk layout, install, boot through the real boot loader) is available for this host. Enabled automatically for Disko-managed hosts. |
| `options.testing.name` | `null or string` | *null* | `x240` | Flake attribute name of the host under test, injected by the test harness. |
| `options.testing.vm.allowedFailedUnits` | `list of string` | `[ ... ]` | `[ ... ]` | Shell-style unit patterns that may legitimately fail inside the isolated test network. |
| `options.testing.vm.cores` | `positive integer, meaning >0` | `2` | *none* | Number of virtual CPU cores given to the host under test. |
| `options.testing.vm.enable` | `boolean` | `1` | *none* | Whether the host can be booted in a virtualised `vm` tier test. |
| `options.testing.vm.memorySize` | `positive integer, meaning >0` | `2048` | *none* | Memory in MiB given to the virtual machine running the host under test. |
| `options.testing.vm.sshForwardPort` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | `2222` | *none* | Host port forwarded to the guest SSH daemon when running the interactive VM. |

## Outputs

### Custom Submodule Types

*No custom types declared.*

### Library Helpers

| Symbol | Description | Details |
| :--- | :--- | :--- |
| [`flake.lib.testing.failedEvalChecks`](../lib/testing.md#failedEvalChecks) | Contract option constructor / binding helper | [More →](../lib/testing.md#failedEvalChecks) |
| [`flake.lib.testing.mkTestScript`](../lib/testing.md#mkTestScript) | Contract option constructor / binding helper | [More →](../lib/testing.md#mkTestScript) |
| [`flake.lib.testing.mkTtyLogin`](../lib/testing.md#mkTtyLogin) | Contract option constructor / binding helper | [More →](../lib/testing.md#mkTtyLogin) |
| [`flake.lib.testing.selectChecks`](../lib/testing.md#selectChecks) | Contract option constructor / binding helper | [More →](../lib/testing.md#selectChecks) |

## Implementations

Providers satisfying the `testing` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`nixos-test`](../implementations/nixos-test.md) | Host verification through the NixOS test driver: built-in essentials, QEMU VM sizing, and Disko install tests. | [More →](../implementations/nixos-test.md) |

## Contract Consumers

Modules configuring options under the `testing` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../implementations/impermanence.md">impermanence</a></code></summary>

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


<details>
<summary><code><a href="../implementations/sops.md">sops</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Features

<details>
<summary><code><a href="../features/greetd.md">greetd</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/nix.md">nix</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

