// Proxmox related variables
variable "proxmox_url" {
  type        = string
  description = "Proxmox Server URL"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Allow insecure connections to Proxmox"
  default     = false
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox username"
  sensitive   = true
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
  default     = ""
}

variable "proxmox_token" {
  type        = string
  description = "Proxmox API token (alternative to password)"
  sensitive   = true
  default     = ""
}

variable "node" {
  type        = string
  description = "Proxmox cluster node"
}

variable "pool" {
  type        = string
  description = "Proxmox pool name for the LXC container"
  default     = ""
}

variable "task_timeout" {
  type        = string
  description = "Proxmox API task timeout (e.g. 60s, 5m)"
  default     = "60s"
}

// LXC template and container configuration
variable "ostemplate" {
  type        = string
  description = "Proxmox LXC OS template (e.g. local:vztmpl/ubuntu-24.04-standard_24.04-1_amd64.tar.zst)"
}

variable "rootfs" {
  type        = string
  description = "Root filesystem storage (e.g. local-lvm:8)"
}

variable "vm_id" {
  type        = number
  description = "Container ID. Set to 0 for auto-assignment by Proxmox."
  default     = 0
  validation {
    condition     = var.vm_id == 0 || (var.vm_id >= 100 && var.vm_id <= 999999999)
    error_message = "VM ID must be between 100 and 999999999, or 0 for auto-assignment."
  }
}

variable "vm_name" {
  type        = string
  description = "Container hostname"
  default     = ""
}

variable "memory" {
  type        = number
  description = "Amount of RAM in MB"
  default     = 4096
}

variable "cores" {
  type        = number
  description = "Amount of CPU cores"
  default     = 2
}

variable "onboot" {
  type        = bool
  description = "Start container on node boot"
  default     = true
}

variable "start" {
  type        = bool
  description = "Start container immediately after creation"
  default     = false
}

variable "tags" {
  type        = string
  description = "Comma-separated container tags"
  default     = ""
}

variable "nameserver" {
  type        = string
  description = "DNS server list (space-separated)"
  default     = ""
}

variable "searchdomain" {
  type        = string
  description = "DNS search domain"
  default     = ""
}

variable "unprivileged" {
  type        = bool
  description = "Create unprivileged container"
  default     = true
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

variable "net_name" {
  type        = string
  description = "LXC network interface name (defaults to eth0 when empty)"
  default     = ""
}

variable "net_firewall" {
  type        = bool
  description = "Enable Proxmox firewall on the LXC network interface"
  default     = false
}

variable "net_ip" {
  type        = string
  description = "IPv4 address in CIDR format (e.g. 192.168.1.10/24 or dhcp)"
  default     = "dhcp"
}

variable "net_gateway" {
  type        = string
  description = "IPv4 gateway"
  default     = ""
}

variable "net_ipv6" {
  type        = string
  description = "IPv6 address in CIDR format (e.g. 2001:db8::10/64, auto, or dhcp)"
  default     = ""
}

variable "net_gateway_ipv6" {
  type        = string
  description = "IPv6 gateway"
  default     = ""
}

variable "net_mac_address" {
  type        = string
  description = "MAC address for the network interface"
  default     = ""
}

variable "net_mtu" {
  type        = number
  description = "MTU for the network interface"
  default     = 0
}

variable "net_rate" {
  type        = string
  description = "Rate limit in mbps (Proxmox rate format)"
  default     = ""
}

variable "net_vlan_tag" {
  type        = string
  description = "VLAN tag for the network interface"
  default     = ""
}

variable "net_type" {
  type        = string
  description = "Network device type (e.g. veth)"
  default     = ""
}

variable "features" {
  type        = string
  description = "Proxmox LXC features string (e.g. nesting=1)"
  default     = "nesting=1"
}

variable "template" {
  type        = bool
  description = "Convert the LXC container to a Proxmox template after provisioning"
  default     = true
}

variable "template_name" {
  type        = string
  description = "Template name (maps to LXC hostname)"
  default     = ""
}

variable "template_description" {
  type        = string
  description = "Template description shown in the Proxmox UI"
  default     = ""
}

# variable "lxc_config" {
#   type        = map(string)
#   description = "Additional Proxmox LXC config key/value pairs"
#   default     = {}
# }

// SSH communicator configuration
variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "root"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = ""
  sensitive   = true
}

variable "ssh_host" {
  type        = string
  description = "SSH host for LXC provisioning"
  default     = ""
}

variable "ssh_timeout" {
  type        = string
  description = "SSH timeout"
  default     = "1h"
}

// Image-related variables
variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}

variable "image_os" {
  type    = string
  default = "Linux"
}

variable "image_version" {
  type    = string
  default = "dev"
}

variable "container_password" {
  type        = string
  description = "LXC container root password"
  default     = ""
  sensitive   = true
}



variable "image_owner" {
  type        = string
  description = "Image owner metadata"
  default     = "GitHub"
}

variable "image_target_platform" {
  type        = string
  description = "Image target platform metadata"
  default     = "GitHub"
}

variable "nvm_dir" {
  type        = string
  description = "NVM installation directory"
  default     = "/etc/skel/.nvm"
}

variable "imagedata_name" {
  type        = string
  description = "Image name written to imagedata.json"
  default     = "ubuntu:24.04"
}

variable "imagedata_included_software" {
  type        = string
  description = "Optional extra metadata for imagedata.json"
  default     = ""
}

variable "imagedata_file" {
  type    = string
  default = "/imagegeneration/imagedata.json"
}
