#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path


MOUNT = Path("/mnt")


def run(cmd, check=True):
    subprocess.run(cmd, check=check)


def require_root():
    if os.geteuid() != 0:
        raise SystemExit("You must run the installer as root.")


def gather_info():
    info = {}

    info["disk"] = input("DISK: ").strip()
    info["hostname"] = input("HOSTNAME: ").strip()
    info["username"] = input("USERNAME: ").strip()
    info["timezone"] = input("TIMEZONE [America/Chicago]: ").strip() or "America/Chicago"

    if not info["disk"]:
        raise SystemExit("Disk is required.")

    if not info["hostname"]:
        raise SystemExit("Hostname is required.")

    if not info["username"]:
        raise SystemExit("Username is required.")

    return info


def confirm_install(info):
    print("\nWARNING: This will erase the selected disk.\n")
    print(f"Disk:     {info['disk']}")
    print(f"Hostname: {info['hostname']}")
    print(f"Username: {info['username']}")
    print(f"Timezone: {info['timezone']}")

    confirm = input("Type INSTALL to continue: ").strip()

    if confirm != "INSTALL":
        raise SystemExit("Install cancelled.")


def part(disk, number):
    if disk[-1].isdigit():
        return f"{disk}p{number}"

    return f"{disk}{number}"


def partition_disk(info):
    disk = info["disk"]

    run(["parted", "-s", disk, "mklabel", "gpt"])
    run(["parted", "-s", disk, "mkpart", "ESP", "fat32", "1MiB", "513MiB"])
    run(["parted", "-s", disk, "set", "1", "esp", "on"])
    run(["parted", "-s", disk, "mkpart", "primary", "ext4", "513MiB", "100%"])


def format_partitions(info):
    efi = part(info["disk"], 1)
    root = part(info["disk"], 2)

    run(["mkfs.fat", "-F32", efi])
    run(["mkfs.ext4", "-F", root])


def mount_partitions(info):
    efi = part(info["disk"], 1)
    root = part(info["disk"], 2)

    run(["mount", root, str(MOUNT)])
    (MOUNT / "boot").mkdir(parents=True, exist_ok=True)
    run(["mount", efi, str(MOUNT / "boot")])


def install_base():
    packages = [
        "base",
        "base-devel",
        "linux",
        "linux-headers",
        "linux-firmware",
        "syslinux",
        "mkinitcpio",
        "mkinitcpio-archiso",
        "squashfs-tools",
        "edk2-shell",
        "sudo",
        "pacman",
        "systemd",
        "grub",
        "efibootmgr",
        "dosfstools",
        "e2fsprogs",
        "parted",
        "gptfdisk",
        "arch-install-scripts",
        "networkmanager",
        "iwd",
        "dhcpcd",
        "openssh",
        "curl",
        "wget",
        "man-db",
        "bash",
        "xorg-server",
        "xorg-xinit",
        "libx11",
        "libxft",
        "libxinerama",
        "freetype2",
        "fontconfig",
        "polkit",
        "btrfs-progs",
        "xfsprogs",
        "ntfs-3g",
        "exfatprogs",
        "xf86-video-qxl",
        "xf86-video-vesa",
        "mesa",
        "tmux",
        "make",
        "gcc",
        "cmake",
        "ly",
        "alacritty",
        "neovim",
        "vi",
        "htop",
        "firefox",
        "ttf-jetbrains-mono-nerd",
        "noto-fonts-emoji",
        "thunar",
        "thunar-volman",
        "gtk3",
        "papirus-icon-theme",
        "lxappearance",
        "python",
        "python-pip",
        "uv",
        "opencode",
        "zed",
    ]

    run(["pacstrap", "-K", str(MOUNT), *packages])

    with open(MOUNT / "etc/fstab", "a") as f:
        subprocess.run(["genfstab", "-U", str(MOUNT)], stdout=f, check=True)


def install_skel():
    src = Path("/etc/skel")
    dst = MOUNT / "etc/skel"

    if src.exists():
        dst.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(src) + "/.", str(dst)])


def install_ly(info):
    username = info["username"]
    config_src = Path("/etc/ly/config.ini")
    config_dst = MOUNT / "etc/ly/config.ini"
    override_src = Path("/etc/systemd/system/ly@tty1.service.d/override.conf")
    override_dst = MOUNT / "etc/systemd/system/ly@tty1.service.d/override.conf"

    if config_src.exists():
        config_dst.parent.mkdir(parents=True, exist_ok=True)
        config = config_src.read_text()
        config = config.replace("auto_login_user = devel", f"auto_login_user = {username}")
        config_dst.write_text(config)

    if override_src.exists():
        override_dst.parent.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(override_src), str(override_dst)])


def install_firefox_distribution():
    src = Path("/usr/lib/firefox/distribution")
    dst = MOUNT / "usr/lib/firefox/distribution"

    if src.exists():
        dst.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(src) + "/.", str(dst)])


