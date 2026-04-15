source "proxmox-clone" "image" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  token                    = var.proxmox_token
  node                     = var.node
  task_timeout             = var.task_timeout

  clone_vm                 = "ubuntu-slim-runner"
  full_clone               = false
  vm_id                    = var.vm_id != 0 ? var.vm_id : null
  vm_name                  = length(trimspace(var.vm_name)) > 0 ? "${var.vm_name}-garm" : "ubuntu-slim-garm-runner-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

  template_name            = "ubuntu-slim-garm-runner"
  template_description     = "Ubuntu slim GARM runner LXC template\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}"

  communicator = "ssh"
  ssh_host     = var.ssh_host
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
}
