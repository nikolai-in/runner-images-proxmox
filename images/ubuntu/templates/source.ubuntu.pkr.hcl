packer {
  required_plugins {
    proxmox = {
      version = "1.2.10"
      source  = "github.com/nikolai-in/proxmox"
    }
  }
}

source "proxmox-clone" "image" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  node                     = var.node

  clone_vm                = local.image_properties.base_template
  full_clone              = false
  vm_id                   = local.image_properties.runner_vm_id
  vm_name                 = "ubuntu-instance-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  template_name           = local.image_properties.runner_template
  template_description    = "Ubuntu ${var.image_os} Runner VM cloned from base template\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}"
  os                      = "l26"
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage
  cloud_init_additional_values = {
    ciuser    = var.install_user
    ipconfig0 = "ip=dhcp"
  }

  memory   = var.memory
  cores    = var.cores
  sockets  = var.socket
  cpu_type = "host"
  cpu_flags {
    nested_virt = true
  }
  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    model  = "virtio"
    bridge = var.bridge
  }

  disks {
    storage_pool = var.disk_storage
    type         = "scsi"
    disk_size    = local.image_properties.disk_size
    cache_mode   = "unsafe"
    format       = "raw"
    index        = "0"
  }

  communicator = "ssh"
  ssh_username = var.install_user
  ssh_password = var.install_password
  ssh_timeout  = "1h"
}

source "null" "ssh" {
  ssh_host     = var.ssh_host
  ssh_port     = var.ssh_port
  ssh_username = var.install_user
  ssh_password = var.install_password
  ssh_timeout  = "1h"
}
