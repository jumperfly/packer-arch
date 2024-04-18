# Arch Linux Packer

Builds Arch Linux Vagrant boxes from ISO installation using Packer.

Supported providers:
  - libvirt

## Building Locally

Requires
  - packer 1.10.2+
  - libvirt

Run `packer init .` before the first build.

Build the base qemu image from ISO: `packer build packer-iso.pkr.hcl`

Build the vagrant boxes from the base image above: `packer build packer-main.pkr.hcl`

The resulting vagrant boxes are saved to `output-boxes`

## Running Locally

Requires:
  - vagrant 2.4.1+
  - vagrant-libvirt plugin 0.12.2+

Run the supplied script: `./local-run.sh`.

This essentially wraps `vagrant up` while ensuring the latest built boxes are imported.

It will attempt to cleanup previously imported libvirt images provided they are stored in the default /var/lib/libvirt/images
