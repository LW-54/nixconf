# Features Documentation

Reusable system services and applications declared via `options.feature` in [`primitives/feature.nix`](../primitives/feature.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.

### Option Schema (`options.feature.<name>`)

- `description` (string, required): Formal description of the feature and service scope.
- `modules` (attrsOf deferredModule, default: `{}`): Named NixOS configuration modules exported by this feature.
- `packages` (raw, default: `{}`): Executable packages or package generator function exported on `flake.packages`.
- `devShells` (raw, default: `{}`): Development environments or shell generator function exported on `flake.devShells`.
- `lib` (attrsOf raw, default: `{}`): Helper functions exported on `flake.lib.<name>`.
- `types` (attrsOf raw, default: `{}`): Custom option submodules and types.

### Declaration Example (`feature.<name>`)

```nix
feature.example-feature = {
  description = "Application and service environment.";
  modules = {
    example-feature = { pkgs, ... }: { ... };
  };
};
```

## Features Catalog

| Feature | Description | Docs |
| :--- | :--- | :--- |
| [`antigravity`](features/antigravity.md) | Google Antigravity IDE, agentic workflow tools, and CLI runtime. | [More →](features/antigravity.md) |
| [`audio`](features/audio.md) | PipeWire sound server and real-time audio processing stack. | [More →](features/audio.md) |
| [`bitwarden`](features/bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [More →](features/bitwarden.md) |
| [`cosmic`](features/cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [More →](features/cosmic.md) |
| [`cursor`](features/cursor.md) | XCursor theme configuration and icon assets. | [More →](features/cursor.md) |
| [`direnv`](features/direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [More →](features/direnv.md) |
| [`disko`](features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [More →](features/disko.md) |
| [`dolphin`](features/dolphin.md) | KDE Dolphin file manager with Wayland integration and isolated runtime plugins. | [More →](features/dolphin.md) |
| [`fonts`](features/fonts.md) | System typography and developer monospace font packages. | [More →](features/fonts.md) |
| [`foot`](features/foot.md) | Fast, lightweight Wayland terminal emulator with server-client architecture. | [More →](features/foot.md) |
| [`git`](features/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [More →](features/git.md) |
| [`greetd`](features/greetd.md) | Lightweight console greeter and graphical session launcher via tuigreet. | [More →](features/greetd.md) |
| [`helium`](features/helium.md) | Helium web browser with custom runtime flags and enterprise policy management. | [More →](features/helium.md) |
| [`labwc`](features/labwc.md) | Labwc stacking Wayland compositor with window manager keybindings and XDG autostart. | [More →](features/labwc.md) |
| [`locale`](features/locale.md) | System internationalization, time zone, and language locale configuration. | [More →](features/locale.md) |
| [`nix`](features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [More →](features/nix.md) |
| [`noctalia`](features/noctalia.md) | Noctalia shell environment, status bar, app launcher, and wallpaper manager. | [More →](features/noctalia.md) |
| [`ssh`](features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [More →](features/ssh.md) |
| [`tack`](features/tack.md) | Flake input pinning and lockfile orchestration tool. | [More →](features/tack.md) |
| [`ttyd`](features/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [More →](features/ttyd.md) |
| [`user`](features/user.md) | Normal user account helper functions and querying utilities. | [More →](features/user.md) |
| [`vaultwarden`](features/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [More →](features/vaultwarden.md) |
| [`vivaldi`](features/vivaldi.md) | Vivaldi web browser with Widevine and proprietary media codecs. | [More →](features/vivaldi.md) |
| [`vscode`](features/vscode.md) | Visual Studio Code editor environment and persistence. | [More →](features/vscode.md) |
| [`wifi-eduroam`](features/wifi-eduroam.md) | Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager. | [More →](features/wifi-eduroam.md) |
