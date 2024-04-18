#!/usr/bin/env bash

set -e

# Configure OS
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sed -i 's/^#\(en_GB\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_GB.UTF-8' > /etc/locale.conf
echo 'KEYMAP=uk' > /etc/vconsole.conf
echo 'arch-base' > /etc/hostname
systemctl enable sshd
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/sudo-group-nopasswd

# Configure Network
systemctl enable systemd-networkd
systemctl enable systemd-resolved

mkdir /etc/systemd/network/99-default.link.d
cat <<-EOF > /etc/systemd/network/99-default.link.d/traditional-naming.conf
[Link]
NamePolicy=keep kernel
EOF

cat <<-EOF > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

# Configure grub
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
grub-install --target=i386-pc $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# Configure vagrant user
useradd --create-home --groups wheel --password $(openssl passwd -1 'vagrant') vagrant
mkdir /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/v2.4.1/keys/vagrant.pub
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/*
