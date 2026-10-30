terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.162.0, < 1.0.0"
    }
  }
}

resource "yandex_compute_disk" "data" {
  name = "${var.name}-data"
  zone = var.zone
  size = var.disk_size
  type = var.disk_type
}

resource "yandex_compute_instance" "vm" {
  name        = var.name
  zone        = var.zone
  platform_id = var.platform_id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.boot_disk_size
      type     = var.disk_type
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.data.id
    auto_delete = false
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    "ssh-keys" = "${var.ssh_user}:${var.ssh_key}"
  }
}