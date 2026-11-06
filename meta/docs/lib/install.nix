# Shared host installation & deployment guide renderer.
# Used by both README.md (generic template) and host pages (targeted host).
{config, ...}: let
  renderInstallationGuide = {
    target ? "<HOST>",
    repoUrl ? config.docs.project.url,
    keyPath ? "/persist/sops-nix/key.txt",
    mountKeyDir ? "/mnt/persist/sops-nix",
  }: ''
    ### Track 1: Remote Automated Deployment via `nixos-anywhere`

    For headless cloud instances or network-accessible hosts booted into a live environment:

    ```bash
    # 1. Obtain and verify SSH root access to target IP
    ssh root@<TARGET-IP>

    # 2. Deploy system, format partitions via Disko, and copy SOPS secret key
    nix run github:nix-community/nixos-anywhere -- \
      --flake .#${target} \
      --copy-secret /path/to/host-key.txt ${keyPath} \
      root@<TARGET-IP>
    ```

    ### Track 2: Local Host Installation (NixOS Live ISO)

    For bare-metal physical hosts booted from a standard NixOS Live ISO USB drive:

    ```bash
    # 1. Elevate to root in the live environment
    sudo -i

    # 2. Clone repository to live memory
    git clone ${repoUrl} /tmp/nixconf
    cd /tmp/nixconf

    # 3. Format disk and mount partitions declaratively via Disko
    nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
      --mode zap_create_mount \
      --flake .#${target}

    # 4. Provision SOPS age secret key on mounted persistence volume
    install -d -m 0700 ${mountKeyDir}
    install -m 0400 /path/to/host-key.txt ${mountKeyDir}/key.txt

    # 5. Install NixOS to target disk and reboot
    nixos-install --flake .#${target} --no-root-passwd
    reboot
    ```

    ### Track 3: Host Maintenance & System Rebuilds

    ```bash
    # Rebuild and switch locally on the host
    sudo nixos-rebuild switch --flake .#${target}

    # Remote deployment over SSH from a management machine
    nixos-rebuild switch --flake .#${target} --target-host root@<TARGET-IP>
    ```
  '';
in {
  internal.docs.installGuide = renderInstallationGuide;
}
