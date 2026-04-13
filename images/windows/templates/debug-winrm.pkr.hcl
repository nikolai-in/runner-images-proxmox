variable "vm_ip" {
  type        = string
  description = "The IP address of the running Windows VM"
  default     = "10.99.99.91"
}

variable "winrm_password" {
  type        = string
  description = "The Administrator password set by your unattend.xml"
  default     = "YourSecurePassword123!" # Change this if your default password is different
}

source "null" "windows_debug" {
  communicator   = "winrm"
  winrm_host     = var.vm_ip
  winrm_username = "Administrator"
  winrm_password = var.winrm_password
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "1h"
}

build {
  sources = ["source.null.windows_debug"]

  # 1. Run the updated Install-Runner.ps1 to install act_runner and NSSM
  provisioner "powershell" {
    script           = "${path.root}/../scripts/build/Install-Runner.ps1"
    environment_vars = ["TEMP_DIR=C:\\Windows\\Temp", "IMAGE_FOLDER=C:\\"]
  }


  provisioner "file" {
    source      = "${path.root}/../assets/base/config/"
    destination = "C:/Program Files/Cloudbase Solutions/Cloudbase-Init/conf"
  }

  # 2. Sysprep again to return it to OOBE, then shut down
  provisioner "powershell" {
    inline = [
      "Set-Service cloudbase-init -StartupType Automatic",
      "Write-Output \"Skipping Sysprep for faster CI/CD spin-up time.\""
      , "Stop-Computer -Force"
    ]
  }
}