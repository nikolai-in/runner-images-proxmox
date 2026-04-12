build {
  name    = "ubuntu-slim"
  sources = ["source.proxmox-lxc.image"]

  provisioner "shell" {
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p ${var.image_folder}",
      "mkdir -p ${var.helper_script_folder}",
      "mkdir -p ${var.installer_script_folder}",
      "chmod 777 ${var.image_folder}"
    ]
  }

  provisioner "file" {
    destination = "${var.image_folder}"
    source      = "${path.root}/../scripts/helpers"
  }



  provisioner "file" {
    destination = "${var.installer_script_folder}/toolset.json"
    source      = "${path.root}/../toolsets/toolset.json"
  }

  provisioner "file" {
    destination = "${var.image_folder}/docs-gen"
    source      = "${path.root}/../scripts/docs-gen"
  }

  provisioner "file" {
    destination = "${var.image_folder}/software-report-base"
    source      = "${path.root}/../../../helpers/software-report-base"
  }

  provisioner "shell" {
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /run",
      "touch /run/.containerenv",
      "DEBIAN_FRONTEND=noninteractive apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y sudo lsb-release jq dpkg curl ca-certificates gnupg unzip"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "HELPER_SCRIPTS=${var.helper_script_folder}",
      "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}",
      "IMAGE_FOLDER=${var.image_folder}",
      "IMAGE_VERSION=${var.image_version}",
      "IMAGE_OS=${var.image_os}",
      "IMAGE_OWNER=${var.image_owner}",
      "IMAGE_TARGET_PLATFORM=${var.image_target_platform}",
      "IMAGEDATA_NAME=${var.imagedata_name}",
      "IMAGEDATA_INCLUDED_SOFTWARE=${var.imagedata_included_software}",
      "NVM_DIR=${var.nvm_dir}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "${path.root}/../scripts/build/configure-apt-sources.sh",
      "${path.root}/../scripts/build/configure-apt.sh",
      "${path.root}/../scripts/build/install-apt-vital.sh",
      "${path.root}/../scripts/build/install-ms-repos.sh",
      "${path.root}/../scripts/build/configure-image-data-file.sh",
      "${path.root}/../scripts/build/configure-environment.sh",
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
      "${path.root}/../scripts/build/install-docker-cli.sh",
      "${path.root}/../scripts/build/configure-system.sh",
      "${path.root}/../scripts/helpers/cleanup.sh"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "IMAGE_VERSION=${var.image_version}",
      "IMAGE_OS=${var.image_os}",
      "IMAGEDATA_NAME=${var.imagedata_name}",
      "IMAGEDATA_INCLUDED_SOFTWARE=${var.imagedata_included_software}"
    ]
    execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p ${var.image_folder}/output",
      "pwsh -File \"${var.image_folder}/docs-gen/Generate-SoftwareReport.ps1\" -OutputDirectory \"${var.image_folder}/output\""
    ]
  }

  provisioner "file" {
    direction   = "download"
    source      = "${var.image_folder}/output/software-report.md"
    destination = "${path.root}/../ubuntu-slim-Readme.md"
  }

  provisioner "file" {
    direction   = "download"
    source      = "${var.image_folder}/output/software-report.json"
    destination = "${path.root}/../ubuntu-slim-Report.json"
  }


}
