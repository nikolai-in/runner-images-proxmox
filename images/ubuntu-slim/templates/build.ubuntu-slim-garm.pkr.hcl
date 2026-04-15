build {
  sources = [
    "source.proxmox-clone.image"
  ]
  name = "ubuntu-slim-garm"

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /opt/garm/scripts",
      "chmod 777 /opt/garm/scripts"
    ]
  }

  provisioner "file" {
    destination = "/opt/garm/scripts/install-linux.sh"
    source      = "${path.root}/../../garm/scripts/install-linux.sh"
  }

  provisioner "file" {
    destination = "/opt/garm/scripts/startup-linux.sh"
    source      = "${path.root}/../../garm/scripts/startup-linux.sh"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "chmod +x /opt/garm/scripts/install-linux.sh /opt/garm/scripts/startup-linux.sh",
      "/opt/garm/scripts/install-linux.sh"
    ]
  }
}
