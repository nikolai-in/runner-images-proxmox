build {
  sources = [
    "source.proxmox-clone.image"
  ]
  name = "ubuntu-2404-garm"

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

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "if [ -x /usr/sbin/waagent ]; then /usr/sbin/waagent -force -deprovision+user; elif command -v cloud-init >/dev/null 2>&1; then cloud-init clean --logs --seed; fi",
      "rm -rf /var/lib/cloud/",
      "rm -f /etc/machine-id",
      "touch /etc/machine-id",
      "export HISTSIZE=0 && sync"
    ]
  }
}
