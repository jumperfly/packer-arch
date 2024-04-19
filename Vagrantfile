# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.define "base" do |base|
    base.vm.box = "jumperfly-local/archlinux"
    base.vm.box_url = "file://output-boxes/archlinux-#{ENV['VAGRANT_DEFAULT_PROVIDER']}.box"
    base.vm.provision "shell", inline: "cat /etc/os-release && uname -r"
  end

  config.vm.define "ansible" do |ansible|
    ansible.vm.box = "jumperfly-local/ansible"
    ansible.vm.box_url = "file://output-boxes/ansible-#{ENV['VAGRANT_DEFAULT_PROVIDER']}.box"
    ansible.vm.provision "shell", inline: "ansible --version"
  end
end
