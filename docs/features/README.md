# Features

Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.

[← Back to Main README](../../README.md)

## Specification

- **Declared as**: `feature.<name>` in any flake-parts module under `modules/features/`
- **Primitive definition**: [`primitives/feature.nix`](../../primitives/feature.nix)
- **Instances**: 27

## Option Schema (`feature.<name>`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `description` | `string` | **required** | Formal description of this primitive instance. |
| `devShells` | `raw value` | `{ }` | Development shells provided by this primitive. |
| `lib` | `attribute set of raw value` | `{ }` | Library helper functions and values exported on flake.lib.<name>. |
| `modules` | `attribute set of module` | `{ }` | NixOS modules exported by this primitive. |
| `packages` | `raw value` | `{ }` | Packages provided by this primitive. |
| `types` | `attribute set of raw value` | `{ }` | Custom types declared and exported by this primitive. |

## Declaration Example

Smallest declaration in the repository, [`modules/features/fonts.nix`](../../modules/features/fonts.nix):

```nix
{...}: {
  feature.fonts = {
    description = "System typography and developer monospace font packages.";
    modules = {
      fonts = {pkgs, ...}: {
        fonts.packages = [pkgs.jetbrains-mono];
      };
    };
  };
}
```

## Catalog

| Feature | Description | Outputs | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`antigravity`](antigravity.md) | Google Antigravity IDE, agentic workflow tools, and CLI runtime. | [`antigravity`](../modules/antigravity.md) (module), [`antigravity-cli`](../modules/antigravity-cli.md) (module), [`antigravity-ide`](../modules/antigravity-ide.md) (module), [`antigravity`](../packages.md#antigravity) (package), [`antigravity-cli`](../packages.md#antigravity-cli) (package), [`antigravity-ide`](../packages.md#antigravity-ide) (package) | [`modules/features/antigravity.nix`](../../modules/features/antigravity.nix) | [More →](antigravity.md) |
| [`audio`](audio.md) | PipeWire sound server and real-time audio processing stack. | [`audio`](../modules/audio.md) (module) | [`modules/features/audio.nix`](../../modules/features/audio.nix) | [More →](audio.md) |
| [`bitwarden`](bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [`bitwarden-desktop`](../modules/bitwarden-desktop.md) (module), [`bw`](../modules/bw.md) (module), [`bw`](../packages.md#bw) (package) | [`modules/features/bitwarden.nix`](../../modules/features/bitwarden.nix) | [More →](bitwarden.md) |
| [`cosmic`](cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [`cosmic`](../modules/cosmic.md) (module) | [`modules/features/cosmic.nix`](../../modules/features/cosmic.nix) | [More →](cosmic.md) |
| [`cursor`](cursor.md) | XCursor theme configuration and icon assets. | [`cursor`](../modules/cursor.md) (module) | [`modules/features/cursor.nix`](../../modules/features/cursor.nix) | [More →](cursor.md) |
| [`direnv`](direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [`direnv`](../modules/direnv.md) (module) | [`modules/features/direnv.nix`](../../modules/features/direnv.nix) | [More →](direnv.md) |
| [`disko`](disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`disko`](../modules/disko.md) (module) | [`modules/features/disko.nix`](../../modules/features/disko.nix) | [More →](disko.md) |
| [`docker`](docker.md) | Docker application container engine, socket activation, and state persistence. | [`docker`](../modules/docker.md) (module) | [`modules/features/docker.nix`](../../modules/features/docker.nix) | [More →](docker.md) |
| [`dolphin`](dolphin.md) | KDE Dolphin file manager with Wayland integration and isolated runtime plugins. | [`dolphin`](../modules/dolphin.md) (module), [`dolphin`](../packages.md#dolphin) (package) | [`modules/features/dolphin.nix`](../../modules/features/dolphin.nix) | [More →](dolphin.md) |
| [`fonts`](fonts.md) | System typography and developer monospace font packages. | [`fonts`](../modules/fonts.md) (module) | [`modules/features/fonts.nix`](../../modules/features/fonts.nix) | [More →](fonts.md) |
| [`foot`](foot.md) | Fast, lightweight Wayland terminal emulator with server-client architecture. | [`foot`](../modules/foot.md) (module), [`foot`](../packages.md#foot) (package) | [`modules/features/foot.nix`](../../modules/features/foot.nix) | [More →](foot.md) |
| [`git`](git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [`git`](../modules/git.md) (module), [`git`](../packages.md#git) (package), [`github-ssh`](../devshells.md#github-ssh) (devShell) | [`modules/features/git.nix`](../../modules/features/git.nix) | [More →](git.md) |
| [`greetd`](greetd.md) | Lightweight console greeter and graphical session launcher via tuigreet. | [`greetd`](../modules/greetd.md) (module) | [`modules/features/greetd.nix`](../../modules/features/greetd.nix) | [More →](greetd.md) |
| [`helium`](helium.md) | Helium web browser with custom runtime flags and enterprise policy management. | [`helium`](../modules/helium.md) (module) | [`modules/features/helium.nix`](../../modules/features/helium.nix) | [More →](helium.md) |
| [`labwc`](labwc.md) | Labwc stacking Wayland compositor with window manager keybindings and XDG autostart. | [`labwc`](../modules/labwc.md) (module) | [`modules/features/labwc.nix`](../../modules/features/labwc.nix) | [More →](labwc.md) |
| [`locale`](locale.md) | System internationalization, time zone, and language locale configuration. | [`locale`](../modules/locale.md) (module) | [`modules/features/locale.nix`](../../modules/features/locale.nix) | [More →](locale.md) |
| [`nix`](nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [`nix`](../modules/nix.md) (module) | [`modules/features/nix.nix`](../../modules/features/nix.nix) | [More →](nix.md) |
| [`noctalia`](noctalia.md) | Noctalia shell environment, status bar, app launcher, and wallpaper manager. | [`noctalia`](../modules/noctalia.md) (module) | [`modules/features/noctalia.nix`](../../modules/features/noctalia.nix) | [More →](noctalia.md) |
| [`ssh`](ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [`ssh`](../modules/ssh.md) (module), [`master-ssh`](../devshells.md#master-ssh) (devShell) | [`modules/features/ssh.nix`](../../modules/features/ssh.nix) | [More →](ssh.md) |
| [`tack`](tack.md) | Flake input pinning and lockfile orchestration tool. | [`tack`](../modules/tack.md) (module) | [`modules/features/tack.nix`](../../modules/features/tack.nix) | [More →](tack.md) |
| [`ttyd`](ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [`ttyd`](../modules/ttyd.md) (module) | [`modules/features/ttyd.nix`](../../modules/features/ttyd.nix) | [More →](ttyd.md) |
| [`uchiyomi`](uchiyomi.md) | Self-hosted manga, manhwa, and webtoon server, reader, and downloader stack. | [`uchiyomi`](../modules/uchiyomi.md) (module) | [`modules/features/uchiyomi.nix`](../../modules/features/uchiyomi.nix) | [More →](uchiyomi.md) |
| [`user`](user.md) | Normal user account helper functions and querying utilities. | — | [`modules/features/user.nix`](../../modules/features/user.nix) | [More →](user.md) |
| [`vaultwarden`](vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [`vaultwarden`](../modules/vaultwarden.md) (module) | [`modules/features/vaultwarden.nix`](../../modules/features/vaultwarden.nix) | [More →](vaultwarden.md) |
| [`vivaldi`](vivaldi.md) | Vivaldi web browser with Widevine and proprietary media codecs. | [`vivaldi`](../modules/vivaldi.md) (module) | [`modules/features/vivaldi.nix`](../../modules/features/vivaldi.nix) | [More →](vivaldi.md) |
| [`vscode`](vscode.md) | Visual Studio Code editor environment and persistence. | [`vscode`](../modules/vscode.md) (module) | [`modules/features/vcode.nix`](../../modules/features/vcode.nix) | [More →](vscode.md) |
| [`wifi-eduroam`](wifi-eduroam.md) | Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager. | [`wifi-eduroam`](../modules/wifi-eduroam.md) (module) | [`modules/features/wifi.nix`](../../modules/features/wifi.nix) | [More →](wifi-eduroam.md) |
