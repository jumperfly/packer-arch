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
  boot_wait               = "30s"
  box_version             = ""
  box_version_description = ""
}

locals {
  now = timestamp()

  box_tag = "jumperfly/archlinux"
  box_version = coalesce(
    # Use box_version from variable if set
    var.box_version,
    # Otherwise default to 0.<date>.<time>
    formatdate("0.YYYYMMDD.hhmmss", local.now)
  )

  iso = {
    year     = "2024"
    month    = "04"
    day      = "01"
    checksum = "sha256:52aea58f88c9a80afe64f0536da868251ef4878de5a5e0227fcada9f132bd7ab"
  }
  iso_version = "${local.iso.year}.${local.iso.month}.${local.iso.day}"
}

source "qemu" "base" {
  accelerator    = "kvm"
  headless       = true
  memory         = 1024
  disk_size      = 10240
  iso_url        = "https://mirrors.edge.kernel.org/archlinux/iso/${local.iso_version}/archlinux-${local.iso_version}-x86_64.iso"
  iso_checksum   = local.iso.checksum
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
      box_tag             = local.box_tag
      version             = local.box_version
      version_description = var.box_version_description
    }
  }
}
