variable "name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "zone" {
  description = "Зона доступности; должна совпадать с зоной подсети"
  type        = string
}

variable "cores" {
  description = "Количество vCPU"
  type        = number

  validation {
    condition     = var.cores >= 2 && floor(var.cores) == var.cores
    error_message = "Количество vCPU должно быть целым числом не меньше 2."
  }
}

variable "memory" {
  description = "Объем RAM в ГБ"
  type        = number
}

variable "image_id" {
  description = "ID образа операционной системы"
  type        = string
}

variable "boot_disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20
}

variable "disk_size" {
  description = "Размер дополнительного диска в ГБ"
  type        = number
}

variable "disk_type" {
  description = "Тип загрузочного и дополнительного дисков"
  type        = string
  default     = "network-hdd"
}

variable "subnet_id" {
  description = "ID существующей подсети"
  type        = string
}

variable "ssh_key" {
  description = "Содержимое публичного SSH-ключа"
  type        = string
}

variable "ssh_user" {
  description = "Пользователь для SSH; должен поддерживаться образом ОС"
  type        = string
  default     = "ubuntu"
}

variable "platform_id" {
  description = "Аппаратная платформа ВМ"
  type        = string
  default     = "standard-v3"
}

variable "nat" {
  description = "Назначить ВМ публичный IP"
  type        = bool
  default     = false
}