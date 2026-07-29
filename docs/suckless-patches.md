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

- `fullgaps`
- Source: https://dwm.suckless.org/patches/fullgaps/
- Adds configurable gaps between tiled clients and around the outer monitor edges in the `tile` layout.
- Adds per-monitor gap state through `Monitor.gappx`, initialized from `gappx` in `config.def.h`.
- DevelOS currently sets `gappx` to `5`.
- Adds runtime gap controls: `Mod-minus` decreases gaps, `Mod-equal` increases gaps, and `Mod-Shift-equal` disables gaps.

Relevant source locations:

- `install/dwm/dwm.c`
- `install/dwm/config.def.h`

### Window Titlebars (custom)

Not based on an upstream patch; implemented directly in the vendored source.

- Every managed window gets a titlebar above its content: window title on the left, minimize/maximize/close buttons on the right (Nerd Font glyphs).
- The titlebar is an override-redirect child of the root window docked above the client window. Layouts compute "slot" geometry (titlebar band plus content) unchanged; only `resizeclient()` and `configure()` translate slot geometry into real X window geometry through `clientgeom()`.
- The titlebar band is `bh + border` tall. The titlebar draws the frame's top and side border segments in `ColBorder` while the client's own border wraps the rest, so one continuous border frames titlebar and content, with no border line separating them.
- Buttons act on release, and only when press and release land on the same button (`btncell` hit-testing, `btnrelease` handler).
- Dragging the titlebar past a 4px threshold moves the window via `movemouse`: tiled windows auto-float past the snap threshold, and dragging a maximized window restores it first, then moves it.
- Minimize iconifies the window with `hidewin` (`IconicState`), integrating with `awesomebar`: hidden windows keep a `SchemeHid` tab in the bar that restores them on click.
- Maximize is a toggle: it fills the monitor work area and restores the previous geometry and floating/tiled state on the second click. The button glyph switches to a restore icon while maximized. State is tracked per client with `ismax` and dedicated saved-geometry fields.
- Close sends `WM_DELETE`, falling back to `XKillClient`. The logic is shared with `killclient` through `killthis`.
- Fullscreen windows hide the titlebar; it reappears when fullscreen is left.
- Titlebars follow the focus color schemes, move and resize with their window, and stack directly above their client in `restack`.
- Size hints and resize increments apply to the content area, so terminals keep exact character-cell sizing.

Configuration values:

- `showwinbuttons` (default `1`): enables the titlebars.
- `btnright` (default `1`): places the buttons at the right end of the titlebar; `0` places them on the left.
- `btnoffset` (default `4`): gap between the buttons and the titlebar edge.
- `btnsyms[]`: button glyphs for minimize, maximize, close, and restore. Stored as UTF-8 byte escapes (`U+F2D1`, `U+F2D0`, `U+F00D`, `U+F2D2`) because editors and tooling may strip raw Private Use Area characters.

Added handlers and helpers: `minimizeclient`, `closeclient`, `killthis`, `togglemaximize`, `createbtn`, `drawbtn`, `btncell`, `btnrelease`, `wintostrip`, `clientgeom`.

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
- Tiled windows have `5px` full gaps through `gappx`.
- `Mod-minus`, `Mod-equal`, and `Mod-Shift-equal` control gaps at runtime.
- Windows have titlebars with minimize, maximize, and close buttons and drag-to-move; see Window Titlebars (custom) above.
- The bar is placed at the bottom of the screen through `topbar = 0`.

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
