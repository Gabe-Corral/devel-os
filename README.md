DevelOS
=======

DevelOS is a custom Arch Linux based development environment, built as a reproducible live ISO with a simple installer.

The long-term goal of this project is to grow into a small Arch-based distribution focused on developers, minimalism, and performance: a fast, no-frills environment with a curated set of tools and configs that stay out of your way.

![DevelOS screenshot](screenshots/devel-os.png)

This repository contains:
- An `archiso` profile used to build the ISO image.
- Configuration and source trees for tools like `dwm`, `dmenu`, and `dwmblocks-async` under `install/`.
- Helper scripts in `scripts/` to build the ISO and run it in QEMU.

Documentation
-------------

- [Build guide](docs/build.md): build packages, build the ISO, and test with QEMU.
- [Install guide](docs/install.md): install with Calamares or the CLI installer.
- [Calamares notes](docs/calamares.md): details about the graphical installer integration.
- [Roadmap](docs/roadmap.md): current distro and `dwmctl` development roadmap.
- [Suckless patches](docs/suckless-patches.md): notes on patched `dwm` and `dmenu` sources.

Building the ISO
----------------

See [docs/build.md](docs/build.md).

Running the ISO in QEMU
------------------------

See [docs/build.md](docs/build.md).

Installing DevelOS
--------------------------------

See [docs/install.md](docs/install.md).

Roadmap
-------

See [docs/roadmap.md](docs/roadmap.md).
