#!/usr/bin/env bash
# scripts/menu.sh: Interactive fuzzy command palette for nixconf
set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Ensure fzf is available
if ! command -v fzf >/dev/null 2>&1; then
  echo "Error: fzf is required for menu.sh. Please enter the devenv shell first." >&2
  exit 1
fi

# Preview generator called by fzf preview
if [ "${1:-}" = "--preview" ]; then
  shift
  CATEGORY="$1"
  TITLE="$2"
  COMMAND="$3"
  DESCRIPTION="$4"
  NOTES="$5"

  echo -e "\033[1;36m=== ${TITLE} ===\033[0m"
  echo -e "\033[1;33mCategory:\033[0m    ${CATEGORY}"
  echo ""
  echo -e "\033[1;32mCommand:\033[0m"
  echo -e "  \033[1;37m${COMMAND}\033[0m"
  echo ""
  echo -e "\033[1;34mDescription:\033[0m"
  echo -e "  ${DESCRIPTION}"
  if [ -n "${NOTES}" ]; then
    echo ""
    echo -e "\033[1;35mNotes / Caveats:\033[0m"
    echo -e "  ${NOTES}"
  fi
  echo ""
  echo -e "\033[0;90m──────────────────────────────────────────────────────────\033[0m"
  echo -e "\033[0;90m[Enter] Run  ·  [Tab / Ctrl-Y] Copy to Clipboard  ·  [Ctrl-C] Exit\033[0m"
  exit 0
fi

# Define catalog entry helper: Category \t Title \t Command \t Description \t Notes
entry() {
  printf "%b\t%b\t%b\t%b\t%b\n" "$1" "$2" "$3" "$4" "$5"
}

