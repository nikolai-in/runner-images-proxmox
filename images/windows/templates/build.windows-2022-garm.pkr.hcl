// Normal build: packer build -only="windows-2022-garm.proxmox-clone.runner" -var="image_os=win22-garm" .

build {
  sources = [
    "source.proxmox-clone.runner"
  ]
  name = "windows-2022-garm"

  provisioner "powershell" {
    inline = ["New-Item -ItemType Directory -Force -Path C:\\garm\\scripts"]
  }

  provisioner "file" {
    destination = "C:\\garm\\scripts\\install-windows.ps1"
    source      = "${path.root}/../../garm/scripts/install-windows.ps1"
  }

  provisioner "file" {
    destination = "C:\\garm\\scripts\\startup-windows.ps1"
    source      = "${path.root}/../../garm/scripts/startup-windows.ps1"
  }

  provisioner "powershell" {
    environment_vars = ["IMAGE_FOLDER=${var.image_folder}", "TEMP_DIR=${var.temp_dir}"]
    inline = [
      "C:\\garm\\scripts\\install-windows.ps1"
    ]
  }
}
