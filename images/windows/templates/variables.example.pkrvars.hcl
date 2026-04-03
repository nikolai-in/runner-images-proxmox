# Example Packer variable file for Windows builds
# Copy this to variables.pkrvars.hcl and customize for your environment

# Proxmox connection settings
proxmox_url      = "https://your-proxmox-server:8006/api2/json"
proxmox_user     = "your-user@pam"
proxmox_password = "your-password"
node             = "your-node-name"

# Storage configuration
iso_storage        = "local"
disk_storage       = "local-lvm"
efi_storage        = "local-lvm"
cloud_init_storage = "local-lvm"

# VM hardware settings
memory = 8192
cores  = 4
socket = 1

# Network settings
bridge = "vmbr0"

# Windows settings
install_user     = "Administrator"
install_password = "YourSecurePassword123!"
timezone         = "UTC"

# Image settings
# Note: image_os uses hyphens (e.g. "win25-vs2026") while vm_ids and license_keys
# use underscores (e.g. win25_vs2026) because HCL attribute names cannot contain hyphens.
image_os      = "win25" # Options: win22, win25, win25-vs2026
image_version = "dev"
# disk_size_gb controls the OS disk of the base template, which runner VMs inherit.
# Default is 150G — sufficient for Windows Server + updates + all runner tooling.
# Increase to 200G+ if runner builds run out of C:\ space.
# disk_size_gb = "150G"

# License keys (optional - leave empty for evaluation versions)
license_keys = {
  win22        = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win25        = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win25_vs2026 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
}

# VM IDs for templates (optional - set to 0 for auto-assignment)
# VMIDs must be unique cluster-wide and in range 100-999999999
vm_ids = {
  win22_base          = 0 # 1022  # Example: assign specific VM ID
  win22_runner        = 0 # 2022  # Example: assign specific VM ID
  win25_base          = 0 # 1025  # Example: assign specific VM ID
  win25_runner        = 0 # 2025  # Example: assign specific VM ID
  win25_vs2026_base   = 0 # 1026  # Example: assign specific VM ID
  win25_vs2026_runner = 0 # 2026  # Example: assign specific VM ID
}

# ISO files (ensure these exist in your Proxmox ISO storage)
virtio_win_iso = "virtio-win.iso"
