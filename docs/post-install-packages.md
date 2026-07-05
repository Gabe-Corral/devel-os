# Post-Install Packages and Configuration

This document lists the non-essential user-facing packages included in an installed DevelOS system and the default configuration applied after install.

Core boot, kernel, package manager, base system, filesystem, networking, firmware, audio, Xorg, and driver packages are intentionally omitted here. The full installed manifest is `archiso/packages.installed.x86_64`.

## Installed User Packages

### Desktop Session

- `develos-dwm`: patched `dwm` window manager used as the default session.
- `develos-dmenu`: patched `dmenu` launcher.
- `develos-dwmblocks-async`: status bar blocks for `dwm`.
- `ly`: TTY display manager used to launch the `dwm` session.
- `alacritty`: default terminal emulator.
- `dunst`: notification daemon started by `start-dwm`.
- `feh`: wallpaper setter used by `start-dwm`.
- `xsettingsd`: applies GTK theme, icon, and font settings in the `dwm` session.

### Editors and Development Tools

- `neovim`: terminal editor with a default Lazy.nvim configuration.
- `zed`: graphical editor with Dracula theme assets and Vim mode enabled.
- `tmux`: terminal multiplexer with Dracula-style status colors.
- `git`: source control.
- `make`, `gcc`, `cmake`, `base-devel`: build tooling.
- `python`, `python-pip`, `uv`: Python tooling.
- `opencode`: AI coding tool.

### Graphical Applications and Utilities

- `firefox`: browser with a DevelOS policy file.
- `thunar`: graphical file manager.
- `thunar-volman`: removable media integration for Thunar.
- `lxappearance`: GTK theme configuration utility.
- `pavucontrol`: graphical PulseAudio/PipeWire volume control.
- `htop`: process monitor.

### Networking

- `networkmanager`: network management daemon used for Ethernet and Wi-Fi.
- `nmcli`: command-line NetworkManager client for connecting to Wi-Fi and managing saved connections.

### Appearance

- `ttf-jetbrains-mono-nerd`: default monospace/UI font.
- `noto-fonts-emoji`: emoji font support.
- `papirus-icon-theme`: icon theme, configured as `Papirus-Dark`.
- `gtk3`: GTK runtime and settings support for themed graphical apps.
- Dracula GTK theme: shipped by `develos-config` under `/usr/share/themes/Dracula`.
- DevelOS wallpapers: shipped by `develos-config` under `/usr/share/develos/backgrounds`.

## Live-Only Packages

These packages are included on the ISO but should not be installed to the target system through the installed package manifest:

- `calamares`: graphical installer.
- `develos-calamares-config`: Calamares branding and installer configuration.
- `develos-installer`: CLI installer scripts.
- `develos-live-config`: live-session configuration.
- `mkinitcpio-archiso`, `squashfs-tools`, `syslinux`, `edk2-shell`: ISO boot/build support.
- `arch-install-scripts`, `hwinfo`, `kpmcore`, `ckbcomp`: installer support.
- `qt6-base`, `qt6-declarative`, `qt6-svg`, `vulkan-swrast`: Calamares/runtime support on the live ISO.

## Configuration Applied By `develos-config`

The `develos-config` package installs system files and copies `/usr/share/develos/skel` into `/etc/skel` during install and upgrade. New users created after installation inherit these defaults.

### Session Startup

- `/usr/share/xsessions/dwm.desktop` registers `dwm` as a display-manager session.
- `~/.xinitrc` executes `/usr/local/bin/start-dwm`.
- `/usr/local/bin/start-dwm` starts the wallpaper, `xsettingsd`, `dunst`, and `dwmblocks`, then execs `/usr/bin/dwm`.
- Wallpaper defaults to `/usr/share/develos/backgrounds/wallpaper_1.png` through `feh --bg-fill`.

### Ly Login Manager

- `develos-config` syncs `/usr/share/develos/ly/config.ini` into Ly's configuration.
- Ly is configured for auto-login as user `devel`.
- Ly uses Dracula-style foreground/background colors.
- `ly@tty1.service` has an override that sets the TTY palette before Ly starts.

### GTK and Theme Defaults

- GTK theme: `Dracula`.
- Icon theme: `Papirus-Dark`.
- Font: `JetBrainsMono Nerd Font 10`.
- Dark theme preference is enabled.
- The same values are mirrored in `~/.xsettingsd` for X11 applications.

### Neovim

Neovim uses `~/.config/nvim/init.lua` from the skeleton config.

- Bootstraps `lazy.nvim` automatically on first launch.
- Installs and enables `Mofiqul/dracula.nvim`.
- Includes Telescope with leader mappings for files, grep, buffers, and help.
- Includes Treesitter highlighting and indentation.
- Includes `nvim-lspconfig` with basic LSP keybindings.
- Includes `which-key.nvim` and `oil.nvim`.
- Sets common editor defaults: line numbers, true color, two-space indentation, smart search, and persistent sign column.

### Zed

Zed uses `~/.config/zed/settings.json` and a bundled Dracula theme file.

- Vim mode is enabled.
- UI and buffer font size are set to `16`.
- Light theme is `Dracula`; dark theme is `One Dark`.
- Preview tabs are disabled.
- Font ligatures and contextual alternates are disabled.

### Alacritty

Alacritty uses `~/.config/alacritty/alacritty.toml`.

- Dracula color palette.
- `TERM` is set to `xterm-256color`.

### tmux

tmux uses `~/.tmux.conf`.

- True color support is enabled.
- Mouse support is enabled.
- Copy mode uses vi keys.
- Status bar, messages, and pane borders use Dracula colors.

### Firefox

Firefox policy defaults are installed at `/usr/lib/firefox/distribution/policies.json`.

- Homepage and startup page default to `about:blank`.
- New tab page, Pocket, Firefox Studies, telemetry, default bookmarks, Firefox View, and Firefox account sign-in are disabled.
- Default-browser checks and first-run pages are disabled.
- `about:config` warning is disabled.
- `uBlock Origin` is force-installed.
- Dracula dark colorscheme extension is force-installed.

### Shell

- `~/.bashrc` sets a Dracula-colored prompt.
- `~/.bashrc` prepends `/home/gabe/.opencode/bin` to `PATH`.

## Source Files

- Installed package manifest: `archiso/packages.installed.x86_64`.
- Live ISO package manifest: `archiso/packages.x86_64`.
- DevelOS defaults: `packages/develos-config/files`.
- User skeleton files: `packages/develos-config/files/usr/share/develos/skel`.
