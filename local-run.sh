#!/usr/bin/env bash

vagrant destroy
if [[ -d "$HOME/.vagrant.d/boxes/jumperfly-local-VAGRANTSLASH-archlinux/0" ]]; then
  vagrant box remove jumperfly-local/archlinux
  for img in /var/lib/libvirt/images/jumperfly-local-VAGRANTSLASH-archlinux_*.img; do
    virsh vol-delete $img
  done
fi
vagrant up
