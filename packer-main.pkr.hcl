variables {
  box_version             = ""
  box_version_description = ""
}

source "qemu" "iso-output" {
  output_directory = "output-${source.name}"
  vm_name          = "packer-${source.name}"
  accelerator      = "kvm"
  headless         = true
  memory           = 512
  disk_size        = 10240
  iso_url          = "file:${abspath(path.root)}/output-iso/packer-iso"
  iso_checksum     = "file:${abspath(path.root)}/output-iso/packer-iso.md5"
  disk_image       = true
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "1m"
}

build {
  source "qemu.iso-output" {
    name = "archlinux"
  }

  source "qemu.iso-output" {
    name = "ansible"
  }

  provisioner "shell" {
    scripts = compact([
      source.name == "archlinux" ? "" : "scripts/provision-${source.name}.sh",
      "scripts/cleanup.sh",
    ])
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
  }

  post-processors {
    post-processor "vagrant" {
      output              = "output-boxes/${source.name}-{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag             = "jumperfly/${source.name}"
      version             = var.box_version
      version_description = var.box_version_description
    }
  }
}
