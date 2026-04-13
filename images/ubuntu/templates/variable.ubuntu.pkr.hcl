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
  description = "Target size of the OS disk, including a unit suffix (e.g. '75G')."
  default     = null
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

variable "vm_ids" {
  type = object({
    ubuntu22_runner = number
    ubuntu24_runner = number
  })
  description = "VM IDs for templates. Set to 0 for auto-assignment by Proxmox. VMIDs must be unique cluster-wide and in range 100-999999999."
  default = {
    ubuntu22_runner = 0
    ubuntu24_runner = 0
  }
  validation {
    condition = alltrue([
      for vm_id in values(var.vm_ids) :
      vm_id == 0 || (vm_id >= 100 && vm_id <= 999999999)
    ])
    error_message = "VM IDs must be between 100 and 999999999, or 0 for auto-assignment."
  }
}

variable "base_template_ubuntu22" {
  type        = string
  description = "Override base template name for Ubuntu 22.04 runner builds"
  default     = ""
}

variable "base_template_ubuntu24" {
  type        = string
  description = "Override base template name for Ubuntu 24.04 runner builds"
  default     = ""
}

// Image related variables
variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}
variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}
variable "image_os" {
  type = string
  validation {
    condition     = contains(["ubuntu22", "ubuntu24"], var.image_os)
    error_message = "The image_os value must be one of: ubuntu22, ubuntu24."
  }
}
variable "image_version" {
  type    = string
  default = "dev"
}
variable "imagedata_file" {
  type    = string
  default = "/imagegeneration/imagedata.json"
}
variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}
variable "install_password" {
  type      = string
  default   = ""
  sensitive = true
}
variable "install_user" {
  type    = string
  default = "installer"
}

variable "ssh_host" {
  type        = string
  description = "SSH host for resume/debug builds via null source"
  default     = ""
}

variable "ssh_port" {
  type        = number
  description = "SSH port for resume/debug builds via null source"
  default     = 22
}
