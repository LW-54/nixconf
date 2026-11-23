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

# Fast targeted check for a single host (pure eval assertions, ~6s, zero builds)
check-host host=`hostname`:
    nix build --no-link ".#checks.x86_64-linux.eval-{{host}}"

# Fast repo-wide static check: formatting + schemas + all host eval assertions (~12s)
check-fast:
    alejandra --check .
    nix build --no-link .#checks.x86_64-linux.schemas .#checks.x86_64-linux.eval-astrolabe .#checks.x86_64-linux.eval-x240

# Run fast evaluation checks on one or all hosts (direct nix build avoids double flake eval)
test-eval host="":
    @if [ -n "{{host}}" ]; then \
        nix build --no-link ".#checks.x86_64-linux.eval-{{host}}"; \
    else \
        nix build --no-link .#checks.x86_64-linux.eval-astrolabe .#checks.x86_64-linux.eval-x240; \
    fi

# Validate generated /etc and system-path without KVM (optional: only=<namespace>)
test-inspect host="" only="":
    @if [ -n "{{only}}" ] && [ -n "{{host}}" ]; then \
        nix build --no-link -L ".#legacyPackages.x86_64-linux.hostTests.{{host}}.inspectByNamespace.{{only}}"; \
    elif [ -n "{{host}}" ]; then \
        nix build --no-link -L ".#checks.x86_64-linux.inspect-{{host}}"; \
    else \
        nix build --no-link -L .#checks.x86_64-linux.inspect-astrolabe .#checks.x86_64-linux.inspect-x240; \
    fi

# Boot host in QEMU and execute runtime checks (requires KVM; optional: only=<namespace>)
test-vm host="" only="":
    @if [ -n "{{only}}" ] && [ -n "{{host}}" ]; then \
        nix build --no-link -L ".#legacyPackages.x86_64-linux.hostTests.{{host}}.vmByNamespace.{{only}}"; \
    elif [ -n "{{host}}" ]; then \
        nix build --no-link -L ".#legacyPackages.x86_64-linux.hostTests.{{host}}.vm"; \
    else \
        nix run .#test -- vm; \
    fi

# Partition real Disko layout, install, and test reboot persistence (requires KVM)
test-install host="":
    @if [ -n "{{host}}" ]; then \
        nix build --no-link -L ".#legacyPackages.x86_64-linux.hostTests.{{host}}.install"; \
    else \
        nix run .#test -- install; \
    fi

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

# Format all Nix files with Alejandra (direct binary avoids Nix flake eval overhead)
fmt:
    alejandra .

# Run dead code and anti-pattern checks
lint:
    statix check
    deadnix

# Profile any command with SVG flamegraph, Speedscope Gantt timeline, and Nix stats
prof *cmd:
    nixprof trace -- {{cmd}}

# Analyze derivation cache invalidation on working-tree edits
prof-cache *files:
    @args=""; for f in {{files}}; do args="$args --mutate $f"; done; \
    nixprof cache-diff --working-tree --flake-all $args

# Inspect live GitHub Actions workflow/job/step timings
prof-ci:
    nixprof ci

# Bootstrap self-hosted Attic cache + upload GitHub Actions SOPS_AGE_KEY + encrypt CI token (run on astrolabe after deploy)
attic-bootstrap:
    nix develop .#github-cli --command nix run .#attic-bootstrap

# Run all flake validation checks (full eval + inspect + docs + ci + schemas)
check:
    nix flake check
