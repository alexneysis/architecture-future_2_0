variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment label: dev, stage or prod"
  type        = string
}

variable "cores" {
  description = "Number of vCPUs"
  type        = number
}

variable "memory" {
  description = "RAM in GiB"
  type        = number
}

variable "disk_size" {
  description = "Additional EBS disk size in GiB"
  type        = number
}

variable "boot_disk_size" {
  description = "Root EBS disk size in GiB"
  type        = number
  default     = 8
}

variable "vpc_cidr" {
  description = "VPC IPv4 network"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet IPv4 network inside vpc_cidr"
  type        = string
}

variable "ssh_key_path" {
  description = "Local public SSH key path; contents are passed to the module"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_cidr" {
  description = "Public IPv4/CIDR allowed to SSH; set via TF_VAR_ssh_cidr"
  type        = string
}

variable "public_ip" {
  description = "Assign a public IPv4 to the VM"
  type        = bool
  default     = true
}
