

source "proxmox-lxc" "image" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  token                    = var.proxmox_token
  node                     = var.node
  pool                     = var.pool
  task_timeout             = var.task_timeout

  ostemplate   = var.ostemplate
  rootfs       = var.rootfs
  vm_id        = var.vm_id
  vm_name      = length(trimspace(var.vm_name)) > 0 ? var.vm_name : "ubuntu-slim-runner-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  memory       = var.memory
  cores        = var.cores
  onboot       = var.onboot
  start        = var.start
  tags         = var.tags
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
  unprivileged = var.unprivileged
  features     = var.features
  template     = var.template
  template_name        = length(trimspace(var.template_name)) > 0 ? var.template_name : "ubuntu-slim-runner"
  template_description = length(trimspace(var.template_description)) > 0 ? var.template_description : "Ubuntu slim runner LXC template\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}\nMetadata: /imagegeneration/imagedata.json\nSoftware report: /imagegeneration/output/software-report.json\nToolset: /imagegeneration/installers/toolset.json"
  container_password = var.container_password

  network_adapters {
    name        = var.net_name
    bridge      = var.bridge
    firewall    = var.net_firewall
    gateway     = var.net_gateway
    gateway_ipv6 = var.net_gateway_ipv6
    ip          = var.net_ip
    ipv6        = var.net_ipv6
    mac_address = var.net_mac_address
    mtu         = var.net_mtu
    rate        = var.net_rate
    vlan_tag    = var.net_vlan_tag
    type        = var.net_type
  }

  communicator = "ssh"
  ssh_host     = var.ssh_host
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
}
