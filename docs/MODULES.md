# Modules Documentation

Complete directory of all NixOS modules exported on `flake.nixosModules`.

[← Back to Main README](../README.md)

## Exported Modules Catalog

| Module | Description | Docs |
| :--- | :--- | :--- |
| [`antigravity`](modules/antigravity.md) | Google Antigravity IDE, agentic workflow tools, and CLI runtime. | [More →](modules/antigravity.md) |
| [`antigravity-cli`](modules/antigravity-cli.md) | System service module exported by the 'antigravity' feature. | [More →](modules/antigravity-cli.md) |
| [`antigravity-ide`](modules/antigravity-ide.md) | System service module exported by the 'antigravity' feature. | [More →](modules/antigravity-ide.md) |
| [`astrolabe`](modules/astrolabe.md) | Unified NixOS system configuration root module for host 'astrolabe'. | [More →](modules/astrolabe.md) |
| [`astrolabe-disk`](modules/astrolabe-disk.md) | Storage partition layout, Btrfs subvolumes, and swap configuration for astrolabe. | [More →](modules/astrolabe-disk.md) |
| [`astrolabe-hardware`](modules/astrolabe-hardware.md) | Hardware profile, kernel modules, and bootloader configuration for astrolabe. | [More →](modules/astrolabe-hardware.md) |
| [`astrolabe-packages`](modules/astrolabe-packages.md) | Host configuration submodule for astrolabe. | [More →](modules/astrolabe-packages.md) |
| [`astrolabe-services`](modules/astrolabe-services.md) | Host configuration submodule for astrolabe. | [More →](modules/astrolabe-services.md) |
| [`astrolabe-system`](modules/astrolabe-system.md) | Host configuration submodule for astrolabe. | [More →](modules/astrolabe-system.md) |
| [`audio`](modules/audio.md) | PipeWire sound server and real-time audio processing stack. | [More →](modules/audio.md) |
| [`backup`](modules/backup.md) | Contract interface defining 'backup' option schemas and custom types. | [More →](modules/backup.md) |
| [`bitwarden-desktop`](modules/bitwarden-desktop.md) | System service module exported by the 'bitwarden' feature. | [More →](modules/bitwarden-desktop.md) |
| [`bw`](modules/bw.md) | System service module exported by the 'bitwarden' feature. | [More →](modules/bw.md) |
| [`caddy`](modules/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [More →](modules/caddy.md) |
| [`cgroups`](modules/cgroups.md) | Systemd control groups slice hierarchy and resource quotas implementation. | [More →](modules/cgroups.md) |
| [`contracts`](modules/contracts.md) | Central contract registry importing all declared contract interfaces. | [More →](modules/contracts.md) |
| [`cosmic`](modules/cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [More →](modules/cosmic.md) |
| [`cursor`](modules/cursor.md) | XCursor theme configuration and icon assets. | [More →](modules/cursor.md) |
| [`default-user`](modules/default-user.md) | Contract interface defining 'default-user' option schemas and custom types. | [More →](modules/default-user.md) |
| [`direnv`](modules/direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [More →](modules/direnv.md) |
| [`disko`](modules/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [More →](modules/disko.md) |
| [`dolphin`](modules/dolphin.md) | KDE Dolphin file manager with Wayland integration and isolated runtime plugins. | [More →](modules/dolphin.md) |
| [`fonts`](modules/fonts.md) | System typography and developer monospace font packages. | [More →](modules/fonts.md) |
| [`foot`](modules/foot.md) | Fast, lightweight Wayland terminal emulator with server-client architecture. | [More →](modules/foot.md) |
| [`git`](modules/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [More →](modules/git.md) |
| [`greetd`](modules/greetd.md) | Lightweight console greeter and graphical session launcher via tuigreet. | [More →](modules/greetd.md) |
| [`helium`](modules/helium.md) | Helium web browser with custom runtime flags and enterprise policy management. | [More →](modules/helium.md) |
| [`hjem`](modules/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [More →](modules/hjem.md) |
| [`home`](modules/home.md) | Contract interface defining 'home' option schemas and custom types. | [More →](modules/home.md) |
| [`impermanence`](modules/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](modules/impermanence.md) |
| [`labwc`](modules/labwc.md) | Labwc stacking Wayland compositor with window manager keybindings and XDG autostart. | [More →](modules/labwc.md) |
| [`locale`](modules/locale.md) | System internationalization, time zone, and language locale configuration. | [More →](modules/locale.md) |
| [`lw`](modules/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](modules/lw.md) |
| [`nix`](modules/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [More →](modules/nix.md) |
| [`noctalia`](modules/noctalia.md) | Noctalia shell environment, status bar, app launcher, and wallpaper manager. | [More →](modules/noctalia.md) |
| [`persistence`](modules/persistence.md) | Contract interface defining 'persistence' option schemas and custom types. | [More →](modules/persistence.md) |
| [`resources`](modules/resources.md) | Contract interface defining 'resources' option schemas and custom types. | [More →](modules/resources.md) |
| [`restic`](modules/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [More →](modules/restic.md) |
| [`reverse-proxy`](modules/reverse-proxy.md) | Contract interface defining 'reverse-proxy' option schemas and custom types. | [More →](modules/reverse-proxy.md) |
| [`secrets`](modules/secrets.md) | Contract interface defining 'secrets' option schemas and custom types. | [More →](modules/secrets.md) |
| [`sops`](modules/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](modules/sops.md) |
| [`ssh`](modules/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [More →](modules/ssh.md) |
| [`tack`](modules/tack.md) | Flake input pinning and lockfile orchestration tool. | [More →](modules/tack.md) |
| [`ttyd`](modules/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [More →](modules/ttyd.md) |
| [`uwsm`](modules/uwsm.md) | Universal Wayland Session Manager integration for desktop environments. | [More →](modules/uwsm.md) |
| [`vaultwarden`](modules/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [More →](modules/vaultwarden.md) |
| [`vivaldi`](modules/vivaldi.md) | Vivaldi web browser with Widevine and proprietary media codecs. | [More →](modules/vivaldi.md) |
| [`vscode`](modules/vscode.md) | Visual Studio Code editor environment and persistence. | [More →](modules/vscode.md) |
| [`wayland`](modules/wayland.md) | Contract interface defining 'wayland' option schemas and custom types. | [More →](modules/wayland.md) |
| [`wifi-eduroam`](modules/wifi-eduroam.md) | Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager. | [More →](modules/wifi-eduroam.md) |
| [`x240`](modules/x240.md) | Unified NixOS system configuration root module for host 'x240'. | [More →](modules/x240.md) |
| [`x240-desktop`](modules/x240-desktop.md) | Host configuration submodule for x240. | [More →](modules/x240-desktop.md) |
| [`x240-desktop-features`](modules/x240-desktop-features.md) | Host configuration submodule for x240. | [More →](modules/x240-desktop-features.md) |
| [`x240-disk`](modules/x240-disk.md) | Storage partition layout, Btrfs subvolumes, and swap configuration for x240. | [More →](modules/x240-disk.md) |
| [`x240-hardware`](modules/x240-hardware.md) | Hardware profile, kernel modules, and bootloader configuration for x240. | [More →](modules/x240-hardware.md) |
| [`x240-packages`](modules/x240-packages.md) | Host configuration submodule for x240. | [More →](modules/x240-packages.md) |
| [`x240-system`](modules/x240-system.md) | Host configuration submodule for x240. | [More →](modules/x240-system.md) |
| [`x240-system-features`](modules/x240-system-features.md) | Host configuration submodule for x240. | [More →](modules/x240-system-features.md) |
