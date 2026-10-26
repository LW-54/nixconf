# Module: `fonts`

System typography and developer monospace font packages.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.fonts`
- **Description**: System typography and developer monospace font packages.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.fonts
          self.nixosModules.labwc
          self.nixosModules.noctalia
          self.nixosModules.audio
          self.nixosModules.cursor
          self.nixosModules.greetd
          self.nixosModules.x240-desktop-features
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.fonts.enableCoreFonts` | `unspecified value` |  |
| `options.fonts.enableDefaultFonts` | `boolean` | Alias of {option}`fonts.enableDefaultPackages`. |
| `options.fonts.enableDefaultPackages` | `boolean` | Enable a basic set of fonts providing several styles and families and reasonable coverage of Unicode. |
| `options.fonts.enableFontDir` | `boolean` | Alias of {option}`fonts.fontDir.enable`. |
| `options.fonts.enableGhostscriptFonts` | `boolean` | Whether to add the fonts provided by Ghostscript (such as various URW fonts and the “Base-14” Postscript fonts) to the list of system fonts, making them available to X11 applications. |
| `options.fonts.fontDir.decompressFonts` | `boolean` | Whether to decompress fonts in {file}`/run/current-system/sw/share/X11/fonts`. |
| `options.fonts.fontDir.enable` | `boolean` | Whether to create a directory with links to all fonts in {file}`/run/current-system/sw/share/X11/fonts`. |
| `options.fonts.fontconfig.aliases` | `attribute set of (submodule)` | Font aliases that can substitute preferential fonts, or specify custom fallback fonts. |
| `options.fonts.fontconfig.allowBitmaps` | `boolean` | Allow bitmap fonts. Set to `false` to ban all bitmap fonts. |
| `options.fonts.fontconfig.allowType1` | `boolean` | Allow Type-1 fonts. Default is `false` because of poor rendering. |
| `options.fonts.fontconfig.antialias` | `boolean` | Enable font antialiasing. At high resolution (> 200 DPI), antialiasing has no visible effect; users of such displays may want to disable this option. |
| `options.fonts.fontconfig.cache32Bit` | `boolean` | Generate system fonts cache for 32-bit applications. |
| `options.fonts.fontconfig.confPackages` | `list of absolute path` | Fontconfig configuration packages. |
| `options.fonts.fontconfig.defaultFonts.emoji` | `list of string` | System-wide default emoji font(s). Multiple fonts may be listed in case a font does not support all emoji.  Note that fontconfig matches color emoji fonts preferentially, so if you want to use a black and white font while having a color font installed (eg. Noto Color Emoji installed alongside Noto Emoji), fontconfig will still choose the color font even when it is later in the list. |
| `options.fonts.fontconfig.defaultFonts.monospace` | `list of string` | System-wide default monospace font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `options.fonts.fontconfig.defaultFonts.sansSerif` | `list of string` | System-wide default sans serif font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `options.fonts.fontconfig.defaultFonts.serif` | `list of string` | System-wide default serif font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `options.fonts.fontconfig.dpi` | `unspecified value` |  |
| `options.fonts.fontconfig.enable` | `boolean` | If enabled, a Fontconfig configuration file will be built pointing to a set of default fonts.  If you don't care about running X11 applications or any other program that uses Fontconfig, you can turn this option off and prevent a dependency on all those fonts. |
| `options.fonts.fontconfig.forceAutohint` | `unspecified value` |  |
| `options.fonts.fontconfig.hinting.autohint` | `boolean` | Enable the autohinter in place of the default interpreter. The results are usually lower quality than correctly-hinted fonts, but better than unhinted fonts. |
| `options.fonts.fontconfig.hinting.enable` | `boolean` | Enable font hinting. Hinting aligns glyphs to pixel boundaries to improve rendering sharpness at low resolution. At high resolution (> 200 dpi) hinting will do nothing (at best); users of such displays may want to disable this option. |
| `options.fonts.fontconfig.hinting.style` | `one of "none", "slight", "medium", "full"` | Hintstyle is the amount of font reshaping done to line up to the grid.  slight will make the font more fuzzy to line up to the grid but will be better in retaining font shape, while full will be a crisp font that aligns well to the pixel grid but will lose a greater amount of font shape. |
| `options.fonts.fontconfig.includeUserConf` | `boolean` | Include the user configuration from {file}`~/.config/fontconfig/fonts.conf` or {file}`~/.config/fontconfig/conf.d`. |
| `options.fonts.fontconfig.localConf` | `strings concatenated with "\n"` | System-wide customization file contents, has higher priority than `defaultFonts` settings. |
| `options.fonts.fontconfig.penultimate` | `unspecified value` |  |
| `options.fonts.fontconfig.renderMonoTTFAsBitmap` | `unspecified value` |  |
| `options.fonts.fontconfig.subpixel.lcdfilter` | `one of "none", "default", "light", "legacy"` | FreeType LCD filter. At high resolution (> 200 DPI), LCD filtering has no visible effect; users of such displays may want to select `none`. |
| `options.fonts.fontconfig.subpixel.rgba` | `one of "rgb", "bgr", "vrgb", "vbgr", "none"` | Subpixel order. The overwhelming majority of displays are `rgb` in their normal orientation. Select `vrgb` for mounting such a display 90 degrees clockwise from its normal orientation or `vbgr` for mounting 90 degrees counter-clockwise. Select `bgr` in the unlikely event of mounting 180 degrees from the normal orientation. Reverse these directions in the improbable event that the display's native subpixel order is `bgr`. |
| `options.fonts.fontconfig.ultimate.allowBitmaps` | `boolean` | Alias of {option}`fonts.fontconfig.allowBitmaps`. |
| `options.fonts.fontconfig.ultimate.allowType1` | `boolean` | Alias of {option}`fonts.fontconfig.allowType1`. |
| `options.fonts.fontconfig.ultimate.enable` | `unspecified value` |  |
| `options.fonts.fontconfig.ultimate.forceAutohint` | `unspecified value` | Alias of {option}`fonts.fontconfig.forceAutohint`. |
| `options.fonts.fontconfig.ultimate.preset` | `unspecified value` |  |
| `options.fonts.fontconfig.ultimate.renderMonoTTFAsBitmap` | `unspecified value` | Alias of {option}`fonts.fontconfig.renderMonoTTFAsBitmap`. |
| `options.fonts.fontconfig.ultimate.substitutions` | `unspecified value` |  |
| `options.fonts.fontconfig.ultimate.useEmbeddedBitmaps` | `boolean` | Alias of {option}`fonts.fontconfig.useEmbeddedBitmaps`. |
| `options.fonts.fontconfig.useEmbeddedBitmaps` | `boolean` | Use embedded bitmaps in fonts like Calibri. |
| `options.fonts.fonts` | `list of absolute path` | Alias of {option}`fonts.packages`. |
| `options.fonts.optimizeForVeryHighDPI` | `unspecified value` |  |
| `options.fonts.packages` | `list of absolute path` | List of primary font packages. |

