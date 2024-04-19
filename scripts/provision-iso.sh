#!/usr/bin/env bash

set -e

DISK=/dev/vda
BIOSBOOT_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"

parted $DISK mklabel gpt \
  mkpart biosboot ext4 1MiB 2MiB \
  set 1 bios_grub on \
  mkpart root ext4 2MiB 100% \
  type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709 # Linux root (x86-64)

mkfs.ext4 $ROOT_PARTITION
mount $ROOT_PARTITION /mnt

curl -L \
  'https://archlinux.org/mirrorlist/?country=GB&protocol=https&ip_version=4&use_mirror_status=on' \
  | sed 's/#Server/Server/' > /etc/pacman.d/mirrorlist

pacstrap -K /mnt base linux grub openssh sudo python

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt bash -c "curl -sL ${PACKER_HTTP_ADDR}/provision-iso-chroot.sh | DISK=$DISK bash"

umount -R /mnt