def install_xsession():
    start_dwm_src = Path("/usr/local/bin/start-dwm")
    start_dwm_dst = MOUNT / "usr/local/bin/start-dwm"

    if start_dwm_src.exists():
        start_dwm_dst.parent.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(start_dwm_src), str(start_dwm_dst)])
        run(["chmod", "+x", str(start_dwm_dst)])

    desktop_src = Path("/usr/share/xsessions/dwm.desktop")
    desktop_dst = MOUNT / "usr/share/xsessions/dwm.desktop"

    if desktop_src.exists():
        desktop_dst.parent.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(desktop_src), str(desktop_dst)])


def install_dwmblocks_scripts():
    scripts = [
        "/usr/local/bin/dwmblocks-memory.sh",
        "/usr/local/bin/dwmblocks-cpu.sh",
        "/usr/local/bin/dwmblocks-datetime.sh",
    ]

    for path in scripts:
        src = Path(path)
        dst = MOUNT / "usr/local/bin" / src.name

        if src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            run(["cp", "-a", str(src), str(dst)])
            run(["chmod", "+x", str(dst)])


def install_themes():
    src = Path("/usr/share/themes")
    dst = MOUNT / "usr/share/themes"

    if src.exists():
        dst.mkdir(parents=True, exist_ok=True)
        run(["cp", "-a", str(src) + "/.", str(dst)])


def install_suckless_sources():
    src = Path("/opt/devel-os")
    dst = MOUNT / "opt/devel-os"

    if src.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        # copy entire tree
        run(["cp", "-a", str(src), str(dst.parent)])


def run_chroot(script):
    subprocess.run(
        ["arch-chroot", str(MOUNT), "/bin/bash"],
        input=script,
        text=True,
        check=True,
    )


def configure_system(info):
    hostname = info["hostname"]
    username = info["username"]
    timezone = info["timezone"]

    script = f"""
set -e

ln -sf /usr/share/zoneinfo/{timezone} /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "{hostname}" > /etc/hostname

cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 {hostname}.localdomain {hostname}
EOF

useradd -m -G wheel -s /bin/bash {username}

# copy default dotfiles and other skel content into the new user's home
cp -a /etc/skel/. "/home/{username}/"
chown -R "{username}:{username}" "/home/{username}"

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

systemctl enable NetworkManager
systemctl enable ly@tty1.service

if grep -q '^GRUB_DISTRIBUTOR=' /etc/default/grub; then
    sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="DevelOS"/' /etc/default/grub
else
    echo 'GRUB_DISTRIBUTOR="DevelOS"' >> /etc/default/grub
fi

# build and install dwm, dmenu, and dwmblocks-async from /opt/devel-os
rebuild_suckless() {{
    local dir="$1"
    cd "$dir" || return 1
    make clean install
}}

rebuild_suckless /opt/devel-os/dwm
rebuild_suckless /opt/devel-os/dmenu
rebuild_suckless /opt/devel-os/dwmblocks-async

# attempt to install GRUB; if EFI NVRAM entry creation fails, try --removable
set +e
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=DevelOS
grub_rc=$?
if [ "$grub_rc" -ne 0 ]; then
    echo "WARNING: grub-install failed with status $grub_rc, retrying with --removable" >&2
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=DevelOS --removable
    grub_rc=$?
fi

if [ "$grub_rc" -ne 0 ]; then
    echo "ERROR: grub-install failed; system may not boot without manual bootloader setup." >&2
    exit "$grub_rc"
fi

set -e
grub-mkconfig -o /boot/grub/grub.cfg
test -s /boot/grub/grub.cfg

mkdir -p /boot/EFI/DevelOS /boot/EFI/BOOT
for grub_efi_cfg in /boot/EFI/DevelOS/grub.cfg /boot/EFI/BOOT/grub.cfg; do
    cat > "$grub_efi_cfg" <<'EOF'
search --no-floppy --file --set=root /grub/grub.cfg
set prefix=($root)/grub
configfile /grub/grub.cfg
EOF
done
"""

    run_chroot(script)


def set_passwords(info):
    username = info["username"]

    print("\nSet ROOT password:")
    run(["arch-chroot", str(MOUNT), "passwd"])

    print(f"\nSet password for {username}:")
    run(["arch-chroot", str(MOUNT), "passwd", username])

    # chpasswd_input = f"{username}:password"
    # command = ["arch-chroot", str(MOUNT), "chpasswd"]

    # try:
    #     subprocess.run(
    #         command,
    #         input=chpasswd_input,
    #         text=True,
    #         check=True
    #     )
    #     print(f"Password for user '{username}' set successfully.")
    # except subprocess.CalledProcessError as e:
    #     print(f"Failed to set password: {e}")


def main():
    require_root()

    info = gather_info()
    confirm_install(info)

    run(["timedatectl", "set-ntp", "true"])

    partition_disk(info)
    format_partitions(info)
    mount_partitions(info)
    install_base()
    install_skel()
    install_ly(info)
    install_firefox_distribution()
    install_xsession()
    install_dwmblocks_scripts()
    install_themes()
    install_suckless_sources()
    configure_system(info)
    set_passwords(info)

    print("\nInstall complete. You can now reboot.")


if __name__ == "__main__":
    main()
