# Testing

This document covers local DevelOS smoke tests.

## Live ISO Smoke Test

Use `test-live` to verify that a built ISO can boot to the live system login prompt in QEMU.

```bash
sudo make test-live ISO=output/<iso-name>.iso
```

If `ISO` is omitted, the newest ISO under `output/` is used:

```bash
sudo make test-live
```

The test boots the ISO with QEMU, directly loads the ISO kernel and initramfs, and waits for the serial login prompt:

```text
develos login:
```

This is a boot smoke test only. It does not test graphical login, `dwm`, Calamares, or installation to disk.

## Requirements

- `qemu-system-x86_64`
- `blkid`
- `mount`
- `umount`
- Permission to loop-mount the ISO, which is why `sudo` is required

## Logs

Logs are written under:

```text
output/test/
```

Important files:

- `output/test/live.log`: serial boot output from the guest.
- `output/test/live-qemu.log`: QEMU stderr.
- `output/test/iso-mount`: temporary mount point for reading the ISO kernel and initramfs.

## Troubleshooting

If the test fails, inspect:

```bash
less output/test/live.log
less output/test/live-qemu.log
```

If a previous failed run leaves the ISO mount busy, the script attempts a lazy unmount automatically on the next run.
