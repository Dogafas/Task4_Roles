# Terraform: Инфраструктура для Ansible Playbook

Terraform конфигурация для автоматического развертывания инфраструктуры в Yandex Cloud и запуска Ansible playbook.

## Описание

Конфигурация создает три виртуальные машины в Yandex Cloud:
- **clickhouse-01** - для ClickHouse СУБД
- **vector-01** - для Vector (сбор логов)
- **lighthouse-01** - для Lighthouse (веб-интерфейс)

После создания инфраструктуры автоматически:
1. Генерируется Ansible inventory файл `prod.yml`
2. Запускается Ansible playbook для установки и настройки сервисов

## Требования

- Terraform 1.0+
- Yandex Cloud аккаунт
- Service Account с правами на создание ресурсов
- SSH ключи для доступа к ВМ
- Ansible 2.9+ (для автоматического provisioning)

## Структура

```
terraform/
├── main.tf                    # Основная конфигурация
├── variables.tf               # Определение переменных
├── terraform.tfvars           # Значения переменных (не в git)
├── terraform.tfvars.example   # Пример файла переменных
├── inventory.tftpl            # Шаблон Ansible inventory
└── .gitignore                 # Исключения для git
```

## Параметры (Переменные)

### Обязательные переменные

| Переменная | Тип | Описание |
|------------|-----|----------|
| `cloud_id` | string | ID облака Yandex Cloud |
| `folder_id` | string | ID каталога Yandex Cloud |
| `service_account_key_file` | string | Путь к JSON файлу с ключом сервисного аккаунта |
| `each_vm` | list(object) | Список ВМ с параметрами (name, platform_id, cores, memory, disk_size) |

### Опциональные переменные

| Переменная | Тип | Значение по умолчанию | Описание |
|------------|-----|----------------------|----------|
| `default_zone` | string | `"ru-central1-a"` | Зона доступности |
| `public_key_path` | string | `"~/.ssh/id_ed25519.pub"` | Путь к публичному SSH ключу |
| `private_key_path` | string | `"~/.ssh/id_ed25519"` | Путь к приватному SSH ключу |

## Настройка

### 1. Создайте файл terraform.tfvars

```hcl
cloud_id                 = "your-cloud-id"
folder_id                = "your-folder-id"
service_account_key_file = "/path/to/key.json"
public_key_path          = "~/.ssh/id_ed25519.pub"
private_key_path         = "~/.ssh/id_ed25519"

each_vm = [
  {
    name        = "clickhouse-01"
    platform_id = "standard-v3"
    cores       = 2
    memory      = 4
    disk_size   = 10
  },
  {
    name        = "vector-01"
    platform_id = "standard-v3"
    cores       = 2
    memory      = 2
    disk_size   = 10
  },
  {
    name        = "lighthouse-01"
    platform_id = "standard-v3"
    cores       = 2
    memory      = 2
    disk_size   = 10
  }
]
```

### 2. Инициализация

```bash
terraform init
```

### 3. Проверка плана

```bash
terraform plan
```

### 4. Применение конфигурации

```bash
terraform apply
```

## Создаваемые ресурсы

### Yandex Cloud

- **yandex_vpc_network.default** - виртуальная сеть
- **yandex_vpc_subnet.default** - подсеть 10.0.0.0/24
- **yandex_compute_instance.vm** - 3 виртуальные машины (Ubuntu)

### Локальные ресурсы

- **local_file.ansible_inventory** - генерирует `playbook/inventory/prod.yml`
- **null_resource.ansible_provisioner** - запускает Ansible playbook

## Outputs

| Output | Описание |
|--------|----------|
| `vm_ips` | Map с именами ВМ и их внешними IP адресами |

Пример вывода:
```
vm_ips = {
  "clickhouse-01" = "51.250.x.x"
  "lighthouse-01" = "51.250.x.x"
  "vector-01" = "51.250.x.x"
}
```

## Особенности

### Автоматический provisioning

После создания ВМ автоматически запускается Ansible playbook:
- Ожидание 60 секунд для инициализации ВМ
- Отключение проверки SSH host keys
- Запуск `ansible-playbook` с сгенерированным inventory

### Генерация inventory

Шаблон `inventory.tftpl` автоматически создает Ansible inventory с:
- IP адресами всех ВМ
- Настройками SSH подключения
- Параметрами sudo

### Образ ВМ

Используется образ Ubuntu: `fd80bm0rh4rkepi5ksdi`

### Сетевые настройки

- Все ВМ получают внешние IP (NAT enabled)
- Внутренняя сеть: 10.0.0.0/24
- SSH доступ через пользователя `yc-user`

## Управление

### Просмотр состояния

```bash
terraform show
```

### Просмотр outputs

```bash
terraform output
```

### Уничтожение инфраструктуры

```bash
terraform destroy
```

### Обновление отдельного ресурса

```bash
terraform apply -target=yandex_compute_instance.vm[\"clickhouse-01\"]
```

## Теги (Tags)

В текущей конфигурации теги не используются. Для добавления тегов к ресурсам Yandex Cloud можно использовать параметр `labels`:

```hcl
resource "yandex_compute_instance" "vm" {
  # ...
  labels = {
    environment = "production"
    project     = "ansible-playbook"
    managed_by  = "terraform"
  }
}
```

## Безопасность

⚠️ **Важно:**
- Файл `terraform.tfvars` содержит чувствительные данные и исключен из git
- Не коммитьте файлы с ключами (*.json, *.key, *.pem)
- Service Account должен иметь минимально необходимые права
- SSH ключи должны быть защищены правами доступа 600

## Troubleshooting

### Ошибка подключения к Yandex Cloud

Проверьте:
- Корректность `cloud_id` и `folder_id`
- Валидность service account key
- Права сервисного аккаунта

### Ansible provisioner не запускается

- Убедитесь, что Ansible установлен
- Проверьте доступность ВМ по SSH
- Увеличьте время ожидания (sleep) в provisioner

### ВМ не создаются

- Проверьте квоты в Yandex Cloud
- Убедитесь в доступности зоны `ru-central1-a`
- Проверьте корректность platform_id
