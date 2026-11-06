# Module: `fonts`

System typography and developer monospace font packages.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.fonts`
- **Provided by**: feature [`fonts`](../features/fonts.md)

## Importing Hosts

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `fonts.enableCoreFonts` | `unspecified value` | — | — |  |
| `fonts.enableDefaultFonts` | `boolean` | — | — | Alias of {option}`fonts.enableDefaultPackages`. |
| `fonts.enableDefaultPackages` | `boolean` | `false` | — | Enable a basic set of fonts providing several styles and families and reasonable coverage of Unicode. |
| `fonts.enableFontDir` | `boolean` | — | — | Alias of {option}`fonts.fontDir.enable`. |
| `fonts.enableGhostscriptFonts` | `boolean` | `false` | — | Whether to add the fonts provided by Ghostscript (such as various URW fonts and the “Base-14” Postscript fonts) to the list of system fonts, making them available to X11 applications. |
| `fonts.fontDir.decompressFonts` | `boolean` | `config.programs.xwayland.enable` | — | Whether to decompress fonts in {file}`/run/current-system/sw/share/X11/fonts`. |
| `fonts.fontDir.enable` | `boolean` | `false` | — | Whether to create a directory with links to all fonts in {file}`/run/current-system/sw/share/X11/fonts`. |
| `fonts.fontconfig.aliases` | `attribute set of (submodule)` | `{ }` | `{ # use FreeSans for Greek symbols missing in Helvetica "Helvetica" = { default = [ "FreeSans" ]; }; };` | Font aliases that can substitute preferential fonts, or specify custom fallback fonts. |
| `fonts.fontconfig.allowBitmaps` | `boolean` | `true` | — | Allow bitmap fonts. Set to `false` to ban all bitmap fonts. |
| `fonts.fontconfig.allowType1` | `boolean` | `false` | — | Allow Type-1 fonts. Default is `false` because of poor rendering. |
| `fonts.fontconfig.antialias` | `boolean` | `true` | — | Enable font antialiasing. At high resolution (> 200 DPI), antialiasing has no visible effect; users of such displays may want to disable this option. |
| `fonts.fontconfig.cache32Bit` | `boolean` | `false` | — | Generate system fonts cache for 32-bit applications. |
| `fonts.fontconfig.confPackages` | `list of absolute path` | `[ ]` | — | Fontconfig configuration packages. |
| `fonts.fontconfig.defaultFonts.emoji` | `list of string` | `[ ... ]` | — | System-wide default emoji font(s). Multiple fonts may be listed in case a font does not support all emoji. Note that fontconfig matches color emoji fonts preferentially, so if you want to use a black and white font while having a color font installed (eg. Noto Color Emoji installed alongside Noto Emoji), fontconfig will still choose the color font even when it is later in the list. |
| `fonts.fontconfig.defaultFonts.monospace` | `list of string` | `[ ... ]` | — | System-wide default monospace font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `fonts.fontconfig.defaultFonts.sansSerif` | `list of string` | `[ ... ]` | — | System-wide default sans serif font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `fonts.fontconfig.defaultFonts.serif` | `list of string` | `[ ... ]` | — | System-wide default serif font(s). Multiple fonts may be listed in case multiple languages must be supported. |
| `fonts.fontconfig.dpi` | `unspecified value` | — | — |  |
| `fonts.fontconfig.enable` | `boolean` | `true` | — | If enabled, a Fontconfig configuration file will be built pointing to a set of default fonts. If you don't care about running X11 applications or any other program that uses Fontconfig, you can turn this option off and prevent a dependency on all those fonts. |
| `fonts.fontconfig.forceAutohint` | `unspecified value` | — | — |  |
| `fonts.fontconfig.hinting.autohint` | `boolean` | `false` | — | Enable the autohinter in place of the default interpreter. The results are usually lower quality than correctly-hinted fonts, but better than unhinted fonts. |
| `fonts.fontconfig.hinting.enable` | `boolean` | `true` | — | Enable font hinting. Hinting aligns glyphs to pixel boundaries to improve rendering sharpness at low resolution. At high resolution (> 200 dpi) hinting will do nothing (at best); users of such displays may want to disable this option. |
| `fonts.fontconfig.hinting.style` | `one of "none", "slight", "medium", "full"` | `"slight"` | — | Hintstyle is the amount of font reshaping done to line up to the grid. slight will make the font more fuzzy to line up to the grid but will be better in retaining font shape, while full will be a crisp font that aligns well to the pixel grid but will lose a greater amount of font shape. |
| `fonts.fontconfig.includeUserConf` | `boolean` | `true` | — | Include the user configuration from {file}`~/.config/fontconfig/fonts.conf` or {file}`~/.config/fontconfig/conf.d`. |
| `fonts.fontconfig.localConf` | `strings concatenated with "\n"` | `""` | — | System-wide customization file contents, has higher priority than `defaultFonts` settings. |
| `fonts.fontconfig.penultimate` | `unspecified value` | — | — |  |
| `fonts.fontconfig.renderMonoTTFAsBitmap` | `unspecified value` | — | — |  |
| `fonts.fontconfig.subpixel.lcdfilter` | `one of "none", "default", "light", "legacy"` | `"default"` | — | FreeType LCD filter. At high resolution (> 200 DPI), LCD filtering has no visible effect; users of such displays may want to select `none`. |
| `fonts.fontconfig.subpixel.rgba` | `one of "rgb", "bgr", "vrgb", "vbgr", "none"` | `"none"` | — | Subpixel order. The overwhelming majority of displays are `rgb` in their normal orientation. Select `vrgb` for mounting such a display 90 degrees clockwise from its normal orientation or `vbgr` for mounting 90 degrees counter-clockwise. Select `bgr` in the unlikely event of mounting 180 degrees from the normal orientation. Reverse these directions in the improbable event that the display's native subpixel order is `bgr`. |
| `fonts.fontconfig.ultimate.allowBitmaps` | `boolean` | — | — | Alias of {option}`fonts.fontconfig.allowBitmaps`. |
| `fonts.fontconfig.ultimate.allowType1` | `boolean` | — | — | Alias of {option}`fonts.fontconfig.allowType1`. |
| `fonts.fontconfig.ultimate.enable` | `unspecified value` | — | — |  |
| `fonts.fontconfig.ultimate.forceAutohint` | `unspecified value` | — | — | Alias of {option}`fonts.fontconfig.forceAutohint`. |
| `fonts.fontconfig.ultimate.preset` | `unspecified value` | — | — |  |
| `fonts.fontconfig.ultimate.renderMonoTTFAsBitmap` | `unspecified value` | — | — | Alias of {option}`fonts.fontconfig.renderMonoTTFAsBitmap`. |
| `fonts.fontconfig.ultimate.substitutions` | `unspecified value` | — | — |  |
| `fonts.fontconfig.ultimate.useEmbeddedBitmaps` | `boolean` | — | — | Alias of {option}`fonts.fontconfig.useEmbeddedBitmaps`. |
| `fonts.fontconfig.useEmbeddedBitmaps` | `boolean` | `true` | — | Use embedded bitmaps in fonts like Calibri. |
| `fonts.fonts` | `list of absolute path` | — | — | Alias of {option}`fonts.packages`. |
| `fonts.optimizeForVeryHighDPI` | `unspecified value` | — | — |  |
| `fonts.packages` | `list of absolute path` | `[ ]` | `[ pkgs.dejavu_fonts ]` | List of primary font packages. |
