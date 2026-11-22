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

# Rebuild and switch NixOS configuration for local or specified host
switch host=`hostname`:
    sudo nixos-rebuild switch --flake .#{{host}}

# Test NixOS configuration without creating a boot entry
test host=`hostname`:
    sudo nixos-rebuild test --flake .#{{host}}

# Install NixOS configuration to bootloader without switching running system
boot host=`hostname`:
    sudo nixos-rebuild boot --flake .#{{host}}

# Build NixOS configuration into ./result using nix-output-monitor
build host=`hostname`:
    nom-build .#nixosConfigurations.{{host}}.config.system.build.toplevel

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
test-run host=`hostname`:
    nix run .#test -- run {{host}}

# Open the VM test driver Python REPL
test-interactive host=`hostname`:
    nix run .#test -- interactive {{host}}

# List available hosts, tiers, and their test checks
test-list:
    nix run .#test -- list

# Update repository documentation (README.md and docs/**)
docs-write:
    nix run .#docs -- --write

# Verify documentation synchronization and exit 1 if stale
docs-check:
    nix run .#docs -- --check

# Check documentation health and coverage metrics
docs-health:
    nix run .#docs -- --health

# Synchronize compiled GitHub Actions workflows to .github/workflows/
ci-write:
    nix run .#ci -- --write

# Verify GitHub Actions workflow synchronization
ci-check:
    nix run .#ci -- --check

# View architecture LPG and CPG graph statistics
graph-stats:
    nix run .#graph -- --stats

# Enter an exported devshell (opens interactive menu picker if shell is omitted)
devshell shell="":
    @if [ -z "{{shell}}" ]; then \
        menu --category devshell; \
    else \
        nix develop ".#{{shell}}"; \
    fi

# Run an exported package (opens interactive menu picker if pkg is omitted)
run-pkg pkg="":
    @if [ -z "{{pkg}}" ]; then \
        menu --category package; \
    else \
        nix run ".#{{pkg}}"; \
    fi

# Edit a SOPS secret file (opens interactive menu picker if file is omitted)
secrets file="":
    @if [ -z "{{file}}" ]; then \
        menu --category secrets; \
    else \
        sops "{{file}}"; \
    fi

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
