packer {
  required_plugins {
    qemu = {
      version = "1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = "1.1.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variables {
  boot_wait     = "30s"
  version_patch = "1"
}

locals {
  version_year  = "2024"
  version_month = "04"
  version_day   = "01"
  version       = "${local.version_year}.${local.version_month}.${local.version_day}"
  iso_checksum  = "sha256:52aea58f88c9a80afe64f0536da868251ef4878de5a5e0227fcada9f132bd7ab"
}

source "qemu" "base" {
  accelerator    = "kvm"
  headless       = true
  memory         = 1024
  disk_size      = 10240
  iso_url        = "https://mirrors.edge.kernel.org/archlinux/iso/${local.version}/archlinux-${local.version}-x86_64.iso"
  iso_checksum   = local.iso_checksum
  ssh_username   = "root"
  ssh_password   = "packer"
  ssh_timeout    = "1m"
  http_directory = "http"
  boot_wait      = "5s"
  boot_command = [
    "<enter><wait${var.boot_wait}>",
    "usermod -p $(openssl passwd -1 'packer') root<enter>"
  ]
}

build {
  sources = ["sources.qemu.base"]

  provisioner "shell" {
    script = "provision.sh"
  }

  post-processors {
    post-processor "vagrant" {
      output = "output-boxes/${source.name}-{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "jumperfly/arch"
      version = "0.${local.version_year}${local.version_month}.${var.version_patch}"
    }
  }
}
