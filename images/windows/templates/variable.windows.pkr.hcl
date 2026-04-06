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
}

variable "node" {
  type        = string
  description = "Proxmox cluster node"
}

variable "iso_storage" {
  type        = string
  description = "Proxmox storage location for iso files"
  default     = "local"
}

variable "disk_storage" {
  type        = string
  description = "Disk storage location"
  default     = "local-lvm"
}

variable "efi_storage" {
  type        = string
  description = "Location of EFI storage on proxmox host"
  default     = "local-lvm"
}

variable "cloud_init_storage" {
  type        = string
  description = "Location of cloud-init files/iso/yaml config"
  default     = "local-lvm"
}

// VM hardware related variables
variable "memory" {
  type        = number
  description = "Amount of RAM in MB"
  default     = 8192
}

variable "ballooning_minimum" {
  type        = number
  description = "Minimum amount of RAM in MB for ballooning"
  default     = 2048
}

variable "cores" {
  type        = number
  description = "Amount of CPU cores"
  default     = 2
}

variable "socket" {
  type        = number
  description = "Amount of CPU sockets"
  default     = 1
}

variable "disk_size_gb" {
  type        = string
  description = "Size of the base image OS disk, including a unit suffix (e.g. '32G'). Kept small so the Proxmox template occupies minimal storage. The runner build expands this disk before installing tooling. The effective per-OS default (32G) is set via coalesce() in locals.windows.pkr.hcl."
  default     = null
}

variable "runner_disk_size_gb" {
  type        = string
  description = "Target size of the OS disk after expansion during the runner build, including a unit suffix (e.g. '200G'). Must be larger than disk_size_gb. The runner build calls the Proxmox API to resize scsi0 to this size before installing runner tooling."
  default     = "200G"
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

// Windows related variables

variable "license_keys" {
  type = object({
    win22        = string
    win25        = string
    win25_vs2026 = string
  })
  description = "Windows license keys for different versions. Leave empty for evaluation versions."
  default = {
    win22        = ""
    win25        = ""
    win25_vs2026 = ""
  }
  validation {
    condition = alltrue([
      for version, key in var.license_keys :
      key == "" || can(regex("^([A-Za-z0-9]{5}-){4}[A-Za-z0-9]{5}$", key))
    ])
    error_message = "Each license key must be either empty for evaluation version or in the format XXXXX-XXXXX-XXXXX-XXXXX-XXXXX."
  }
}

variable "virtio_win_iso" {
  type        = string
  description = "Virtio-win ISO file"
  default     = "virtio-win.iso"
}

variable "cdrom_drive" {
  type        = string
  description = "CD-ROM Drive letter for extra iso"
  default     = "D:"
}

variable "virtio_cdrom_drive" {
  type        = string
  description = "CD-ROM Drive letter for virtio-win iso"
  default     = "E:"
}

variable "timezone" {
  type        = string
  description = "Windows timezone"
  default     = "UTC"
}

// Build scripts related variables
variable "agent_tools_directory" {
  type    = string
  default = "C:\\hostedtoolcache\\windows"
}
variable "helper_script_folder" {
  type    = string
  default = "C:\\Program Files\\WindowsPowerShell\\Modules\\"
}
variable "image_folder" {
  type    = string
  default = "C:\\image"
}
variable "vm_ids" {
  type = object({
    win22_base        = number
    win22_runner      = number
    win25_base        = number
    win25_runner      = number
    win25_vs2026_base = number
    win25_vs2026_runner = number
  })
  description = "VM IDs for templates. Set to 0 for auto-assignment by Proxmox. VMIDs must be unique cluster-wide and in range 100-999999999."
  default = {
    win22_base          = 0
    win22_runner        = 0
    win25_base          = 0
    win25_runner        = 0
    win25_vs2026_base   = 0
    win25_vs2026_runner = 0
  }
  validation {
    condition = alltrue([
      for vm_id in values(var.vm_ids) :
      vm_id == 0 || (vm_id >= 100 && vm_id <= 999999999)
    ])
    error_message = "VM IDs must be between 100 and 999999999, or 0 for auto-assignment."
  }
}

variable "image_os" {
  type    = string
  default = "win25"
  validation {
    condition     = contains(["win22", "win25", "win25-vs2026"], var.image_os)
    error_message = "The image_os value must be one of: win22, win25, win25-vs2026."
  }
}

variable "image_version" {
  type    = string
  default = "dev"
}
variable "imagedata_file" {
  type    = string
  default = "C:\\imagedata.json"
}
variable "install_password" {
  type      = string
  default   = ""
  sensitive = true
}
variable "install_user" {
  type        = string
  default     = "Administrator"
  description = "Username for logging into winrm and autologon during and after image build. Use 'Administrator' for the built-in admin account."
}

// Debugging related variables
variable "winrm_host" {
  type        = string
  description = "IP address or hostname for WinRM debugging connection. Required when using *.winrm sources for testing provisioners on existing VMs."
  default     = null
}

