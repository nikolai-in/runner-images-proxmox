packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
      source  = "github.com/nikolai-in/proxmox"
    }
    windows-update = {
      version = "~> 0.16.10"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "base" {

  // PROXMOX CONNECTION CONFIGURATION
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  node                     = var.node

  // BIOS & MACHINE CONFIGURATION
  bios    = "ovmf"
  machine = "q35"

  efi_config {
    efi_storage_pool  = var.efi_storage
    pre_enrolled_keys = true
    efi_type          = "4m"
  }

  // BOOT MEDIA CONFIGURATION
  boot_iso {
    iso_file         = "${var.iso_storage}:iso/${local.image_properties.windows_iso}"
    iso_storage_pool = var.iso_storage
    unmount          = true
  }

  additional_iso_files {
    iso_file         = "${var.iso_storage}:iso/${var.virtio_win_iso}"
    iso_storage_pool = var.iso_storage
    unmount          = true
    type             = "sata"
    index            = 1
  }

  additional_iso_files {
    cd_files = ["${path.root}/../scripts/build/Configure-RemotingForAnsible.ps1"]
    cd_content = {
      "autounattend.xml" = templatefile("../assets/base/unattend.pkrtpl", {
        user               = var.install_user,
        password           = var.install_password,
        cdrom_drive        = var.cdrom_drive,
        license_key        = local.image_properties.license_key,
        timezone           = var.timezone,
        index              = local.image_properties.image_index
        virtio_cdrom_drive = var.virtio_cdrom_drive
        driver_paths       = local.image_properties.driver_paths
      })
    }
    cd_label         = "Unattend"
    iso_storage_pool = var.iso_storage
    unmount          = true
    type             = "sata"
    index            = 0
  }

  // VM TEMPLATE CONFIGURATION
  template_name        = local.image_properties.base_template
  vm_id                = local.image_properties.base_vm_id
  vm_name              = "win-instance-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  template_description = "Windows ${var.image_os} Base Image\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}"
  os                   = "win11"

  // HARDWARE CONFIGURATION
  memory          = var.memory
  cores           = var.cores
  sockets         = var.socket
  cpu_type        = "host"
  scsi_controller = "virtio-scsi-pci"
  serials         = ["socket"]

  // NETWORK CONFIGURATION
  network_adapters {
    model  = "virtio"
    bridge = var.bridge
  }

  // STORAGE CONFIGURATION
  disks {
    storage_pool = var.disk_storage
    type         = "scsi"
    disk_size    = local.image_properties.disk_size
    cache_mode   = "writeback"
    format       = "raw"
  }

  // WINRM COMMUNICATION CONFIGURATION
  communicator   = "winrm"
  winrm_username = var.install_user
  winrm_password = var.install_password
  winrm_timeout  = "1h"
  winrm_port     = "5986"
  winrm_use_ssl  = true
  winrm_insecure = true

  // BOOT CONFIGURATION
  boot         = "order=scsi0"
  boot_wait    = "3s"
  boot_command = ["<enter><enter>", "\\efi\\boot\\bootx64.efi<enter><wait>", "<enter>"]
}

source "proxmox-clone" "runner" {
  // PROXMOX CONNECTION CONFIGURATION
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = true
  username                 = var.proxmox_user
  password                 = var.proxmox_password
  node                     = var.node

  // CLONE CONFIGURATION
  clone_vm                = local.image_properties.base_template
  full_clone              = false
  vm_id                   = local.image_properties.runner_vm_id
  vm_name                 = "win-instance-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  template_name           = local.image_properties.runner_template
  template_description    = "Windows ${var.image_os} Runner VM cloned from base template\nCreated on: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", timestamp())}"
  os                      = "win11"
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage

  // EFI & SECURE BOOT CONFIGURATION
  // pre_enrolled_keys = false disables Secure Boot on the runner VM so that
  // bcdedit.exe /set TESTSIGNING ON and other low-level modifications succeed.
  efi_config {
    efi_storage_pool  = var.efi_storage
    pre_enrolled_keys = false
    efi_type          = "4m"
  }

  // HARDWARE CONFIGURATION
  memory          = var.memory
  cores           = var.cores
  sockets         = var.socket
  cpu_type        = "host"
  scsi_controller = "virtio-scsi-pci"

  // NETWORK CONFIGURATION
  network_adapters {
    model  = "virtio"
    bridge = var.bridge
  }

  // IMAGE FILES ISO - scripts, toolsets, and assets delivered via CD-ROM.
  // Avoids slow per-file WinRM uploads; the ISO is mounted before the VM
  // starts and unmounted at the end of the build.
  additional_iso_files {
    cd_files = [
      "${path.root}/../scripts/",
      "${path.root}/../toolsets/",
      "${path.root}/../assets/",
      "${path.root}/../../../helpers/software-report-base/"
    ]
    cd_label         = "ImageFiles"
    iso_storage_pool = var.iso_storage
    unmount          = true
    type             = "sata"
    index            = 0
  }

  // COMMUNICATION CONFIGURATION
  communicator   = "winrm"
  winrm_username = var.install_user
  winrm_password = var.install_password
  winrm_timeout  = "30m"
  winrm_port     = "5986"
  winrm_use_ssl  = true
  winrm_insecure = true

  // OS DISK - resized to runner target size using packer-plugin-proxmox index
  // feature (github.com/nikolai-in/proxmox fork, PR #324).  Specifying index = "0"
  // causes the plugin to configure scsi0 at the target size on the cloned VM.
  // Expand-RunnerDisk.ps1 then extends the C: partition inside Windows.
  disks {
    storage_pool = var.disk_storage
    type         = "scsi"
    disk_size    = var.runner_disk_size_gb
    cache_mode   = "writeback"
    format       = "raw"
    index        = "0"
  }

  // DISK FOR TEMP DIR
  disks {
    storage_pool = var.disk_storage
    type         = "scsi"
    disk_size    = "128G"
    cache_mode   = "unsafe"
    format       = "raw"
  }
}

source "null" "winrm" {
  // DEBUG SOURCE - Connect to existing Windows VM via WinRM for rapid provisioner testing
  //
  // This source allows you to test provisioners on an existing VM without rebuilding.
  // To use this source instead of the default Proxmox sources, use Packer's -only flag:
  //
  // Examples:
  // packer build -only="*.null.winrm" -var="winrm_host=192.168.1.100" .
  // packer build -only="windows-2022.null.winrm" -var="winrm_host=my-test-vm" .
  //
  // Prerequisites:
  // - Existing Windows VM with WinRM enabled on port 5986 (SSL)
  // - Same credentials as specified in install_user/install_password variables
  // - VM should be in a clean state for repeatable testing

  communicator   = "winrm"
  winrm_username = var.install_user
  winrm_password = var.install_password
  winrm_timeout  = "30m"
  winrm_port     = "5986"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_host     = var.winrm_host
}