generate_catalog() {
  # --- [SYSTEM] ---
  entry "[ide]" "open Antigravity IDE (antigravity-ide .)" "if command -v antigravity-ide >/dev/null 2>&1; then antigravity-ide .; else nix run .#antigravity-ide -- .; fi" "Open workspace in Antigravity IDE (uses installed binary or falls back to nix run)." ""
  entry "[system]" "switch (x240 laptop)" "sudo nixos-rebuild switch --flake .#x240" "Rebuild and activate configuration on local x240 laptop." "Requires sudo password."
  entry "[system]" "test (x240 laptop)" "sudo nixos-rebuild test --flake .#x240" "Build and activate configuration without adding a GRUB/systemd-boot entry." "Requires sudo password."
  entry "[system]" "boot (x240 laptop)" "sudo nixos-rebuild boot --flake .#x240" "Build and install configuration to bootloader without switching running system." "Requires sudo password."
  entry "[system]" "build (x240 laptop)" "nom-build .#nixosConfigurations.x240.config.system.build.toplevel" "Build system toplevel closure using nix-output-monitor into ./result." ""
  entry "[system]" "build (astrolabe VPS)" "nom-build .#nixosConfigurations.astrolabe.config.system.build.toplevel" "Build remote VPS toplevel closure into ./result." ""

  # --- [DOCS] ---
  entry "[docs]" "write documentation" "nix run .#docs -- --write" "Regenerate all markdown pages (README.md, docs/**/*.md) and delete stale pages." "Updates repo files."
  entry "[docs]" "check documentation" "nix run .#docs -- --check" "Verify that working tree matches evaluated documentation generator." "Exits 1 if stale."
  entry "[docs]" "docs health & coverage" "nix run .#docs -- --health" "Print documentation coverage metrics, warning counts, and missing docstrings." ""
  entry "[docs]" "list generated docs" "nix run .#docs -- --list" "List all documentation files produced by the generator." ""

  # --- [GRAPH] ---
  entry "[graph]" "graph stats" "nix run .#graph -- --stats" "Print LPG and CPG graph node, edge, and relation counts." ""
  entry "[graph]" "export graph json" "nix run .#graph -- --json" "Print the complete architecture LPG graph as JSON to stdout." ""
  entry "[graph]" "export cpg json" "nix run .#graph -- --cpg-json" "Print the multi-strata Code Property Graph (CPG) as JSON to stdout." ""
  entry "[graph]" "inspect subgraph" "nix run .#graph -- --help" "Inspect Mermaid neighborhood for a node URN." "Pass URN to --subgraph."

  # --- [SECRETS] ---
  entry "[secrets]" "edit user secrets" "sops secrets/users/default.yaml" "Edit user passwords and hashed credentials with SOPS." "Requires host age key or master key."
  entry "[secrets]" "edit wifi eduroam" "sops secrets/wifi/wifi_eduroam.yaml" "Edit 802.1x enterprise WiFi credentials." ""
  entry "[secrets]" "edit cachix credentials" "sops secrets/cachix/cachix.yaml" "Edit Cachix auth tokens and signing keys." ""
  entry "[secrets]" "edit restic backup secrets" "sops secrets/backup/restic.yaml" "Edit Restic S3 and encryption repository secrets." ""
  entry "[secrets]" "edit couchdb secrets" "sops secrets/services/couchdb.yaml" "Edit CouchDB administrative passwords." ""
  entry "[secrets]" "edit copyparty secrets" "sops secrets/services/copyparty.yaml" "Edit Copyparty service credentials." ""
  entry "[secrets]" "edit zurg secrets" "sops secrets/services/zurg.yaml" "Edit Zurg debrid proxy tokens." ""
  entry "[secrets]" "edit reading-stack secrets" "sops secrets/services/reading-stack.yaml" "Edit reading stack (Uchiyomi / Kavita) secrets." ""

  # --- [DEVSHELLS] ---
  entry "[devshell]" "enter: sops-admin" "nix develop .#sops-admin" "Administrative shell loading Bitwarden master age key into SOPS_AGE_KEY." "Requires bitwarden unlock."
  entry "[devshell]" "enter: sops-host" "nix develop .#sops-host" "Operational shell loading host age key from /persist/sops-nix/key.txt." "Requires sudo to read host key."
  entry "[devshell]" "enter: github-ssh" "nix develop .#github-ssh" "Development shell configured with Bitwarden GitHub SSH deploy key." "Requires bitwarden unlock."
  entry "[devshell]" "enter: master-ssh" "nix develop .#master-ssh" "Cluster orchestration shell with Bitwarden master SSH key." "Requires bitwarden unlock."
  entry "[devshell]" "enter: default (devenv)" "nix develop .#default" "Main development shell with devenv, just, fzf, and linters." ""

  # --- [PACKAGES] ---
  entry "[package]" "run: docs CLI" "nix run .#docs" "Documentation engine CLI." ""
  entry "[package]" "run: graph CLI" "nix run .#graph" "Architecture LPG/CPG graph inspection CLI." ""
  entry "[package]" "run: foot terminal" "nix run .#foot" "Run wrapped Foot terminal with nixconf configuration." "Wayland only."
  entry "[package]" "run: dolphin file manager" "nix run .#dolphin" "Run wrapped Dolphin file manager." ""
  entry "[package]" "run: git wrapper" "nix run .#git -- --help" "Run Git with nixconf declarative configurations." ""
  entry "[package]" "run: bw wrapper" "nix run .#bw -- --help" "Run Bitwarden CLI client wrapper." ""
  entry "[package]" "run: antigravity CLI" "nix run .#antigravity-cli -- --help" "Run Antigravity assistant CLI." ""
  entry "[package]" "run: antigravity IDE" "nix run .#antigravity-ide" "Launch Antigravity IDE." ""

  # --- [TACK] ---
  entry "[tack]" "tack look" "tack look" "Inspect upstream drift of pinned flake inputs without modifying lockfile." ""
  entry "[tack]" "tack update (all)" "tack update" "Update all pinned dependencies in .tack/pins.toml and write pins.lock.json." "Updates lockfile."
  entry "[tack]" "tack tree" "tack tree" "Show input relationship tree and followed dependencies." ""
  entry "[tack]" "tack verify" "tack verify" "Verify cryptographically signed commits on pins requiring signers." ""

  # --- [HOST TESTING] ---
  entry "[test]" "test: eval (all hosts)" "nix run .#test -- eval" "Evaluate all host configurations and run fast static checks (bootloader, login, ssh)." "Fast (seconds, no KVM)."
  entry "[test]" "test: inspect (all hosts)" "nix run .#test -- inspect" "Validate /etc/fstab, PAM, sudoers, and sshd in a pure sandbox without KVM." "Fast (10-15s, no KVM)."
  entry "[test]" "test: vm (astrolabe VPS)" "nix run .#test -- vm astrolabe" "Boot astrolabe VPS in QEMU, verify secrets provisioning, SSH daemon, and systemd units." "Requires KVM."
  entry "[test]" "test: vm (x240 laptop)" "nix run .#test -- vm x240" "Boot x240 in QEMU, verify console login, sudo escalation, secrets, and systemd units." "Requires KVM."
  entry "[test]" "test: install (x240 laptop)" "nix run .#test -- install x240" "Partition Disko layout, install NixOS, and verify impermanence reboot survival." "Slow (requires KVM)."
  entry "[test]" "test: run interactive VM (x240)" "nix run .#test -- run x240" "Boot x240 interactive VM with stand-in secrets (SSH port forwarded to localhost:2222)." "Requires KVM."
  entry "[test]" "test: list hosts & checks" "nix run .#test -- list" "List all hosts, available test tiers, and registered test checks." ""

  # --- [CHECK & FORMATTING] ---
  entry "[check]" "format all files (nix fmt .)" "nix fmt ." "Format all Nix files across repository with Alejandra." "Includes dot argument."
  entry "[check]" "check formatting" "alejandra --check ." "Verify code formatting without modifying files." ""
  entry "[check]" "lint dead code & patterns" "statix check && deadnix" "Run Statix anti-pattern checks and Deadnix unused variable detection." ""
  entry "[check]" "flake check" "nix flake check" "Run all flake validation checks, primitive schema checks, and doc sync checks." ""
}

# Run FZF command palette
SELECTED=$(generate_catalog | fzf \
  --delimiter=$'\t' \
  --with-nth=1,2,3 \
  --height=60% \
  --reverse \
  --header="Select a command to run (Enter: Execute, Tab/Ctrl-Y: Copy to clipboard)" \
  --preview="bash \"$REPO_ROOT/scripts/menu.sh\" --preview {1} {2} {3} {4} {5}" \
  --preview-window=right:48%:wrap \
  --bind="tab:execute-silent(printf '%s' {3} | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || true)+abort" \
  --bind="ctrl-y:execute-silent(printf '%s' {3} | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || true)+abort" \
  --bind="ctrl-e:execute(echo {3})+abort" \
  || true)

if [ -z "$SELECTED" ]; then
  exit 0
fi

CMD=$(echo "$SELECTED" | awk -F'\t' '{print $3}')
TITLE=$(echo "$SELECTED" | awk -F'\t' '{print $2}')

if [ -n "$CMD" ]; then
  echo ""
  echo -e "\033[1;32m➜ Executing:\033[0m \033[1;37m$CMD\033[0m"
  echo ""
  eval "$CMD"
fi
