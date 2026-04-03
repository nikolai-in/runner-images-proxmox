packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
      source  = "github.com/nikolai-in/proxmox"
    }
  }
}

source "proxmox-clone" "runner" {
  // PROXMOX CONNECTION CONFIGURATION
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  node                     = var.node

  // CLONE CONFIGURATION
  clone_vm             = local.image_properties.base_template
  full_clone           = false
  vm_id                = local.image_properties.runner_vm_id
  vm_name              = "ubuntu-instance-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  template_name        = local.image_properties.runner_template
  template_description = "Ubuntu ${var.image_os} Runner Image\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}"
  os                   = "l26"

  // CLOUD-INIT CONFIGURATION
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage

  // HARDWARE CONFIGURATION
  memory   = var.memory
  cores    = var.cores
  sockets  = var.socket
  cpu_type = "host"

  // NETWORK CONFIGURATION
  network_adapters {
    model  = "virtio"
    bridge = var.bridge
  }

  // SSH COMMUNICATION CONFIGURATION
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
}

source "null" "ssh" {
  // DEBUG SOURCE - Connect to existing Ubuntu VM via SSH for rapid provisioner testing
  //
  // This source allows you to test provisioners on an existing VM without rebuilding.
  // To use this source instead of the default Proxmox source, use Packer's -only flag:
  //
  // Examples:
  // packer build -only="*.ssh" -var="ssh_host=192.168.1.100" .
  // packer build -only="ubuntu-22_04.ssh" -var="ssh_host=my-test-vm" .
  //
  // Prerequisites:
  // - Existing Ubuntu VM with SSH enabled
  // - Same credentials as specified in ssh_username/ssh_password variables

  communicator = "ssh"
  ssh_host     = var.ssh_host
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
}
