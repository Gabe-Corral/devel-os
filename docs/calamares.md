# Calamares Integration

This document explains how Calamares is leveraged in DevelOS right now. The goal is to make future changes easier without having to rediscover why each file exists.

The current direction is **package-based installation**. Calamares partitions and mounts the target disk, then DevelOS runs `pacstrap` with the same installed-system package manifest used by the CLI installer. We are not copying the live ISO squashfs into the target system.

## Package Flow

Calamares is installed only into the live ISO.

Relevant manifest:

```text
archiso/packages.live.x86_64
```

This includes:

```text
calamares
develos-calamares-config
kpmcore
qt6-base
qt6-declarative
qt6-svg
```

These packages should stay out of:

```text
archiso/packages.installed.x86_64
```

That installed manifest is what the target system gets. Keeping Calamares out of it avoids installing live-only installer tools onto the final system.

## Package Build Hook

File:

```text
scripts/build-packages.sh
```

This script builds all local DevelOS packages. For `develos-installer`, it also copies:

```text
archiso/packages.installed.x86_64
```

into the package source at:

```text
usr/share/develos/packages.installed.x86_64
```

That is intentional. Calamares and the CLI installer should use the same installed package list instead of maintaining separate lists. `develos-installer` owns this manifest file; `develos-calamares-config` reads it but does not package another copy.

If the installed package set changes later, edit:

```text
archiso/packages.installed.x86_64
```

Then rebuild packages so the copied manifest inside `develos-installer` is refreshed.

## Main Calamares Package

Package directory:

```text
packages/develos-calamares-config/
```

This package owns the DevelOS Calamares config, helper script, branding, and live-user polkit rule.

### `PKGBUILD`

File:

```text
packages/develos-calamares-config/PKGBUILD
```

This defines the `develos-calamares-config` package.

It does not hard-depend on `calamares` in the PKGBUILD. Calamares itself is listed in `archiso/packages.live.x86_64`. This avoids `makepkg -s` trying to install Calamares on the build host just to build a config package.

The package copies everything from `files/` into the package root and marks this helper executable:

```text
usr/lib/develos/calamares-pacstrap
```

### Install Hook

File:

```text
packages/develos-calamares-config/develos-calamares-config.install
```

The actual Calamares config is stored under:

```text
/usr/share/develos/calamares/etc/calamares/
```

The install hook copies it into:

```text
/etc/calamares/
```

This avoids direct package file conflicts if the upstream `calamares` package ships files or examples under `/etc/calamares`.

If Calamares is not seeing your config in the live ISO, this install hook is one of the first places to check.

The package also installs:

```text
/usr/lib/develos/sync-calamares-config
```

The ISO customization step runs this script after package installation. This matters because the Manjaro `calamares` package ships its own runtime config under `/usr/share/calamares`; the sync script overwrites the runtime config and branding with DevelOS files so Calamares does not accidentally load Manjaro branding.

## Calamares Settings

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/settings.conf
```

This is the top-level Calamares flow.

The important part is the install sequence:

```text
partition
mount
shellprocess
machineid
fstab
locale
keyboard
localecfg
users
displaymanager
networkcfg
hwclock
umount
```

The `shellprocess` step is where DevelOS installs packages into the target using `pacstrap`.

There is no `unpackfs` step anymore. That is deliberate. We are not copying the live ISO into the installed system.

## Package-Based Install Helper

File:

```text
packages/develos-calamares-config/files/usr/lib/develos/calamares-pacstrap
```

This script is called by Calamares during the `shellprocess` step.

It expects Calamares to pass the mounted target root as the first argument. It then reads:

```text
/usr/share/develos/packages.installed.x86_64
```

and runs:

```bash
pacstrap -K -C /etc/pacman.conf "$target" "${packages[@]}"
```

After `pacstrap`, it copies the local DevelOS repo into the target:

```text
/opt/develos/repo
```

It also copies the live `/etc/pacman.conf` into the target so the installed system knows about the local DevelOS repo.

The helper also enables installed-system services that the CLI installer enables:

```bash
systemctl enable NetworkManager.service
systemctl enable ly@tty1.service
```

If the installed system boots to a plain TTY instead of Ly, check this helper first.

If Calamares gets through partitioning but fails during install, this script is the main thing to inspect.

## Shellprocess Module

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/shellprocess.conf
```

This tells Calamares to run:

```text
/usr/lib/develos/calamares-pacstrap ${ROOT}
```

`${ROOT}` is replaced by Calamares with the mounted target root.

`dontChroot: true` is set because the helper needs to run from the live system and call `pacstrap` into the target, not run from inside the target.

## Module Configs

