# Ubuntu slim LXC Packer variables (local build)
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


ostemplate         = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
rootfs             = "foliant:64"
bridge             = "vmbrawg1"
net_ip             = "dhcp"
container_password = "ChangeMe123!"
features           = "nesting=1"
