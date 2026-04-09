build {
  sources = ["source.lxc.ubuntu_slim"]
  name    = "ubuntu-slim"

  provisioner "shell" {
    inline = [
      "mkdir -p ${var.image_folder} ${var.helper_script_folder} ${var.installer_script_folder}",
      "chmod 777 ${var.image_folder} ${var.helper_script_folder} ${var.installer_script_folder}"
    ]
  }

  provisioner "file" {
    destination = "${var.helper_script_folder}"
    source      = "${path.root}/../scripts/helpers"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/../scripts/build"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/../toolsets"
  }

  provisioner "shell" {
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "find ${var.installer_script_folder} -name \"*.sh\" -type f -exec chmod +x {} \\;",
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get install -y sudo lsb-release jq dpkg",
      "touch /run/.containerenv"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/configure-apt-sources.sh",
      "${path.root}/../scripts/build/configure-apt.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}",
      "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/install-apt-vital.sh",
      "${path.root}/../scripts/build/install-ms-repos.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "IMAGEDATA_NAME=${var.imagedata_name}",
      "IMAGEDATA_INCLUDED_SOFTWARE=${var.imagedata_included_software}",
      "IMAGE_VERSION=${var.image_version}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/configure-image-data-file.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "IMAGE_VERSION=${var.image_version}",
      "IMAGE_OS=${var.image_os}",
      "HELPER_SCRIPTS=${var.helper_script_folder}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/configure-environment.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}",
      "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/install-actions-cache.sh",
      "${path.root}/../scripts/build/install-apt-common.sh",
      "${path.root}/../scripts/build/install-azcopy.sh",
      "${path.root}/../scripts/build/install-azure-cli.sh",
      "${path.root}/../scripts/build/install-azure-devops-cli.sh",
      "${path.root}/../scripts/build/install-bicep.sh",
      "${path.root}/../scripts/build/install-aws-tools.sh",
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      "${path.root}/../scripts/build/install-google-cloud-cli.sh",
      "${path.root}/../scripts/build/install-nvm.sh",
      "${path.root}/../scripts/build/install-nodejs.sh",
      "${path.root}/../scripts/build/install-powershell.sh",
      "${path.root}/../scripts/build/configure-dpkg.sh",
      "${path.root}/../scripts/build/install-yq.sh",
      "${path.root}/../scripts/build/install-python.sh",
      "${path.root}/../scripts/build/install-zstd.sh",
      "${path.root}/../scripts/build/install-pipx-packages.sh",
      "${path.root}/../scripts/build/install-docker-cli.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}",
      "IMAGE_FOLDER=${var.image_folder}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/configure-system.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/helpers/cleanup.sh"
    ]
  }
}
