# Terraform Configuration for Yandex Cloud

## Описание

Terraform конфигурация для автоматического развертывания инфраструктуры в Yandex Cloud и последующей настройки через Ansible.

Создаются 3 виртуальные машины:
- **clickhouse-01** - сервер ClickHouse
- **vector-01** - сервер Vector
- **lighthouse-01** - сервер Lighthouse

## Требования

- Terraform >= 1.0
- Yandex Cloud CLI
- Ansible
- SSH ключи

## Подготовка

1. Создайте сервисный аккаунт в Yandex Cloud с правами `editor`
2. Создайте авторизованный ключ для сервисного аккаунта
3. Сгенерируйте SSH ключи (если еще не созданы):
```bash
ssh-keygen -t ed25519
```

## Настройка

1. Скопируйте файл с примером переменных:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Отредактируйте `terraform.tfvars`:
```hcl
cloud_id                 = "your-cloud-id"
folder_id                = "your-folder-id"
service_account_key_file = "/path/to/key.json"
public_key_path          = "~/.ssh/id_ed25519.pub"
private_key_path         = "~/.ssh/id_ed25519"
```

## Использование

### Инициализация
```bash
terraform init
```

### Проверка плана
```bash
terraform plan
```

### Применение конфигурации
```bash
terraform apply
```

После применения автоматически:
- Создаются VM в Yandex Cloud
- Генерируется Ansible inventory файл
- Устанавливаются роли из requirements.yml
- Запускается Ansible playbook для настройки серверов

### Просмотр IP адресов
```bash
terraform output vm_ips
```

### Удаление инфраструктуры
```bash
terraform destroy
```

## Структура файлов

- `main.tf` - основная конфигурация
- `variables.tf` - определение переменных
- `terraform.tfvars` - значения переменных (не в git)
- `inventory.tftpl` - шаблон для Ansible inventory

## Outputs

- `vm_ips` - публичные IP адреса созданных VM
