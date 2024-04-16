#!/usr/bin/env bash

set -e

DISK=/dev/vda
BIOSBOOT_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"

parted $DISK mklabel gpt
parted $DISK mkpart biosboot ext4 1MiB 2MiB
parted $DISK set 1 bios_grub on
parted $DISK mkpart root ext4 2MiB 100%
parted $DISK type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709 # Linux root (x86-64)

mkfs.ext4 $ROOT_PARTITION
mount $ROOT_PARTITION /mnt

curl -L \
  'https://archlinux.org/mirrorlist/?country=GB&protocol=https&ip_version=4&use_mirror_status=on' \
  | sed 's/#Server/Server/' > /etc/pacman.d/mirrorlist

pacstrap -K /mnt base linux grub openssh sudo

genfstab -U /mnt >> /mnt/etc/fstab

curl -Lo /mnt/provision-chroot.sh ${PACKER_HTTP_ADDR}/provision-chroot.sh
arch-chroot /mnt bash -c "DISK=$DISK bash /provision-chroot.sh"
rm /mnt/provision-chroot.sh

dd if=/dev/zero of=/mnt/ZERO bs=1M || echo "ignoring expected dd out of space error"
rm -f /mnt/ZERO
sync

umount -R /mnt
