packer {
  required_plugins {
    proxmox = {
      version = "1.2.6"
      source  = "github.com/nikolai-in/proxmox"
    }
  }
}

source "proxmox-clone" "linux" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  token                    = var.proxmox_token
  node                     = var.node
  pool                     = var.pool
  task_timeout             = var.task_timeout

  clone_vm                 = var.clone_vm
  vm_id                    = var.vm_id
  vm_name                  = var.template_name
  template_description     = "GARM-ready Linux runner template"

  os                       = "l26"
  qemu_agent               = true

  communicator             = "ssh"
  ssh_username             = var.ssh_username
  ssh_password             = var.ssh_password
  ssh_timeout              = var.ssh_timeout
}

source "proxmox-clone" "windows" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  token                    = var.proxmox_token
  node                     = var.node
  pool                     = var.pool
  task_timeout             = var.task_timeout

  clone_vm                 = var.clone_vm
  vm_id                    = var.vm_id
  vm_name                  = var.template_name
  template_description     = "GARM-ready Windows runner template"

  os                       = "win11"
  qemu_agent               = true

  communicator             = "winrm"
  winrm_username           = var.winrm_username
  winrm_password           = var.winrm_password
  winrm_timeout            = var.winrm_timeout
  winrm_insecure           = true
  winrm_use_ssl            = true
}

source "proxmox-lxc" "lxc" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  token                    = var.proxmox_token
  node                     = var.node
  pool                     = var.pool
  task_timeout             = var.task_timeout

  clone_vm                 = var.clone_vm
  vm_id                    = var.vm_id
  vm_name                  = var.template_name
  template_name            = var.template_name
  template_description     = "GARM-ready LXC runner template"
  template                 = true

  communicator             = "ssh"
  ssh_username             = var.ssh_username
  ssh_password             = var.ssh_password
  ssh_timeout              = var.ssh_timeout
}
