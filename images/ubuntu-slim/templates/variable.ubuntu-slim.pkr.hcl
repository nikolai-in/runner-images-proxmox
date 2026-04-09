variable "image_version" {
  type        = string
  description = "Semantic version for the image"
  default     = "dev"
}

variable "image_os" {
  type        = string
  description = "Image flavor identifier"
  default     = "Linux"
}

variable "image_folder" {
  type        = string
  description = "Root folder used for image generation artifacts"
  default     = "/imagegeneration"
}

variable "helper_script_folder" {
  type        = string
  description = "Path where helper scripts are placed"
  default     = "/imagegeneration/helpers"
}

variable "installer_script_folder" {
  type        = string
  description = "Path where installer scripts and toolsets are placed"
  default     = "/imagegeneration/installers"
}

variable "imagedata_file" {
  type        = string
  description = "Path to the imagedata JSON file"
  default     = "/imagegeneration/imagedata.json"
}

variable "imagedata_name" {
  type        = string
  description = "IMAGEDATA_NAME value used in the image metadata"
  default     = "ubuntu:24.04-slim"
}

variable "imagedata_source" {
  type        = string
  description = "IMAGEDATA_SOURCE value used in the image metadata"
  default     = "LXC"
}

variable "imagedata_included_software" {
  type        = string
  description = "Optional IMAGEDATA_INCLUDED_SOFTWARE string"
  default     = ""
}

variable "lxc_config_file" {
  type        = string
  description = "Path to LXC config file for lxc-create"
  default     = "lxc.conf"
}

variable "lxc_template_name" {
  type        = string
  description = "LXC template to use (e.g. ubuntu, debian)"
  default     = "download"
}

variable "lxc_template_env" {
  type        = list(string)
  description = "Environment variables for the LXC template"
  default     = ["SUITE=noble"]
}





variable "lxc_template_parameters" {
  type        = list(string)
  description = "Parameters to pass to the LXC template script"
  default     = ["-d", "ubuntu", "-r", "noble", "-a", "amd64"]
}

variable "lxc_attach_options" {
  type        = list(string)
  description = "Options passed to lxc-attach"
  default     = ["--clear-env"]
}

variable "lxc_output_directory" {
  type        = string
  description = "Directory where the LXC rootfs tarball is exported"
  default     = "output-ubuntu-slim-lxc"
}

variable "lxc_container_name" {
  type        = string
  description = "Name of the transient LXC container used for build"
  default     = "ubuntu-slim"
}
