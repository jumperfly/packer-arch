#!/usr/bin/env bash

vagrant destroy
if [[ -d "$HOME/.vagrant.d/boxes/jumperfly-VAGRANTSLASH-arch/0" ]]; then
  vagrant box remove jumperfly/arch --box-version 0
  for img in /var/lib/libvirt/images/jumperfly-VAGRANTSLASH-arch*_box_0.img; do
    virsh vol-delete $img
  done
fi
vagrant up
