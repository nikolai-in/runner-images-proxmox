// Windows Server 2025 Base Image Build Configuration
// 
// Normal build: packer build -only="win25-base.proxmox-iso.win25-base" .
// Debug build:  packer build -only="win25-base.null.winrm" -var="winrm_host=IP" .

build {
  name = "win25-base"

  sources = [
    "source.proxmox-iso.win25-base",
    "source.null.winrm",
  ]

  provisioner "windows-restart" {
  }

  // Install Windows Updates using the rgl/packer-plugin-windows-update provisioner.
  // The provisioner handles multiple update/restart cycles automatically.
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -match 'Preview'",
      "exclude:$_.Title -match 'Beta'",
      "exclude:$_.Title -match 'Windows Recovery Environment'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
      "include:$true",
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  provisioner "powershell" {
    // Run after updates have been installed and the OS has restarted.
    // Disables hibernation, cleans the WU download cache, runs DISM
    // component cleanup, clears temp files / event logs, and zeroes
    // free space so Proxmox thin-provisioned storage can reclaim blocks.
    script          = "${path.root}/../scripts/build/Optimize-BaseImage.ps1"
    // Allow up to 45 minutes: DISM /ResetBase alone can take 15-30 minutes;
    // zeroing free space adds another 5-20 minutes depending on disk size.
    timeout         = "45m"
  }

  // Restart after DISM component cleanup (required for changes to take effect)
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
