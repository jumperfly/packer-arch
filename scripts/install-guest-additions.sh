#!/bin/sh

set -e

if [[ $PACKER_BUILDER_TYPE == "virtualbox-ovf" ]]; then
  echo "Installing virtualbox guest additions"
  pacman -Sy --noconfirm virtualbox-guest-utils-nox
  systemctl enable vboxservice
fi