These files are minimal starting points. Expect to tune them during real install testing.

### Bootloader

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/bootloader.conf
```

This currently tells Calamares to use GRUB as the EFI bootloader.

If Calamares installs but the machine drops to a GRUB shell, this file and the Calamares bootloader module logs are the first things to check.

Note: the Calamares `bootloader` module is currently not in the install sequence. DevelOS installs GRUB from `calamares-pacstrap` instead, using `--no-nvram` and `--removable`. This avoids failures in QEMU/OVMF and firmware setups where EFI variables are not writable from the live environment.

### Display Manager

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/displaymanager.conf
```

This points the installed system at `ly`.

The Calamares `displaymanager` module is configured with `basicSetup: true`, but the DevelOS helper also explicitly enables `ly@tty1.service` so the package-based install path stays aligned with the CLI installer.

### Locale

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/locale.conf
```

This sets the default region/timezone shown by Calamares. It is only a default; the user can still choose another timezone in the UI.

### Partitioning

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/partition.conf
```

This controls partition UI behavior and the EFI mount point. Right now the Calamares path uses:

```text
/boot/efi
```

This may differ from the CLI installer, which has historically mounted the ESP at `/boot`. If bootloader behavior is inconsistent, this difference is worth revisiting.

### Users

File:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/modules/users.conf
```

This sets default user groups and enables setting a root password. The important installed-user group is:

```text
wheel
```

That matches the sudo setup used elsewhere in DevelOS.

## Branding

Directory:

```text
packages/develos-calamares-config/files/usr/share/develos/calamares/etc/calamares/branding/develos/
```

Files:

```text
branding.desc
show.qml
develos-icon.svg
develos-logo.svg
```

`branding.desc` names the installer as DevelOS and sets simple Dracula-ish sidebar colors.

`develos-icon.svg` and `develos-logo.svg` are required because Calamares expects a valid branding icon. If these are missing or the paths in `branding.desc` are wrong, Calamares can fail with an `!icon.isNull()` branding error.

`show.qml` is a minimal slideshow screen that says "Installing DevelOS". It is intentionally simple for now. Replace this later if you want a nicer installer slideshow.

## Polkit Rule

File:

```text
packages/develos-calamares-config/files/etc/polkit-1/rules.d/49-develos-calamares.rules
```

This lets the live user `devel` run Calamares through `pkexec` without fighting authentication prompts.

It is intentionally scoped to:

```text
/usr/bin/calamares
```

Do not broaden this rule to allow arbitrary `pkexec` commands unless you intentionally want a less locked-down live ISO.

## Files Removed From The Earlier Plan

These module files were intentionally removed:

```text
unpackfs.conf
packages.conf
```

`unpackfs.conf` was removed because DevelOS is using package-based installation, not squashfs copy installation.

`packages.conf` was removed because the package install is handled by the DevelOS `shellprocess` helper, not Calamares' built-in package operation list.

## Testing Phase 1

Phase 1 is only about launching Calamares and confirming the UI loads. Do not install yet.

Build and boot the ISO:

```bash
./scripts/build-iso.sh
./scripts/run-qemu.sh output/<iso-name>.iso
```

Then launch Calamares from a terminal:

```bash
pkexec /usr/bin/calamares
```

For phase 1, check:

- Calamares opens.
- It says DevelOS, not a generic distro name.
- The welcome, locale, keyboard, partition, users, and summary pages load.
- No module config error appears before the install step.

## Testing Phase 2

Phase 2 is the actual install test.

Use the QEMU install helper:

```bash
./scripts/run-qemu-install.sh output/<iso-name>.iso vm/develos.qcow2
```

After install, confirm:

- The installed system boots.
- GRUB shows DevelOS.
- The created user can log in.
- Ly starts.
- The dwm session launches.
- Live-only packages are not installed on the target.

Useful target checks:

```bash
pacman -Q calamares develos-calamares-config develos-live-config develos-installer
```

Those should not be installed on the final system.

## Future Changes

Common edits later will probably be:

- Change installed packages: edit `archiso/packages.installed.x86_64`.
- Change live-only Calamares packages: edit `archiso/packages.live.x86_64`.
- Change install flow: edit `settings.conf`.
- Change the package install command: edit `calamares-pacstrap`.
- Change default user groups: edit `users.conf`.
- Change partition defaults: edit `partition.conf`.
- Change branding: edit `branding.desc` and `show.qml`.
- Change launcher behavior: add a desktop file under `usr/share/applications` and review the polkit rule at the same time.

After changing any package files, rebuild packages before rebuilding the ISO:

```bash
./scripts/build-packages.sh -s --noconfirm
./scripts/build-iso.sh
```
