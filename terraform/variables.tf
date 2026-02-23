variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "service_account_key_file" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "each_vm" {
  type = list(object({
    name        = string
    platform_id = string
    cores       = number
    memory      = number
    disk_size   = number
  }))
}

variable "public_key_path" {
  description = "Путь к публичному SSH ключу для создания ВМ"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_key_path" {
  description = "Путь к приватному SSH ключу для Ansible"
  type        = string
  default     = "~/.ssh/id_ed25519"   
}


