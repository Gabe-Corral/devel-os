# DevelOS Roadmap

This is the loose roadmap for turning DevelOS from a custom Arch ISO into a complete Arch-based distribution.

## Distribution

- [x] Stop copying/building custom software manually; package `dwm`, `dmenu`, and `dwmblocks-async` with `PKGBUILD`s.
- [x] Create a small DevelOS pacman repository and install DevelOS packages from it during ISO builds and system installs.
- [x] Package shared and live-only DevelOS configs instead of copying them from `airootfs`.
- [x] Package the installer instead of copying it from `airootfs`.
- [x] Split live ISO packages from installed system packages so the installed OS stays clean.
- [x] Add Calamares for graphical system installs while keeping the CLI installer as a fallback.
- [x] Add DevelOS release/branding files such as `os-release`, bootloader branding, and default system metadata.
- [ ] Add automated ISO build and QEMU install tests before publishing releases.

## DWM Runtime Configuration

The goal is to make DevelOS' `dwm` easier to customize without manually editing C and running `make install` by hand.

The rough shape is a `dwmctl` tool plus small `dwm` changes:

- `dwmctl` edits user config.
- `dwmctl` generates `config.h` from safer config data.
- `dwmctl` rebuilds a user-local `dwm` binary.
- `dwm` can restart/reexec cleanly when asked.
- Existing windows should stay alive across restart.

### Implementation

- [ ] Add restart/reexec support to `dwm`, probably through `SIGHUP`.
- [ ] Update `start-dwm` to prefer `~/.local/bin/dwm` and fall back to `/usr/bin/dwm`.
- [ ] Package rebuildable `dwm` source under `/usr/share/develos/suckless/dwm`.
- [ ] Add `dwmctl rebuild` to compile a user-local `~/.local/bin/dwm`.
- [ ] Add `dwmctl restart` to restart the running `dwm` session without killing X clients.
- [ ] Add `dwmctl apply` to generate config, rebuild, and restart in one step.
- [ ] Add a basic TUI for common rebuild-required settings like `gappx`, `borderpx`, fonts, colors, terminal, and dmenu command.
- [ ] Add keybinding editing through a safe generated config layer instead of raw C editing.
- [ ] Add duplicate keybinding detection before writing generated config.
- [ ] Add reset support to remove user overrides and return to packaged defaults.
- [ ] Add basic state preservation for selected tag, layout, `mfact`, and `nmaster`.
- [ ] Add deeper state restore for per-window tags, floating state, geometry, and focus if the basic restart flow proves reliable.

### Keybinding

Keybindings require a rebuild in `dwm`, but they should still be editable through `dwmctl`.

Instead of editing `config.h` directly, `dwmctl` should store user keybindings in a structured file such as:

```text
~/.config/develos/dwm/settings.toml
```

Example shape:

```toml
[[key]]
mod = "Mod1"
key = "p"
action = "spawn"
command = "launcher"

[[key]]
mod = "Mod1|Shift"
key = "Return"
action = "spawn"
command = "terminal"

[commands]
launcher = ["dmenu_run"]
terminal = ["alacritty"]
```

`dwmctl` would validate this and generate the C `Key keys[]` array.

First supported keybinding features:

- Edit existing DevelOS default bindings.
- Change modifier.
- Change key.
- Enable or disable a binding.
- Reset a binding to default.
- Detect conflicts like two actions using `Mod-p`.

Later keybinding features:

- Add fully custom spawn commands.
- Add custom action bindings.
- Export/import keybinding profiles.

## Calamares

- [x] Add Calamares to the live ISO.
- [x] Add `develos-calamares-config` package.
- [x] Use package-based install through `pacstrap` instead of squashfs unpacking.
- [x] Keep Calamares live-only so it is not installed on the target system.
- [x] Document the Calamares integration in `docs/calamares.md`.
- [ ] Continue testing the Calamares install path on real hardware and QEMU.
- [ ] Build/host a DevelOS-owned Calamares package.
- [ ] Automatically detect hardware and recommend/install drivers (include in Python install script).
