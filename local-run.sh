#!/usr/bin/env bash

shopt -s nullglob

export VAGRANT_DEFAULT_PROVIDER=${1:-libvirt}
LOCAL_BOXES="jumperfly-local/archlinux jumperfly-local/ansible"

vagrant destroy

for box in $LOCAL_BOXES; do
  box_id=${box/\//-VAGRANTSLASH-}
  if [[ -d "$HOME/.vagrant.d/boxes/$box_id/0" ]]; then
    vagrant box remove $box --all-providers
    for img in /var/lib/libvirt/images/${box_id}_*.img; do
      virsh vol-delete $img
    done
  fi
done

vagrant up
