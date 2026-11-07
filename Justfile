# Justfile: Task runner for nixconf

# Default action: launch the interactive fuzzy command menu
default:
    @menu

# Open repository in Antigravity IDE (falls back to nix run if not in PATH)
ide path=".":
    @if command -v antigravity-ide >/dev/null 2>&1; then \
        antigravity-ide {{path}}; \
    else \
        echo "antigravity-ide not in PATH; launching via nix run .#antigravity-ide..."; \
        nix run .#antigravity-ide -- {{path}}; \
    fi

# Rebuild and switch NixOS configuration for local machine
switch host="x240":
    sudo nixos-rebuild switch --flake .#{{host}}

# Test NixOS configuration without creating a boot entry
test host="x240":
    sudo nixos-rebuild test --flake .#{{host}}

# Run fast evaluation checks on hosts
test-eval host="":
    nix run .#test -- eval {{host}}

# Validate generated /etc, PAM, and units without KVM
test-inspect host="":
    nix run .#test -- inspect {{host}}

# Boot host in QEMU and execute runtime checks (requires KVM)
test-vm host="":
    nix run .#test -- vm {{host}}

# Partition real Disko layout, install, and test reboot persistence (requires KVM)
test-install host="":
    nix run .#test -- install {{host}}

# Boot host as an interactive test VM with port forward (localhost:2222)
test-run host="x240":
    nix run .#test -- run {{host}}

# Open the VM test driver Python REPL
test-interactive host="x240":
    nix run .#test -- interactive {{host}}

# List available hosts, tiers, and their test checks
test-list:
    nix run .#test -- list

# Install NixOS configuration to bootloader without switching running system
boot host="x240":
    sudo nixos-rebuild boot --flake .#{{host}}

# Build NixOS configuration into ./result using nix-output-monitor
build host="x240":
    nom-build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Update repository documentation (README.md and docs/**)
docs-write:
    nix run .#docs -- --write

# Verify documentation synchronization and exit 1 if stale
docs-check:
    nix run .#docs -- --check

# Check documentation health and coverage metrics
docs-health:
    nix run .#docs -- --health

# View architecture LPG and CPG graph statistics
graph-stats:
    nix run .#graph -- --stats

# Enter an exported devshell (runs fzf picker if shell is not provided)
devshell shell="":
    @if [ -z "{{shell}}" ]; then \
        selected=$(nix eval --json .#devShells.x86_64-linux --apply builtins.attrNames | jq -r '.[]' | fzf --prompt="Select devshell > " --height=40% --reverse); \
        [ -n "$selected" ] && nix develop ".#$selected"; \
    else \
        nix develop ".#{{shell}}"; \
    fi

# Run an exported package (runs fzf picker if pkg is not provided)
run-pkg pkg="":
    @if [ -z "{{pkg}}" ]; then \
        selected=$(nix eval --json .#packages.x86_64-linux --apply builtins.attrNames | jq -r '.[]' | fzf --prompt="Select package > " --height=40% --reverse); \
        [ -n "$selected" ] && nix run ".#$selected"; \
    else \
        nix run ".#{{pkg}}"; \
    fi

# Edit encrypted user secrets with SOPS
secrets-user:
    sops secrets/users/default.yaml

# Enter SOPS administrative shell with Bitwarden master key
sops-admin:
    nix develop .#sops-admin

# Enter SOPS host inspection shell with host age key
sops-host:
    nix develop .#sops-host

# Enter GitHub deploy key devshell
github-ssh:
    nix develop .#github-ssh

# Enter master cluster SSH devshell
master-ssh:
    nix develop .#master-ssh

# Inspect upstream pin drift in Tack without writing lock
tack-look:
    tack look

# Update all Tack pins and regenerate pins.lock.json
tack-update:
    tack update

# Format all Nix files with Alejandra
fmt:
    nix fmt .

# Run dead code and anti-pattern checks
lint:
    statix check
    deadnix

# Run all flake validation checks
check:
    nix flake check
