#!/usr/bin/env bash


if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

# Check if anything is already mounted on /mnt. `mountpoint -q` is a quiet check.
if mountpoint -q /mnt; then
    echo "Error: Something is already mounted on /mnt."
    exit 1
fi

# Check if the /mnt directory is empty. `ls -A` lists all non-hidden files.
# The `-n` operator checks if the resulting string is non-empty.
if [ -n "$(ls -A /mnt)" ]; then
    echo "Error: The /mnt directory is not empty."
    exit 1
fi

# Check if exactly one argument is provided. If not, print usage info and exit.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <disk_path>"
    echo "Example: $0 /dev/nvme0n1"
    exit 1
fi

DISK="$1"

if [ ! -b "$DISK" ]; then
    echo "Error: '$DISK' does not exist or is not a block device."
    exit 1
fi

# Get the device type using lsblk
# -d: no-dependents, ensures we only get info about the specified device
# -n: no-headings
# -o TYPE: output only the TYPE column
DEVICE_TYPE=$(lsblk -dno TYPE "$DISK")

if [[ ! "$DEVICE_TYPE" == "disk" ]]; then
  echo "'$DISK' is not a disk!"
  exit 1
fi

wipefs -af $DISK
sgdisk -n 1:2MiB:+1024MiB -t 1:ef00 -c 1:EFI $DISK
sgdisk -n 2:0:0 -t 2:8309 -c 2:"luks" $DISK

cryptsetup luksFormat -q /dev/sda2 --key-file ./password.txt
cryptsetup open /dev/sda2 luksfs --key-file ./password.txt

mkfs.vfat -F32 -n EFI /dev/disk/by-partlabel/EFI
mkfs.btrfs -fL NIXOS /dev/mapper/luksfs

until [ -b /dev/disk/by-label/NIXOS ]
do
     sleep 1
done

mount -o noatime,discard,ssd,nodev /dev/disk/by-label/NIXOS /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@swap
umount /mnt

mount -o subvol=@,noatime,compress=zstd,ssd,discard=async,space_cache=v2 /dev/disk/by-label/NIXOS /mnt
mkdir -p /mnt/{boot,home,nix,var/{log,/lib/swap}}
mount -o fmask=0077,dmask=0077 /dev/disk/by-label/EFI /mnt/boot
mount -o subvol=@home,noatime,compress=zstd,ssd,discard=async /dev/disk/by-label/NIXOS /mnt/home
mount -o subvol=@log,noatime,compress=zstd,ssd,discard=async /dev/disk/by-label/NIXOS /mnt/var/log
mount -o subvol=@nix,noatime,compress=zstd,ssd,discard=async /dev/disk/by-label/NIXOS /mnt/nix
mount -o subvol=@swap,nodatacow /dev/disk/by-label/NIXOS /mnt/var/lib/swap
nixos-generate-config --root /mnt

sed -i '/swap/ b; s/"subvol/"noatime" "compress=zstd" "ssd" "discard=async" "subvol/g' /mnt/etc/nixos/hardware-configuration.nix
sed -i '/swap/ s/"subvol/"nodatacow" "subvol/g' /mnt/etc/nixos/hardware-configuration.nix

# cryptsetup luksClose /dev/mapper/luksfs
