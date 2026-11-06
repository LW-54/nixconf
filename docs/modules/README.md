# Modules

Every NixOS module exported on `flake.nixosModules`.

[← Back to Main README](../../README.md)

| Module | Provided by | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`antigravity`](antigravity.md) | feature [`antigravity`](../features/antigravity.md) | Google Antigravity IDE, agentic workflow tools, and CLI runtime. | [More →](antigravity.md) |
| [`antigravity-cli`](antigravity-cli.md) | feature [`antigravity`](../features/antigravity.md) | NixOS module exported by feature 'antigravity'. | [More →](antigravity-cli.md) |
| [`antigravity-ide`](antigravity-ide.md) | feature [`antigravity`](../features/antigravity.md) | NixOS module exported by feature 'antigravity'. | [More →](antigravity-ide.md) |
| [`astrolabe`](astrolabe.md) | host [`astrolabe`](../hosts/astrolabe.md) | Headless VPS Server (adje.app public edge and core services). | [More →](astrolabe.md) |
| [`astrolabe-disk`](astrolabe-disk.md) | host [`astrolabe`](../hosts/astrolabe.md) | NixOS module exported by host 'astrolabe'. | [More →](astrolabe-disk.md) |
| [`astrolabe-hardware`](astrolabe-hardware.md) | host [`astrolabe`](../hosts/astrolabe.md) | NixOS module exported by host 'astrolabe'. | [More →](astrolabe-hardware.md) |
| [`astrolabe-packages`](astrolabe-packages.md) | host [`astrolabe`](../hosts/astrolabe.md) | NixOS module exported by host 'astrolabe'. | [More →](astrolabe-packages.md) |
| [`astrolabe-services`](astrolabe-services.md) | host [`astrolabe`](../hosts/astrolabe.md) | NixOS module exported by host 'astrolabe'. | [More →](astrolabe-services.md) |
| [`astrolabe-system`](astrolabe-system.md) | host [`astrolabe`](../hosts/astrolabe.md) | NixOS module exported by host 'astrolabe'. | [More →](astrolabe-system.md) |
| [`audio`](audio.md) | feature [`audio`](../features/audio.md) | PipeWire sound server and real-time audio processing stack. | [More →](audio.md) |
| [`backup`](backup.md) | contract [`backup`](../contracts/backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [More →](backup.md) |
| [`bitwarden-desktop`](bitwarden-desktop.md) | feature [`bitwarden`](../features/bitwarden.md) | NixOS module exported by feature 'bitwarden'. | [More →](bitwarden-desktop.md) |
| [`bw`](bw.md) | feature [`bitwarden`](../features/bitwarden.md) | NixOS module exported by feature 'bitwarden'. | [More →](bw.md) |
| [`caddy`](caddy.md) | implementation [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [More →](caddy.md) |
| [`contracts`](contracts.md) | — | Exported NixOS module 'contracts'. | [More →](contracts.md) |
| [`cosmic`](cosmic.md) | feature [`cosmic`](../features/cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [More →](cosmic.md) |
| [`cursor`](cursor.md) | feature [`cursor`](../features/cursor.md) | XCursor theme configuration and icon assets. | [More →](cursor.md) |
| [`default-user`](default-user.md) | contract [`default-user`](../contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [More →](default-user.md) |
| [`direnv`](direnv.md) | feature [`direnv`](../features/direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [More →](direnv.md) |
| [`disko`](disko.md) | feature [`disko`](../features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [More →](disko.md) |
| [`docker`](docker.md) | feature [`docker`](../features/docker.md) | Docker application container engine, socket activation, and state persistence. | [More →](docker.md) |
| [`dolphin`](dolphin.md) | feature [`dolphin`](../features/dolphin.md) | KDE Dolphin file manager with Wayland integration and isolated runtime plugins. | [More →](dolphin.md) |
| [`fonts`](fonts.md) | feature [`fonts`](../features/fonts.md) | System typography and developer monospace font packages. | [More →](fonts.md) |
| [`foot`](foot.md) | feature [`foot`](../features/foot.md) | Fast, lightweight Wayland terminal emulator with server-client architecture. | [More →](foot.md) |
| [`git`](git.md) | feature [`git`](../features/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [More →](git.md) |
| [`greetd`](greetd.md) | feature [`greetd`](../features/greetd.md) | Lightweight console greeter and graphical session launcher via tuigreet. | [More →](greetd.md) |
| [`helium`](helium.md) | feature [`helium`](../features/helium.md) | Helium web browser with custom runtime flags and enterprise policy management. | [More →](helium.md) |
| [`hjem`](hjem.md) | implementation [`hjem`](../implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [More →](hjem.md) |
| [`home`](home.md) | contract [`home`](../contracts/home.md) | Declarative user home dotfile tree, XDG directory specifications, and session environment. | [More →](home.md) |
| [`impermanence`](impermanence.md) | implementation [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](impermanence.md) |
| [`labwc`](labwc.md) | feature [`labwc`](../features/labwc.md) | Labwc stacking Wayland compositor with window manager keybindings and XDG autostart. | [More →](labwc.md) |
| [`locale`](locale.md) | feature [`locale`](../features/locale.md) | System internationalization, time zone, and language locale configuration. | [More →](locale.md) |
| [`lw`](lw.md) | implementation [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](lw.md) |
| [`nix`](nix.md) | feature [`nix`](../features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [More →](nix.md) |
| [`noctalia`](noctalia.md) | feature [`noctalia`](../features/noctalia.md) | Noctalia shell environment, status bar, app launcher, and wallpaper manager. | [More →](noctalia.md) |
| [`persistence`](persistence.md) | contract [`persistence`](../contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [More →](persistence.md) |
| [`restic`](restic.md) | implementation [`restic`](../implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [More →](restic.md) |
| [`reverse-proxy`](reverse-proxy.md) | contract [`reverse-proxy`](../contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [More →](reverse-proxy.md) |
| [`secrets`](secrets.md) | contract [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [More →](secrets.md) |
| [`sops`](sops.md) | implementation [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](sops.md) |
| [`ssh`](ssh.md) | feature [`ssh`](../features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [More →](ssh.md) |
| [`tack`](tack.md) | feature [`tack`](../features/tack.md) | Flake input pinning and lockfile orchestration tool. | [More →](tack.md) |
| [`ttyd`](ttyd.md) | feature [`ttyd`](../features/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [More →](ttyd.md) |
| [`uchiyomi`](uchiyomi.md) | feature [`uchiyomi`](../features/uchiyomi.md) | Self-hosted manga, manhwa, and webtoon server, reader, and downloader stack. | [More →](uchiyomi.md) |
| [`uwsm`](uwsm.md) | implementation [`uwsm`](../implementations/uwsm.md) | Universal Wayland Session Manager integration for desktop environments. | [More →](uwsm.md) |
| [`vaultwarden`](vaultwarden.md) | feature [`vaultwarden`](../features/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [More →](vaultwarden.md) |
| [`vivaldi`](vivaldi.md) | feature [`vivaldi`](../features/vivaldi.md) | Vivaldi web browser with Widevine and proprietary media codecs. | [More →](vivaldi.md) |
| [`vscode`](vscode.md) | feature [`vscode`](../features/vscode.md) | Visual Studio Code editor environment and persistence. | [More →](vscode.md) |
| [`wayland`](wayland.md) | contract [`wayland`](../contracts/wayland.md) | Wayland compositor registration, session targets, and graphical environment management. | [More →](wayland.md) |
| [`wifi-eduroam`](wifi-eduroam.md) | feature [`wifi-eduroam`](../features/wifi-eduroam.md) | Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager. | [More →](wifi-eduroam.md) |
| [`x240`](x240.md) | host [`x240`](../hosts/x240.md) | ThinkPad Laptop Workstation (Desktop graphical workstation). | [More →](x240.md) |
| [`x240-desktop`](x240-desktop.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-desktop.md) |
| [`x240-desktop-features`](x240-desktop-features.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-desktop-features.md) |
| [`x240-disk`](x240-disk.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-disk.md) |
| [`x240-hardware`](x240-hardware.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-hardware.md) |
| [`x240-packages`](x240-packages.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-packages.md) |
| [`x240-system`](x240-system.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-system.md) |
| [`x240-system-features`](x240-system-features.md) | host [`x240`](../hosts/x240.md) | NixOS module exported by host 'x240'. | [More →](x240-system-features.md) |
