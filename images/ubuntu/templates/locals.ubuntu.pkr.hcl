locals {
  image_properties_map = {
    "ubuntu22" = {
      base_template   = "ubuntu22-base"
      runner_template = "ubuntu22-runner"
      disk_size       = coalesce(var.disk_size_gb, "75G")
      runner_vm_id    = var.vm_ids.ubuntu22_runner == 0 ? null : var.vm_ids.ubuntu22_runner
    },
    "ubuntu24" = {
      base_template   = "ubuntu24-base"
      runner_template = "ubuntu24-runner"
      disk_size       = coalesce(var.disk_size_gb, "75G")
      runner_vm_id    = var.vm_ids.ubuntu24_runner == 0 ? null : var.vm_ids.ubuntu24_runner
    }
  }

  image_properties = local.image_properties_map[var.image_os]
}
