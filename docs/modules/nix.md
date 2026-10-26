# Module: `nix`

Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.nix`
- **Description**: Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.x240-system-features
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.nix.allowedUsers` | `submodule` | Alias of {option}`nix.settings.allowed-users`. |
| `options.nix.autoOptimiseStore` | `submodule` | Alias of {option}`nix.settings.auto-optimise-store`. |
| `options.nix.binaryCachePublicKeys` | `submodule` | Alias of {option}`nix.settings.trusted-public-keys`. |
| `options.nix.binaryCaches` | `submodule` | Alias of {option}`nix.settings.substituters`. |
| `options.nix.buildCores` | `submodule` | Alias of {option}`nix.settings.cores`. |
| `options.nix.buildMachines` | `list of (submodule)` | This option lists the machines to be used if distributed builds are enabled (see {option}`nix.distributedBuilds`). Nix will perform derivations on those machines via SSH by copying the inputs to the Nix store on the remote machine, starting the build, then copying the output back to the local Nix store. |
| `options.nix.cachixWatchStore` | `boolean` | Whether to enable cachix-watch-store service and its SOPS secret. |
| `options.nix.channel.enable` | `boolean` | Whether the `nix-channel` command and state files are made available on the machine.  The following files are initialized when enabled:   - `/nix/var/nix/profiles/per-user/root/channels`   - `/root/.nix-channels`   - `$HOME/.nix-defexpr/channels` (on login)  Disabling this option will not remove the state files from the system. |
| `options.nix.checkAllErrors` | `boolean` | If enabled, checks the nix.conf parsing for any kind of error. When disabled, checks only for unknown settings. |
| `options.nix.checkConfig` | `boolean` | If enabled, checks that Nix can parse the generated nix.conf. |
| `options.nix.chrootDirs` | `submodule` | Alias of {option}`nix.sandboxPaths`. |
| `options.nix.daemon.enable` | `boolean` | Whether to enable the Nix Daemon. |
| `options.nix.daemonCPUSchedPolicy` | `one of "other", "batch", "idle"` | Nix daemon process CPU scheduling policy. This policy propagates to build processes. `other` is the default scheduling policy for regular tasks. The `batch` policy is similar to `other`, but optimised for non-interactive tasks. `idle` is for extremely low-priority tasks that should only be run when no other task requires CPU time.  Please note that while using the `idle` policy may greatly improve responsiveness of a system performing expensive builds, it may also slow down and potentially starve crucial configuration updates during load.  `idle` may therefore be a sensible policy for systems that experience only intermittent phases of high CPU load, such as desktop or portable computers used interactively. Other systems should use the `other` or `batch` policy instead.  For more fine-grained resource control, please refer to {manpage}`systemd.resource-control(5)` and adjust {option}`systemd.services.nix-daemon` directly. |
| `options.nix.daemonGroup` | `string` | Group to use to run the Nix daemon. |
| `options.nix.daemonIONiceLevel` | `signed integer` | Alias of {option}`nix.daemonIOSchedPriority`. |
| `options.nix.daemonIOSchedClass` | `one of "best-effort", "idle"` | Nix daemon process I/O scheduling class. This class propagates to build processes. `best-effort` is the default class for regular tasks. The `idle` class is for extremely low-priority tasks that should only perform I/O when no other task does.  Please note that while using the `idle` scheduling class can improve responsiveness of a system performing expensive builds, it might also slow down or starve crucial configuration updates during load.  `idle` may therefore be a sensible class for systems that experience only intermittent phases of high I/O load, such as desktop or portable computers used interactively. Other systems should use the `best-effort` class. |
| `options.nix.daemonIOSchedPriority` | `signed integer` | Nix daemon process I/O scheduling priority. This priority propagates to build processes. The supported priorities depend on the scheduling policy: With idle, priorities are not used in scheduling decisions. best-effort supports values in the range 0 (high) to 7 (low). |
| `options.nix.daemonNiceLevel` | `unspecified value` |  |
| `options.nix.daemonUser` | `string` | User to use to run the Nix daemon. If this is not "root" then the Nix daemon will set several settings to preserve functionality. When setting this option, you must also set `nix.daemonGroup`. |
| `options.nix.distributedBuilds` | `boolean` | Whether to distribute builds to the machines listed in {option}`nix.buildMachines`. |
| `options.nix.enable` | `boolean` | Whether to enable Nix. Disabling Nix makes the system hard to modify and the Nix programs and configuration will not be made available by NixOS itself. |
| `options.nix.envVars` | `attribute set` | Environment variables used by Nix. |
| `options.nix.extraOptions` | `strings concatenated with "\n"` | Additional text appended to {file}`nix.conf`. |
| `options.nix.firewall.allowLoopback` | `unspecified value` | Whether to allow traffic on the loopback interface. Traffic is still subject to protocol/port rules |
| `options.nix.firewall.allowNonTCPUDP` | `boolean` | Whether to allow traffic that is neither TCP nor UDP |
| `options.nix.firewall.allowPrivateNetworks` | `unspecified value` | Whether to allow traffic to local networks. Traffic is still subject to protocol/port rules. Note that this option may break DNS resolution when the DNS resolver is in a local network |
| `options.nix.firewall.allowedTCPPorts` | `list of ((optionally newline-terminated) single-line string or 16 bit unsigned integer; between 0 and 65535 (both inclusive))` | TCP ports to which traffic is allowed. Specifying no ports will allow all TCP traffic |
| `options.nix.firewall.allowedUDPPorts` | `list of ((optionally newline-terminated) single-line string or 16 bit unsigned integer; between 0 and 65535 (both inclusive))` | UDP ports to which traffic is allowed. Specifying no ports will allow all UDP traffic |
| `options.nix.firewall.enable` | `boolean` | Whether to enable firewalling for outgoing traffic of the nix daemon. |
| `options.nix.firewall.extraNftablesRules` | `list of (optionally newline-terminated) single-line string` | Extra nftables rules to prepend to the generated ones |
| `options.nix.gc.automatic` | `boolean` | Automatically run the garbage collector at a specific time. |
| `options.nix.gc.dates` | `(optionally newline-terminated) single-line string or list of string` | How often or when garbage collection is performed. For most desktop and server systems a sufficient garbage collection is once a week.  This value must be a calendar event in the format specified by {manpage}`systemd.time(7)`. |
| `options.nix.gc.options` | `(optionally newline-terminated) single-line string` | Options given to [`nix-collect-garbage`](https://nixos.org/manual/nix/stable/command-ref/nix-collect-garbage) when the garbage collector is run automatically. |
| `options.nix.gc.persistent` | `boolean` | Takes a boolean argument. If true, the time when the service unit was last triggered is stored on disk. When the timer is activated, the service unit is triggered immediately if it would have been triggered at least once during the time when the timer was inactive. Such triggering is nonetheless subject to the delay imposed by RandomizedDelaySec=. This is useful to catch up on missed runs of the service when the system was powered down. |
| `options.nix.gc.randomizedDelaySec` | `(optionally newline-terminated) single-line string` | Add a randomized delay before each garbage collection. The delay will be chosen between zero and this value. This value must be a time span in the format specified by {manpage}`systemd.time(7)` |
| `options.nix.maxJobs` | `submodule` | Alias of {option}`nix.settings.max-jobs`. |
| `options.nix.nixPath` | `list of string` | The default Nix expression search path, used by the Nix evaluator to look up paths enclosed in angle brackets (e.g. `<nixpkgs>`). |
| `options.nix.nrBuildUsers` | `signed integer` | Number of `nixbld` user accounts created to perform secure concurrent builds.  If you receive an error message saying that “all build users are currently in use”, you should increase this value. |
| `options.nix.optimise.automatic` | `boolean` | Automatically run the nix store optimiser at a specific time. |
| `options.nix.optimise.dates` | `(optionally newline-terminated) single-line string or list of string` | Specification (in the format described by {manpage}`systemd.time(7)`) of the time at which the optimiser will run. |
| `options.nix.optimise.persistent` | `boolean` | Takes a boolean argument. If true, the time when the service unit was last triggered is stored on disk. When the timer is activated, the service unit is triggered immediately if it would have been triggered at least once during the time when the timer was inactive. Such triggering is nonetheless subject to the delay imposed by RandomizedDelaySec=. This is useful to catch up on missed runs of the service when the system was powered down. |
| `options.nix.optimise.randomizedDelaySec` | `(optionally newline-terminated) single-line string` | Add a randomized delay before the optimizer will run. The delay will be chosen between zero and this value. This value must be a time span in the format specified by {manpage}`systemd.time(7)` |
| `options.nix.package` | `package` | This option specifies the Nix package instance to use throughout the system. |
| `options.nix.readOnlyStore` | `unspecified value` | Alias of {option}`boot.readOnlyNixStore`. |
| `options.nix.registry` | `attribute set of (submodule)` | A system-wide flake registry.  See {manpage}`nix3-registry(1)` for more information. |
| `options.nix.requireSignedBinaryCaches` | `submodule` | Alias of {option}`nix.settings.require-sigs`. |
| `options.nix.sandboxPaths` | `submodule` | Alias of {option}`nix.settings.extra-sandbox-paths`. |
| `options.nix.settings` | `open submodule of attribute set of (Nix config atom (null, bool, int, float, str, path or package) or list of (Nix config atom (null, bool, int, float, str, path or package)))` | Configuration for Nix, see <https://nixos.org/manual/nix/stable/command-ref/conf-file.html> or {manpage}`nix.conf(5)` for available options. The value declared here will be translated directly to the key-value pairs Nix expects.  You can use {command}`nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.nix.settings` to view the current value. By default it is empty.  Nix configurations defined under {option}`nix.*` will be translated and applied to this option. In addition, configuration specified in {option}`nix.extraOptions` will be appended verbatim to the resulting config file. |
| `options.nix.sshServe.enable` | `boolean` | Whether to enable serving the Nix store as a remote store via SSH. |
| `options.nix.sshServe.keys` | `list of string` | A list of SSH public keys allowed to access the binary cache via SSH. |
| `options.nix.sshServe.protocol` | `one of "ssh", "ssh-ng"` | The specific Nix-over-SSH protocol to use. |
| `options.nix.sshServe.trusted` | `boolean` | Whether to add nix-ssh to the nix.settings.trusted-users |
| `options.nix.sshServe.write` | `boolean` | Whether to enable writing to the Nix store as a remote store via SSH. Note: by default, the sshServe user is named nix-ssh and is not a trusted-user. nix-ssh should be added to the {option}`nix.sshServe.trusted` option in most use cases, such as allowing remote building of derivations to anonymous people based on ssh key |
| `options.nix.systemFeatures` | `submodule` | Alias of {option}`nix.settings.system-features`. |
| `options.nix.trustedBinaryCaches` | `submodule` | Alias of {option}`nix.settings.trusted-substituters`. |
| `options.nix.trustedUsers` | `submodule` | Alias of {option}`nix.settings.trusted-users`. |
| `options.nix.useChroot` | `submodule` | Alias of {option}`nix.useSandbox`. |
| `options.nix.useSandbox` | `submodule` | Alias of {option}`nix.settings.sandbox`. |

