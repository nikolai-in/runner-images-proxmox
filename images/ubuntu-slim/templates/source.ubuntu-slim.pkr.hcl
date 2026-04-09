packer {
  required_plugins {
    lxc = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/lxc"
    }
  }
}



source "lxc" "ubuntu_slim" {
  config_file               = var.lxc_config_file
  template_name             = var.lxc_template_name
  template_environment_vars = var.lxc_template_env
  template_parameters       = var.lxc_template_parameters
  output_directory          = var.lxc_output_directory
  container_name            = var.lxc_container_name
  attach_options            = var.lxc_attach_options
}
