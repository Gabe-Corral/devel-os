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

Arch-derived hosts are supported through the containerized build path. Local DevelOS packages and external live-only packages are built inside an Arch container so host distribution packages do not leak into the ISO.

## Build The ISO

From the repository root:

```bash
make iso
```

The build script does the following:

- Copies `archiso/packages.live.x86_64` to `archiso/packages.x86_64` for `mkarchiso`.
- Builds local DevelOS packages from `packages/` and `install/`.
- Builds external live-only `calamares` and `ckbcomp` packages from AUR PKGBUILDs inside the Arch container.
- Creates a local pacman repo under `archiso/airootfs/opt/develos/repo`.
- Builds the ISO inside a Podman Arch container.
- Writes the ISO to `output/`.

## Package-Only Build

To rebuild local package artifacts without building a full ISO:

```bash
make packages
```

Use this after changing files under `packages/` or source trees under `install/`.

## Local Repo Build

To recreate the local pacman repo under `archiso/airootfs/opt/develos/repo` from already-built package artifacts:

```bash
make repo
```

## Live Boot Test

After building an ISO, boot the live environment with:

```bash
make qemu-live ISO=output/<iso-name>.iso
```

If `ISO` is omitted, the newest ISO under `output/` is used. This only tests whether the ISO boots. It does not test installation.

For a non-interactive live boot smoke test, run:

```bash
sudo make test-live ISO=output/<iso-name>.iso
```

If `ISO` is omitted, the newest ISO under `output/` is used. See [Testing](testing.md) for details and troubleshooting.

## Full Install Test

To boot the ISO, install to a virtual disk, and then boot that installed disk:

```bash
./scripts/run-qemu-install.sh output/<iso-name>.iso vm/develos.qcow2
```

The helper uses UEFI/OVMF and resets the VM firmware vars for each run so old boot entries do not pollute install testing.

## Useful Files

- `Makefile`: primary build entry point for ISO, package, repo, and QEMU live targets.
- `scripts/build-iso.sh`: ISO build orchestration.
- `scripts/build-packages.sh`: local package build pipeline.
- `scripts/build-repo.sh`: local pacman repo creation.
- `scripts/common.sh`: shared shell helpers.
- `scripts/test-live.sh`: live ISO smoke test runner.
- `archiso/packages.live.x86_64`: packages included in the live ISO.
- `archiso/packages.installed.x86_64`: packages installed onto target systems.
- `packages/`: DevelOS PKGBUILDs and package-owned files.
- `install/`: vendored suckless source trees used by package builds.
