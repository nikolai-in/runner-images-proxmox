# Example Packer variable file for Ubuntu builds
# Copy this to variables.pkrvars.hcl and customize for your environment

# Proxmox connection settings
proxmox_url      = "https://your-proxmox-server:8006/api2/json"
proxmox_user     = "your-user@pam"
proxmox_password = "your-password"
node             = "your-node-name"

# Storage configuration
disk_storage       = "local-lvm"
cloud_init_storage = "local-lvm"

# VM hardware settings
memory = 8192
cores  = 4
socket = 1

# Network settings
bridge = "vmbr0"

# SSH settings
ssh_username = "packer"
ssh_password = "YourSecurePassword123!"

# Image settings
# Note: image_os uses underscores (ubuntu22 / ubuntu24)
# while vm_ids uses the same names as keys
image_os      = "ubuntu24" # Options: ubuntu22, ubuntu24
image_version = "dev"
disk_size_gb  = "75G"

# VM IDs for templates (optional - set to 0 for auto-assignment)
# VMIDs must be unique cluster-wide and in range 100-999999999
vm_ids = {
  ubuntu22_runner = 0 # 3022  # Example: assign specific VM ID
  ubuntu24_runner = 0 # 3024  # Example: assign specific VM ID
}

# DockerHub credentials (optional - avoids rate limiting during image pulls)
# dockerhub_login    = "your-dockerhub-username"
# dockerhub_password = "your-dockerhub-token"
