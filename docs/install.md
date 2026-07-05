# Installing DevelOS

DevelOS can be installed from the live ISO in two ways:

- Graphical installer through Calamares.
- CLI installer through `develos-install`.

Use the graphical installer first for normal installs. Keep the CLI installer as the fallback path while Calamares continues to mature.

## Prepare Install Media

Build or download a DevelOS ISO, then write it to a USB drive with your preferred tool.

Examples include `dd`, `cp`, `gnome-disks`, or another image writer. Double-check the target device before writing because this will overwrite it.

Boot the target machine from the USB drive.

## Graphical Install

From the live `dwm` session, launch dmenu with:

```text
Mod-p
```

Search for and run:

```text
develos-install-gui
```

That script starts the Calamares graphical installer with `pkexec`.

If you prefer to launch it from a terminal, run:

```bash
develos-install-gui
```

Or run Calamares directly:

```bash
pkexec /usr/bin/calamares
```

Follow the Calamares prompts:

- Choose language, location, and keyboard settings.
- Select the target disk and partitioning method.
- Create the user account.
- Confirm the install summary.

Calamares uses the DevelOS installed package manifest:

```text
archiso/packages.installed.x86_64
```

The installed system should not include live-only packages like `calamares`, `develos-calamares-config`, `develos-live-config`, or `develos-installer`.

## CLI Install

If Calamares is unavailable or you want the simpler scripted path, run:

```bash
sudo develos-install
```

The CLI installer will ask for:

- Target disk. This disk will be erased.
- Hostname.
- Username.
- Timezone.
- Final confirmation.

It will then partition the disk, install the base system, configure DevelOS defaults, install GRUB, and ask you to set root and user passwords.

## After Install

Reboot into the installed system.

Expected behavior:

- GRUB boots DevelOS.
- Ly starts on `tty1`.
- The configured user can log in.
- The `dwm` session launches from Ly.
- Networking is managed by NetworkManager. See [Networking](networking.md) for `nmcli` Wi-Fi commands.

If Ly does not start, check:

```bash
systemctl status ly@tty1.service
systemctl is-enabled ly@tty1.service
```

If the system boots to a GRUB shell, the bootloader install path needs investigation. Start by checking whether the EFI partition contains the fallback loader:

```bash
ls /boot/efi/EFI/BOOT/BOOTX64.EFI
```

## VM Install Testing

For a full QEMU install test:

```bash
./scripts/run-qemu-install.sh output/<iso-name>.iso vm/develos.qcow2
```

This boots the installer ISO first. After you finish the install and shut down or reboot the guest, the script boots the installed disk.
