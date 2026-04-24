build {
  sources = [
    "source.proxmox-clone.image"
  ]
  name = "ubuntu-nobel-garm"

  # Pre-cache act_runner binary for GARM bootstrap compatibility
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "RUN_HOME=/home/runner/act-runner",
      "mkdir -p $RUN_HOME",
      "LATEST_RELEASE_URL=$(curl -fsSL \"https://gitea.com/api/v1/repos/gitea/act_runner/releases?limit=1\" | jq -r \".[0].assets[] | select(.name | test(\\\"act_runner-.*-linux-amd64$\\\")) | .browser_download_url\" | head -1)",
      "curl -fsSL \"$LATEST_RELEASE_URL\" -o $RUN_HOME/act_runner",
      "chmod +x $RUN_HOME/act_runner",
      "chown -R runner:runner $RUN_HOME"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      # Copy all secondary groups from installer to runner
      "for grp in $(id -nG installer | tr ' ' '\\n' | grep -v '^installer$'); do",
      "  usermod -aG \"$grp\" runner",
      "done"
    ]
  }

  # Ensure runner is added to docker group after both exist
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "if id runner >/dev/null 2>&1 && getent group docker >/dev/null 2>&1; then usermod -aG docker runner; fi"
    ]
  }

  # Symlink act_runner cache to GitHub actions cache directory for compatibility
  provisioner "shell" {
    execute_command = "sudo -u runner sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /home/runner/.cache",
      "if [ ! -e /home/runner/.cache/act ]; then ln -s /opt/actionarchivecache /home/runner/.cache/act; fi",
      "chown -h runner:runner /home/runner/.cache/act"
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
