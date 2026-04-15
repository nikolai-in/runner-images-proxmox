locals {
  image_properties_map = {
    "ubuntu22" = {
      base_template   = var.base_template_ubuntu22 != "" ? var.base_template_ubuntu22 : "ubuntu-2204-base"
      runner_template = "ubuntu-2204"
      runner_vm_id    = var.vm_ids.ubuntu22_runner == 0 ? null : var.vm_ids.ubuntu22_runner
      disk_size       = coalesce(var.disk_size_gb, "75G")
    },
    "ubuntu24" = {
      base_template   = var.base_template_ubuntu24 != "" ? var.base_template_ubuntu24 : "ubuntu-2404-base"
      runner_template = "ubuntu-2404"
      runner_vm_id    = var.vm_ids.ubuntu24_runner == 0 ? null : var.vm_ids.ubuntu24_runner
      disk_size       = coalesce(var.disk_size_gb, "75G")
    },
    "ubuntu24-garm" = {
      base_template   = "ubuntu-2404"
      runner_template = "ubuntu-2404-garm"
      runner_vm_id    = var.vm_ids.ubuntu24_garm_runner == 0 ? null : var.vm_ids.ubuntu24_garm_runner
      disk_size       = coalesce(var.disk_size_gb, "75G")
    }
  }

  image_properties = local.image_properties_map[var.image_os]
}
