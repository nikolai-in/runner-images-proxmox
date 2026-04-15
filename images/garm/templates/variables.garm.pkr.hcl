variable "proxmox_url" {
  type        = string
  description = "URL to the Proxmox API"
}

variable "proxmox_insecure" {
  type        = bool
  default     = true
  description = "Skip TLS verification"
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox user"
}

variable "proxmox_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Proxmox password (if not using token)"
}

variable "proxmox_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Proxmox API token"
}

variable "node" {
  type        = string
  description = "Target Proxmox node"
}

variable "pool" {
  type        = string
  default     = ""
  description = "Proxmox resource pool"
}

variable "task_timeout" {
  type        = string
  default     = "15m"
  description = "Timeout for Proxmox API tasks"
}

variable "clone_vm" {
  type        = string
  description = "Name or ID of the existing base template to clone"
}

variable "template_name" {
  type        = string
  description = "Name for the new GARM-ready template"
}

variable "vm_id" {
  type        = number
  description = "The ID of the cloned VM"
}

variable "ssh_username" {
  type        = string
  default     = "runner"
  description = "SSH username for Linux images"
}

variable "ssh_password" {
  type        = string
  default     = "runner"
  sensitive   = true
  description = "SSH password for Linux images"
}

variable "ssh_timeout" {
  type        = string
  default     = "20m"
  description = "Timeout for SSH connection"
}

variable "winrm_username" {
  type        = string
  default     = "runneradmin"
  description = "WinRM username for Windows images"
}

variable "winrm_password" {
  type        = string
  default     = "runneradmin"
  sensitive   = true
  description = "WinRM password for Windows images"
}

variable "winrm_timeout" {
  type        = string
  default     = "20m"
  description = "Timeout for WinRM connection"
}
