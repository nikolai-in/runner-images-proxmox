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
  default     = 4
}

variable "socket" {
  type        = number
  description = "Amount of CPU sockets"
  default     = 1
}

variable "disk_size_gb" {
  type        = string
  description = "The size of the disk, including a unit suffix, such as 75G to indicate 75 gigabytes"
  default     = null
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

// VM ID configuration
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

// SSH communication variables
variable "ssh_username" {
  type        = string
  description = "Username used for SSH connection to the VM"
  default     = "packer"
}

variable "ssh_password" {
  type        = string
  description = "Password used for SSH connection to the VM"
  sensitive   = true
  default     = ""
}

variable "ssh_host" {
  type        = string
  description = "IP address or hostname for SSH debugging connection. Required when using *.ssh sources for testing provisioners on existing VMs."
  default     = null
}

// DockerHub credentials (optional - used to avoid rate limiting when pulling images)
variable "dockerhub_login" {
  type        = string
  description = "DockerHub login for authenticated pulls (avoids rate limiting)"
  default     = "${env("DOCKERHUB_LOGIN")}"
}

variable "dockerhub_password" {
  type        = string
  description = "DockerHub password for authenticated pulls"
  sensitive   = true
  default     = "${env("DOCKERHUB_PASSWORD")}"
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
  type    = string
  default = "ubuntu24"
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
