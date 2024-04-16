# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.box = "jumperfly/arch"
  config.vm.box_url = "file://output-boxes/base-libvirt.box"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.provision "shell", inline: "cat /etc/os-release"
end
