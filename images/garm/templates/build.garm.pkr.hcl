build {
  name = "garm-postprocess"

  sources = [
    "source.proxmox-clone.linux",
    "source.proxmox-clone.windows",
    "source.proxmox-lxc.lxc"
  ]

  # For Linux
  provisioner "shell" {
    inline = ["mkdir -p /opt/garm/scripts"]
    only   = ["proxmox-clone.linux", "proxmox-lxc.lxc"]
  }

  provisioner "file" {
    destination = "/opt/garm/scripts/install-linux.sh"
    source      = "${path.root}/../scripts/install-linux.sh"
    only        = ["proxmox-clone.linux", "proxmox-lxc.lxc"]
  }

  provisioner "file" {
    destination = "/opt/garm/scripts/startup-linux.sh"
    source      = "${path.root}/../scripts/startup-linux.sh"
    only        = ["proxmox-clone.linux", "proxmox-lxc.lxc"]
  }

  provisioner "shell" {
    inline = [
      "chmod +x /opt/garm/scripts/install-linux.sh /opt/garm/scripts/startup-linux.sh",
      "/opt/garm/scripts/install-linux.sh"
    ]
    only   = ["proxmox-clone.linux", "proxmox-lxc.lxc"]
  }

  # For Windows
  provisioner "powershell" {
    inline = ["New-Item -ItemType Directory -Force -Path C:\\garm\\scripts"]
    only   = ["proxmox-clone.windows"]
  }

  provisioner "file" {
    destination = "C:\\garm\\scripts\\install-windows.ps1"
    source      = "${path.root}/../scripts/install-windows.ps1"
    only        = ["proxmox-clone.windows"]
  }

  provisioner "file" {
    destination = "C:\\garm\\scripts\\startup-windows.ps1"
    source      = "${path.root}/../scripts/startup-windows.ps1"
    only        = ["proxmox-clone.windows"]
  }

  provisioner "powershell" {
    inline = [
      "C:\\garm\\scripts\\install-windows.ps1"
    ]
    only   = ["proxmox-clone.windows"]
  }
}
