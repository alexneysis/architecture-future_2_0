variable "name" {
  description = "VM name and prefix for related resources"
  type        = string
}

variable "cores" {
  description = "Number of vCPUs; supported pairs are documented in README"
  type        = number
}

variable "memory" {
  description = "RAM in GiB"
  type        = number
}

variable "disk_size" {
  description = "Additional EBS volume size in GiB"
  type        = number
  validation {
    condition     = var.disk_size >= 1 && floor(var.disk_size) == var.disk_size
    error_message = "disk_size must be a positive integer."
  }
}

variable "subnet_id" {
  description = "Existing subnet ID; determines the VPC and availability zone"
  type        = string
}

variable "ssh_key" {
  description = "Contents of the public SSH key; never the private key"
  type        = string
}

variable "ssh_cidr" {
  description = "IPv4 CIDR allowed to connect over SSH, usually your IP/32"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid IPv4 CIDR."
  }
}

variable "image_id" {
  description = "AMI ID in the provider region; must support x86_64 and T3"
  type        = string
}

variable "boot_disk_size" {
  description = "Root EBS volume size in GiB; must meet the AMI minimum"
  type        = number
  default     = 8
  validation {
    condition     = var.boot_disk_size >= 8 && floor(var.boot_disk_size) == var.boot_disk_size
    error_message = "boot_disk_size must be an integer of at least 8 GiB."
  }
}

variable "public_ip" {
  description = "Assign a public IPv4; requires a public subnet for internet access"
  type        = bool
  default     = true
}
