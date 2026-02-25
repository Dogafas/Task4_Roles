# Ansible Playbook: Clickhouse + Vector + Lighthouse

Ansible playbook для развертывания стека мониторинга и аналитики логов, включающего Clickhouse, Vector и Lighthouse.

## Описание

Playbook устанавливает и настраивает:
- **Clickhouse** - колоночная СУБД для аналитики
- **Vector** - агент для сбора и обработки логов
- **Lighthouse** - веб-интерфейс для Clickhouse

## Требования

- Ansible >= 2.10
- Python >= 3.6
- Целевые хосты: Ubuntu/Debian или CentOS/RHEL

## Структура проекта

```
playbook/
├── site.yml              # Основной playbook
├── requirements.yml      # Зависимости ролей
├── inventory/           # Инвентарь хостов
├── group_vars/          # Переменные групп
│   └── clickhouse/
│       └── vars.yml
└── roles/               # Роли
    ├── clickhouse/
    ├── vector-role/
    └── lighthouse-role/
```

## Установка

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd playbook
```

2. Установите зависимые роли:
```bash
ansible-galaxy install -r requirements.yml
```

## Настройка

1. Создайте inventory файл с вашими хостами:
```ini
[clickhouse]
clickhouse-01 ansible_host=<IP>

[vector]
vector-01 ansible_host=<IP>

[lighthouse]
lighthouse-01 ansible_host=<IP>
```

2. Настройте переменные в `group_vars/` при необходимости

## Использование

Запуск playbook:
```bash
ansible-playbook -i inventory/prod.yml site.yml
```

С проверкой (check mode):
```bash
ansible-playbook -i inventory/prod.yml site.yml --check
```

Для конкретной группы хостов:
```bash
ansible-playbook -i inventory/prod.yml site.yml --limit clickhouse
```

## Роли

### Clickhouse
- Версия: 1.13
- Источник: [ansible-clickhouse](https://github.com/AlexeySetevoi/ansible-clickhouse)
- Устанавливает Clickhouse версии 22.3.3.44

### Vector
- Версия: v1.0.2
- Источник: [vector-role](https://github.com/Dogafas/vector-role)
- Настраивает агент для сбора логов

### Lighthouse
- Версия: v1.0.1
- Источник: [lighthouse-role](https://github.com/Dogafas/lighthouse-role)
- Устанавливает веб-интерфейс для Clickhouse

## Переменные

Основные переменные настраиваются в `group_vars/clickhouse/vars.yml`:
- `clickhouse_version` - версия Clickhouse
- `clickhouse_packages` - список устанавливаемых пакетов

## Лицензия

MIT
