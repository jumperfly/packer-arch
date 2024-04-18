#!/usr/bin/env bash

set -e

# Install vagrant insecure key
curl -Lo /home/vagrant/.ssh/id_ed25519 https://raw.githubusercontent.com/hashicorp/vagrant/v2.4.1/keys/vagrant.key.ed25519
chown vagrant:vagrant /home/vagrant/.ssh/id_ed25519
chmod 600 /home/vagrant/.ssh/id_ed25519

# Install ansible
pacman -Sy --noconfirm ansible
echo "ANSIBLE_VERSION: $(pacman -Q ansible | awk '{ print $2 }')"
echo "ANSIBLE_CORE_VERSION: $(pacman -Q ansible-core | awk '{ print $2 }')"

# Configure hostname
echo 'arch-ansible' > /etc/hostname
