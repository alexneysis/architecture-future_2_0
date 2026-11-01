terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.162.0, < 1.0.0"
    }
  }
}

# Параметры аутентификации берутся из переменных окружения YC_*.
provider "yandex" {}

module "vm_module" {
  source = "../../modules/vm"

  name           = var.name
  zone           = var.zone
  cores          = var.cores
  memory         = var.memory
  image_id       = var.image_id
  boot_disk_size = var.boot_disk_size
  disk_size      = var.disk_size
  disk_type      = var.disk_type
  subnet_id      = var.subnet_id
  ssh_key        = var.ssh_key
  ssh_user       = var.ssh_user
  platform_id    = var.platform_id
  nat            = var.nat
}