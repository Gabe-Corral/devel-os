# Suckless Package Patches

This project vendors customized `dwm` and `dmenu` sources in `install/`. The package builds do not apply standalone patch files; the patches and configuration changes are already integrated into the source trees before package tarballs are generated.

## dwm

Package source: `install/dwm`

Upstream base: `dwm` 6.8

### Applied Patches

- `awesomebar`
- Adds a taskbar-style window list that displays visible clients in the bar.
- Supports hidden windows using `IconicState`, with a separate hidden-client color scheme.
- Adds clickable window titles in the bar through `togglewin`.
- Adds keyboard navigation for visible and hidden clients through `focusstackvis` and `focusstackhid`.
- Adds `show`, `showall`, `showwin`, and `hidewin` helpers.
- Restores hidden clients on quit so they do not remain hidden after restarting `dwm`.

- `gaps`
- Source: https://dwm.suckless.org/patches/gaps/
- Adds a configurable gap between tiled clients in the `tile` layout.
- Adds `gappx` to `config.def.h`; DevelOS currently sets it to `1`.
- Keeps the outer screen edge gapless, matching the upstream patch behavior.

Relevant source locations:

- `install/dwm/dwm.c`
- `install/dwm/config.def.h`

### Configuration Changes

- Font changed to `JetBrainsMono Nerd Font:size=11`.
- Colors changed to a Dracula-style palette.
- Added `SchemeHid` for hidden-client taskbar entries.
- Tag labels changed from 9 labels to `1`, `2`, `3`, `4`, while the existing `TAGKEYS` entries still define bindings for tags 1 through 9.
- Terminal command changed from `st` to `alacritty`.
- `dmenu_run` colors changed to match the custom theme.
- `Mod-j` and `Mod-k` now focus visible clients only.
- `Mod-Shift-j` and `Mod-Shift-k` focus hidden clients as well.
- `Mod-s` shows the selected hidden client.
- `Mod-Shift-s` shows all hidden clients on the current tag.
- Left-clicking a window title in the bar toggles that window.
- Tiled windows have a `4px` internal gap through `gappx`.

## dmenu

Package source: `install/dmenu`

Upstream base: `dmenu` 5.4

### Applied Patches

- `fuzzymatch`
- Enables fuzzy matching by default.
- Adds `-F` to disable fuzzy matching.
- Adds match distance scoring and sorting.
- Adds `-lm` to `LIBS` because fuzzy matching uses math functions.

- `center`
- Adds centered menu support.
- Adds `centered` and `min_width` configuration values.
- Adds `-c` support for centering the menu.
- Calculates centered menu width from the widest item, prompt width, and minimum width.

- `border`
- Adds configurable window border width.
- Adds `border_width` configuration.
- Adds `-bw` support.
- Sets the dmenu window border color from the selected background color.

- `mouse-support`
- Adds mouse button handling.
- Supports left-click item selection.
- Supports middle-click paste.
- Supports right-click exit.
- Supports scroll wheel navigation.
- Adds `ButtonPressMask` to the dmenu window event mask.

Relevant source locations:

- `install/dmenu/dmenu.c`
- `install/dmenu/config.def.h`
- `install/dmenu/config.mk`
- `install/dmenu/dmenu.1`

### Configuration Changes

- Font changed to `JetBrainsMono Nerd Font:size=11`.
- Colors changed to a Dracula-style palette.
- Fuzzy matching is enabled by default.
- Centered mode is enabled by default.
- Minimum centered width is set to `500`.
- Default vertical list length changed from `0` to `10` lines.
- Default border width is set to `1`.
