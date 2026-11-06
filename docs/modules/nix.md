# Module: `nix`

Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.nix`
- **Provided by**: feature [`nix`](../features/nix.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `nix.allowedUsers` | `submodule` | — | — | Alias of {option}`nix.settings.allowed-users`. |
| `nix.autoOptimiseStore` | `submodule` | — | — | Alias of {option}`nix.settings.auto-optimise-store`. |
| `nix.binaryCachePublicKeys` | `submodule` | — | — | Alias of {option}`nix.settings.trusted-public-keys`. |
| `nix.binaryCaches` | `submodule` | — | — | Alias of {option}`nix.settings.substituters`. |
| `nix.buildCores` | `submodule` | — | — | Alias of {option}`nix.settings.cores`. |
| `nix.buildMachines` | `list of (submodule)` | `[ ]` | — | This option lists the machines to be used if distributed builds are enabled (see {option}`nix.distributedBuilds`). Nix will perform derivations on those machines via SSH by copying the inputs to the Nix store on the remote machine, starting the build, then copying the output back to the local Nix store. |
| `nix.cachixWatchStore` | `boolean` | `true` | — | Whether to enable cachix-watch-store service and its SOPS secret. |
| `nix.channel.enable` | `boolean` | `true` | — | Whether the `nix-channel` command and state files are made available on the machine. The following files are initialized when enabled: - `/nix/var/nix/profiles/per-user/root/channels` - `/root/.nix-channels` - `$HOME/.nix-defexpr/channels` (on login) Disabling this option will not remove the state files from the system. |
| `nix.checkAllErrors` | `boolean` | `true` | — | If enabled, checks the nix.conf parsing for any kind of error. When disabled, checks only for unknown settings. |
| `nix.checkConfig` | `boolean` | `true` | — | If enabled, checks that Nix can parse the generated nix.conf. |
| `nix.chrootDirs` | `submodule` | — | — | Alias of {option}`nix.sandboxPaths`. |
| `nix.daemon.enable` | `boolean` | `config.nix.enable` | — | Whether to enable the Nix Daemon. |
| `nix.daemonCPUSchedPolicy` | `one of "other", "batch", "idle"` | `"other"` | `"batch"` | Nix daemon process CPU scheduling policy. This policy propagates to build processes. `other` is the default scheduling policy for regular tasks. The `batch` policy is similar to `other`, but optimised for non-interactive tasks. `idle` is for extremely low-priority tasks that should only be run when no other task requires CPU time. Please note that while using the `idle` policy may greatly improve responsiveness of a system performing expensive builds, it may also slow down and potentially starve crucial configuration updates during load. `idle` may therefore be a sensible policy for systems that experience only intermittent phases of high CPU load, such as desktop or portable computers used interactively. Other systems should use the `other` or `batch` policy instead. For more fine-grained resource control, please refer to {manpage}`systemd.resource-control(5)` and adjust {option}`systemd.services.nix-daemon` directly. |
| `nix.daemonGroup` | `string` | `"root"` | — | Group to use to run the Nix daemon. |
| `nix.daemonIONiceLevel` | `signed integer` | — | — | Alias of {option}`nix.daemonIOSchedPriority`. |
| `nix.daemonIOSchedClass` | `one of "best-effort", "idle"` | `"best-effort"` | `"idle"` | Nix daemon process I/O scheduling class. This class propagates to build processes. `best-effort` is the default class for regular tasks. The `idle` class is for extremely low-priority tasks that should only perform I/O when no other task does. Please note that while using the `idle` scheduling class can improve responsiveness of a system performing expensive builds, it might also slow down or starve crucial configuration updates during load. `idle` may therefore be a sensible class for systems that experience only intermittent phases of high I/O load, such as desktop or portable computers used interactively. Other systems should use the `best-effort` class. |
| `nix.daemonIOSchedPriority` | `signed integer` | `4` | `1` | Nix daemon process I/O scheduling priority. This priority propagates to build processes. The supported priorities depend on the scheduling policy: With idle, priorities are not used in scheduling decisions. best-effort supports values in the range 0 (high) to 7 (low). |
| `nix.daemonNiceLevel` | `unspecified value` | — | — |  |
| `nix.daemonUser` | `string` | `"root"` | — | User to use to run the Nix daemon. If this is not "root" then the Nix daemon will set several settings to preserve functionality. When setting this option, you must also set `nix.daemonGroup`. |
| `nix.distributedBuilds` | `boolean` | `false` | — | Whether to distribute builds to the machines listed in {option}`nix.buildMachines`. |
| `nix.enable` | `boolean` | `true` | — | Whether to enable Nix. Disabling Nix makes the system hard to modify and the Nix programs and configuration will not be made available by NixOS itself. |
| `nix.envVars` | `attribute set` | `{ }` | — | Environment variables used by Nix. |
| `nix.extraOptions` | `strings concatenated with "\n"` | `""` | `"keep-outputs = true keep-derivations = true"` | Additional text appended to {file}`nix.conf`. |
| `nix.firewall.allowLoopback` | `unspecified value` | `false` | `true` | Whether to allow traffic on the loopback interface. Traffic is still subject to protocol/port rules |
| `nix.firewall.allowNonTCPUDP` | `boolean` | `false` | `true` | Whether to allow traffic that is neither TCP nor UDP |
| `nix.firewall.allowPrivateNetworks` | `unspecified value` | `true` | `false` | Whether to allow traffic to local networks. Traffic is still subject to protocol/port rules. Note that this option may break DNS resolution when the DNS resolver is in a local network |
| `nix.firewall.allowedTCPPorts` | `list of ((optionally newline-terminated) single-line string or 16 bit unsigned integer; between 0 and 65535 (both inclusive))` | `[ ]` | `[ ... ]` | TCP ports to which traffic is allowed. Specifying no ports will allow all TCP traffic |
| `nix.firewall.allowedUDPPorts` | `list of ((optionally newline-terminated) single-line string or 16 bit unsigned integer; between 0 and 65535 (both inclusive))` | `[ ]` | `[ ... ]` | UDP ports to which traffic is allowed. Specifying no ports will allow all UDP traffic |
| `nix.firewall.enable` | `boolean` | `false` | `true` | Whether to enable firewalling for outgoing traffic of the nix daemon. |
| `nix.firewall.extraNftablesRules` | `list of (optionally newline-terminated) single-line string` | `[ ]` | `[ ... ]` | Extra nftables rules to prepend to the generated ones |
| `nix.gc.automatic` | `boolean` | `false` | — | Automatically run the garbage collector at a specific time. |
| `nix.gc.dates` | `(optionally newline-terminated) single-line string or list of string` | `[ ... ]` | `"weekly"` | How often or when garbage collection is performed. For most desktop and server systems a sufficient garbage collection is once a week. This value must be a calendar event in the format specified by {manpage}`systemd.time(7)`. |
| `nix.gc.options` | `(optionally newline-terminated) single-line string` | `""` | `"--max-freed $((64 * 1024**3))"` | Options given to [`nix-collect-garbage`](https://nixos.org/manual/nix/stable/command-ref/nix-collect-garbage) when the garbage collector is run automatically. |
| `nix.gc.persistent` | `boolean` | `true` | `false` | Takes a boolean argument. If true, the time when the service unit was last triggered is stored on disk. When the timer is activated, the service unit is triggered immediately if it would have been triggered at least once during the time when the timer was inactive. Such triggering is nonetheless subject to the delay imposed by RandomizedDelaySec=. This is useful to catch up on missed runs of the service when the system was powered down. |
| `nix.gc.randomizedDelaySec` | `(optionally newline-terminated) single-line string` | `"0"` | `"45min"` | Add a randomized delay before each garbage collection. The delay will be chosen between zero and this value. This value must be a time span in the format specified by {manpage}`systemd.time(7)` |
| `nix.maxJobs` | `submodule` | — | — | Alias of {option}`nix.settings.max-jobs`. |
| `nix.nixPath` | `list of string` | `"if nix.channel.enable then [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ] else [];"` | — | The default Nix expression search path, used by the Nix evaluator to look up paths enclosed in angle brackets (e.g. `<nixpkgs>`). |
| `nix.nrBuildUsers` | `signed integer` | — | — | Number of `nixbld` user accounts created to perform secure concurrent builds. If you receive an error message saying that “all build users are currently in use”, you should increase this value. |
| `nix.optimise.automatic` | `boolean` | `false` | — | Automatically run the nix store optimiser at a specific time. |
| `nix.optimise.dates` | `(optionally newline-terminated) single-line string or list of string` | `[ ... ]` | — | Specification (in the format described by {manpage}`systemd.time(7)`) of the time at which the optimiser will run. |
| `nix.optimise.persistent` | `boolean` | `true` | `false` | Takes a boolean argument. If true, the time when the service unit was last triggered is stored on disk. When the timer is activated, the service unit is triggered immediately if it would have been triggered at least once during the time when the timer was inactive. Such triggering is nonetheless subject to the delay imposed by RandomizedDelaySec=. This is useful to catch up on missed runs of the service when the system was powered down. |
| `nix.optimise.randomizedDelaySec` | `(optionally newline-terminated) single-line string` | `"1800"` | `"45min"` | Add a randomized delay before the optimizer will run. The delay will be chosen between zero and this value. This value must be a time span in the format specified by {manpage}`systemd.time(7)` |
| `nix.package` | `package` | `pkgs.nix` | `[ ... ]` | This option specifies the Nix package to use throughout the system. It can be used to set a specific version or alternative implementation. |
| `nix.readOnlyStore` | `unspecified value` | — | — | Alias of {option}`boot.readOnlyNixStore`. |
| `nix.registry` | `attribute set of (submodule)` | `{ }` | — | A system-wide flake registry. See {manpage}`nix3-registry(1)` for more information. |
| `nix.requireSignedBinaryCaches` | `submodule` | — | — | Alias of {option}`nix.settings.require-sigs`. |
| `nix.sandboxPaths` | `submodule` | — | — | Alias of {option}`nix.settings.extra-sandbox-paths`. |
| `nix.settings` | `open submodule of attribute set of (Nix config atom (null, bool, int, float, str, path or package) or list of (Nix config atom (null, bool, int, float, str, path or package)))` | `{ }` | `{ use-sandbox = true; show-trace = true; sandbox-paths = [ "/bin/sh=${pkgs.busybox-sandbox-shell.out}/bin/busybox" ]; }` | Configuration for Nix, see <https://nixos.org/manual/nix/stable/command-ref/conf-file.html> or {manpage}`nix.conf(5)` for available options. The value declared here will be translated directly to the key-value pairs Nix expects. You can use {command}`nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.nix.settings` to view the current value. By default it is empty. Nix configurations defined under {option}`nix.*` will be translated and applied to this option. In addition, configuration specified in {option}`nix.extraOptions` will be appended verbatim to the resulting config file. |
| `nix.sshServe.enable` | `boolean` | `false` | — | Whether to enable serving the Nix store as a remote store via SSH. |
| `nix.sshServe.keys` | `list of string` | `[ ]` | `[ ... ]` | A list of SSH public keys allowed to access the binary cache via SSH. |
| `nix.sshServe.protocol` | `one of "ssh", "ssh-ng"` | `"ssh"` | — | The specific Nix-over-SSH protocol to use. |
| `nix.sshServe.trusted` | `boolean` | `false` | — | Whether to add nix-ssh to the nix.settings.trusted-users |
| `nix.sshServe.write` | `boolean` | `false` | — | Whether to enable writing to the Nix store as a remote store via SSH. Note: by default, the sshServe user is named nix-ssh and is not a trusted-user. nix-ssh should be added to the {option}`nix.sshServe.trusted` option in most use cases, such as allowing remote building of derivations to anonymous people based on ssh key |
| `nix.systemFeatures` | `submodule` | — | — | Alias of {option}`nix.settings.system-features`. |
| `nix.trustedBinaryCaches` | `submodule` | — | — | Alias of {option}`nix.settings.trusted-substituters`. |
| `nix.trustedUsers` | `submodule` | — | — | Alias of {option}`nix.settings.trusted-users`. |
| `nix.useChroot` | `submodule` | — | — | Alias of {option}`nix.useSandbox`. |
| `nix.useSandbox` | `submodule` | — | — | Alias of {option}`nix.settings.sandbox`. |
