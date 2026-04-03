locals {
  # Driver names that we want to include for Windows installation
  driver_names = [
    "Balloon",
    "NetKVM",
    "vioscsi",
    "viostor"
  ]

  # Windows version to driver path mapping
  windows_driver_versions = {
    "win22"        = "2k22"
    "win25"        = "2k25"
    "win25-vs2026" = "2k25"
  }

  image_properties_map = {
    "win22" = {
      windows_iso     = "en-us_windows_server_2022_eval_x64fre.iso"
      image_index     = "4"
      disk_size       = coalesce(var.disk_size_gb, "32G")
      base_template   = "win22-base"
      runner_template = "win22-runner"
      base_vm_id      = var.vm_ids.win22_base == 0 ? null : var.vm_ids.win22_base
      runner_vm_id    = var.vm_ids.win22_runner == 0 ? null : var.vm_ids.win22_runner
      license_key     = var.license_keys.win22
      driver_paths = [
        for driver in local.driver_names : "${driver}\\${local.windows_driver_versions["win22"]}\\amd64"
      ]
    },
    "win25" = {
      windows_iso     = "en-us_windows_server_2025_eval_x64fre.iso"
      image_index     = "4"
      disk_size       = coalesce(var.disk_size_gb, "32G")
      base_template   = "win25-base"
      runner_template = "win25-runner"
      base_vm_id      = var.vm_ids.win25_base == 0 ? null : var.vm_ids.win25_base
      runner_vm_id    = var.vm_ids.win25_runner == 0 ? null : var.vm_ids.win25_runner
      license_key     = var.license_keys.win25
      driver_paths = [
        for driver in local.driver_names : "${driver}\\${local.windows_driver_versions["win25"]}\\amd64"
      ]
    },
    "win25-vs2026" = {
      windows_iso     = "en-us_windows_server_2025_eval_x64fre.iso"
      image_index     = "4"
      disk_size       = coalesce(var.disk_size_gb, "32G")
      base_template   = "win25-vs2026-base"
      runner_template = "win25-vs2026-runner"
      base_vm_id      = var.vm_ids.win25_vs2026_base == 0 ? null : var.vm_ids.win25_vs2026_base
      runner_vm_id    = var.vm_ids.win25_vs2026_runner == 0 ? null : var.vm_ids.win25_vs2026_runner
      license_key     = var.license_keys.win25_vs2026
      driver_paths = [
        for driver in local.driver_names : "${driver}\\${local.windows_driver_versions["win25-vs2026"]}\\amd64"
      ]
    }
  }
}
