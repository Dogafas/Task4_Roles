# Ansible Playbook: ClickHouse, Lighthouse и Vector

Этот playbook автоматизирует установку и настройку трех компонентов:
- **ClickHouse** - колоночная СУБД для аналитики
- **Lighthouse** - веб-интерфейс для ClickHouse
- **Vector** - инструмент для сбора и обработки логов

## Описание

Playbook состоит из трех plays:

1. **Install ClickHouse** - устанавливает ClickHouse на хосты группы `clickhouse`
2. **Install Lighthouse** - устанавливает Lighthouse с nginx на хосты группы `lighthouse`
3. **Install Vector** - устанавливает и настраивает Vector на хосты группы `vector`

## Требования

- Ansible 2.9+
- Целевые хосты на базе Debian/Ubuntu
- SSH доступ с правами sudo
- Интернет-соединение для загрузки пакетов

## Структура

```
playbook/
├── site.yml                    # Основной playbook
├── inventory/
│   └── prod.yml               # Inventory файл
├── group_vars/
│   ├── clickhouse/
│   │   └── vars.yml           # Переменные для ClickHouse
│   ├── lighthouse/
│   │   └── vars.yml           # Переменные для Lighthouse
│   └── vector/
│       └── vars.yml           # Переменные для Vector
└── templates/
    ├── lighthouse.conf.j2     # Конфигурация nginx для Lighthouse
    ├── vector.service.j2      # Systemd unit для Vector
    └── vector.yml.j2          # Конфигурация Vector
```

## Параметры (Переменные)

### ClickHouse (`group_vars/clickhouse/vars.yml`)

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `clickhouse_version` | `"22.3.3.44"` | Версия ClickHouse |
| `clickhouse_packages` | `[...]` | Список пакетов для установки |
| `clickhouse_keyring_path` | `/usr/share/keyrings/clickhouse-keyring.gpg` | Путь к GPG ключу |
| `clickhouse_repo_path` | `/etc/apt/sources.list.d/clickhouse.list` | Путь к файлу репозитория |

### Lighthouse (`group_vars/lighthouse/vars.yml`)

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `lighthouse_repo_url` | `https://github.com/VKCOM/lighthouse/archive/refs/heads/master.zip` | URL архива Lighthouse |
| `lighthouse_install_dir` | `/usr/share/nginx/html` | Директория установки |
| `lighthouse_web_root` | `/usr/share/nginx/html/lighthouse-master` | Корневая директория веб-сервера |
| `lighthouse_nginx_conf` | `/etc/nginx/conf.d/lighthouse.conf` | Путь к конфигурации nginx |

### Vector (`group_vars/vector/vars.yml`)

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `vector_version` | `"0.30.0"` | Версия Vector |
| `vector_archive_url` | `https://github.com/...` | URL архива Vector |
| `vector_bin_path` | `/usr/local/bin/vector` | Путь к бинарному файлу |
| `vector_config_dir` | `/etc/vector` | Директория конфигурации |
| `vector_data_dir` | `/var/lib/vector` | Директория данных |

## Использование

### Базовый запуск

```bash
ansible-playbook -i inventory/prod.yml site.yml
```

### Проверка без изменений (check mode)

```bash
ansible-playbook -i inventory/prod.yml site.yml --check
```

### Запуск с отображением изменений

```bash
ansible-playbook -i inventory/prod.yml site.yml --diff
```

### Запуск с ограничением по хостам

```bash
ansible-playbook -i inventory/prod.yml site.yml --limit clickhouse
```

## Теги

В текущей версии playbook теги не реализованы. Для выборочного запуска используйте опцию `--limit` с указанием группы хостов.

## Идемпотентность

Playbook спроектирован идемпотентным - повторный запуск не вносит изменений, если система уже в целевом состоянии.

Проверка идемпотентности:

```bash
# Первый запуск
ansible-playbook -i inventory/prod.yml site.yml --diff

# Повторный запуск - не должно быть изменений (changed=0)
ansible-playbook -i inventory/prod.yml site.yml --diff
```

## Что делает каждый play

### Play 1: Install ClickHouse

1. Устанавливает необходимые пакеты (apt-transport-https, ca-certificates, curl, gnupg)
2. Загружает GPG ключ репозитория ClickHouse
3. Добавляет APT репозиторий ClickHouse
4. Устанавливает пакеты ClickHouse (client, server, common-static)
5. Запускает и включает сервис clickhouse-server

### Play 2: Install Lighthouse

1. Устанавливает nginx и unzip
2. Загружает архив Lighthouse с GitHub
3. Распаковывает архив в `/usr/share/nginx/html`
4. Настраивает nginx через шаблон `lighthouse.conf.j2`
5. Удаляет дефолтную конфигурацию nginx
6. Запускает nginx
7. Handler перезапускает nginx при изменении конфигурации

### Play 3: Install Vector

1. Создает директорию `/opt/vector`
2. Загружает и распаковывает архив Vector
3. Копирует бинарный файл в `/usr/local/bin/vector`
4. Создает systemd unit из шаблона `vector.service.j2`
5. Запускает и включает сервис vector
6. Handler перезапускает vector при изменении конфигурации

## Handlers

- **Restart nginx** - перезапускает nginx при изменении конфигурации Lighthouse
- **Restart vector** - перезапускает vector при изменении конфигурации или systemd unit

## Примечания

- Playbook использует модули: `apt`, `shell`, `copy`, `get_url`, `unarchive`, `file`, `template`, `service`, `systemd`
- Все операции выполняются с повышенными привилегиями (`become: true`)
- Конфигурация Vector настроена на чтение логов из journald и вывод в консоль
- В шаблоне Vector есть закомментированный пример отправки логов в ClickHouse
