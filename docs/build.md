# Building DevelOS

This document covers building the DevelOS live ISO and boot-testing it in QEMU.

## Requirements

Build from an Arch Linux or Arch-derived host with:

- `podman`
- `base-devel`
- `pacman-contrib` for `repo-add`
- `qemu` or `qemu-full` for testing
- OVMF firmware for UEFI install testing

On Arch, the rough package set is:

```bash
sudo pacman -S --needed base-devel pacman-contrib podman qemu-full edk2-ovmf
```

Manjaro is supported as a host through the containerized build path. The build still uses the host `pacman` to stage the Manjaro `calamares` and `ckbcomp` packages into the local DevelOS repo because those packages are not available from Arch's official repos.

## Build The ISO

From the repository root:

```bash
./scripts/build-iso.sh
```

The build script does the following:

- Copies `archiso/packages.live.x86_64` to `archiso/packages.x86_64` for `mkarchiso`.
- Builds local DevelOS packages from `packages/` and `install/`.
- Stages external `calamares` and `ckbcomp` packages from the host pacman repos.
- Creates a local pacman repo under `archiso/airootfs/opt/develos/repo`.
- Builds the ISO inside a Podman Arch container.
- Writes the ISO to `output/`.

## Package-Only Build

To rebuild local package artifacts without building a full ISO:

```bash
./scripts/build-packages.sh -s --noconfirm
```

Use this after changing files under `packages/` or source trees under `install/`.

## Live Boot Test

After building an ISO, boot the live environment with:

```bash
./scripts/run-qemu.sh output/<iso-name>.iso
```

This only tests whether the ISO boots. It does not test installation.

## Full Install Test

To boot the ISO, install to a virtual disk, and then boot that installed disk:

```bash
./scripts/run-qemu-install.sh output/<iso-name>.iso vm/develos.qcow2
```

The helper uses UEFI/OVMF and resets the VM firmware vars for each run so old boot entries do not pollute install testing.

## Useful Files

- `scripts/build-iso.sh`: full ISO build pipeline.
- `scripts/build-packages.sh`: local package build pipeline.
- `archiso/packages.live.x86_64`: packages included in the live ISO.
- `archiso/packages.installed.x86_64`: packages installed onto target systems.
- `packages/`: DevelOS PKGBUILDs and package-owned files.
- `install/`: vendored suckless source trees used by package builds.
