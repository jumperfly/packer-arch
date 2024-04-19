variables {
  boot_wait = "30s"
}

locals {
  iso = {
    year     = "2024"
    month    = "04"
    day      = "01"
    checksum = "sha256:52aea58f88c9a80afe64f0536da868251ef4878de5a5e0227fcada9f132bd7ab"
  }
  iso_version = "${local.iso.year}.${local.iso.month}.${local.iso.day}"
}

source "qemu" "iso" {
  accelerator    = "kvm"
  headless       = true
  memory         = 1024
  disk_size      = 10240
  iso_url        = "https://mirrors.edge.kernel.org/archlinux/iso/${local.iso_version}/archlinux-${local.iso_version}-x86_64.iso"
  iso_checksum   = local.iso.checksum
  ssh_username   = "root"
  ssh_password   = "packer"
  ssh_timeout    = "1m"
  http_directory = "scripts"
  boot_wait      = "5s"
  boot_command = [
    "<enter><wait${var.boot_wait}>",
    "usermod -p $(openssl passwd -1 'packer') root<enter>"
  ]
}

build {
  sources = ["sources.qemu.iso"]

  provisioner "shell" {
    script = "scripts/provision-iso.sh"
  }

  post-processors {
    post-processor "checksum" {
      checksum_types = ["md5"]
      output         = "output-{{.BuildName}}/packer-{{.BuildName}}.{{.ChecksumType}}"
    }
    post-processor "shell-local" {
      inline = ["scripts/convert-qcow2-to-ovf.sh output-iso/packer-iso output-iso/packer-iso.ovf"]
    }
  }
}
