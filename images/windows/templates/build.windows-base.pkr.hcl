// Windows Base Image Build Configuration
// 
// Normal build: packer build -only="${var.image_os}-base.base" .
// Debug build:  packer build -only="${var.image_os}-base.winrm" -var="winrm_host=IP" .

build {
  name = "${var.image_os}-base"

  sources = [
    "source.proxmox-iso.base",
    "source.null.winrm",
  ]

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "${path.root}/../scripts/build/Install-BaseWindowsUpdates.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  provisioner "powershell" {
    script = "${path.root}/../scripts/build/Install-CloudBase.ps1"
  }

  provisioner "file" {
    source      = "${path.root}/../assets/base/config/"
    destination = "C:/Program Files/Cloudbase Solutions/Cloudbase-Init/conf"
  }

  provisioner "powershell" {
    inline = [
      "Set-Service cloudbase-init -StartupType Manual",
      "Stop-Service cloudbase-init -Force -Confirm:$false"
    ]
  }
}
