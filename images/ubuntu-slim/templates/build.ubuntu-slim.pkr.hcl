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
      "${var.installer_script_folder}/build/configure-apt-sources.sh",
      "${var.installer_script_folder}/build/configure-apt.sh"
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
      "${var.installer_script_folder}/build/install-apt-vital.sh",
      "${var.installer_script_folder}/build/install-ms-repos.sh"
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
      "${var.installer_script_folder}/build/configure-image-data-file.sh"
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
      "${var.installer_script_folder}/build/configure-environment.sh"
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
      "${var.installer_script_folder}/build/install-actions-cache.sh",
      "${var.installer_script_folder}/build/install-apt-common.sh",
      "${var.installer_script_folder}/build/install-azcopy.sh",
      "${var.installer_script_folder}/build/install-azure-cli.sh",
      "${var.installer_script_folder}/build/install-azure-devops-cli.sh",
      "${var.installer_script_folder}/build/install-bicep.sh",
      "${var.installer_script_folder}/build/install-aws-tools.sh",
      "${var.installer_script_folder}/build/install-git.sh",
      "${var.installer_script_folder}/build/install-git-lfs.sh",
      "${var.installer_script_folder}/build/install-github-cli.sh",
      "${var.installer_script_folder}/build/install-google-cloud-cli.sh",
      "${var.installer_script_folder}/build/install-nvm.sh",
      "${var.installer_script_folder}/build/install-nodejs.sh",
      "${var.installer_script_folder}/build/install-powershell.sh",
      "${var.installer_script_folder}/build/configure-dpkg.sh",
      "${var.installer_script_folder}/build/install-yq.sh",
      "${var.installer_script_folder}/build/install-python.sh",
      "${var.installer_script_folder}/build/install-zstd.sh",
      "${var.installer_script_folder}/build/install-pipx-packages.sh",
      "${var.installer_script_folder}/build/install-docker-cli.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}",
      "IMAGE_FOLDER=${var.image_folder}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${var.installer_script_folder}/build/configure-system.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${var.helper_script_folder}/cleanup.sh"
    ]
  }
}
