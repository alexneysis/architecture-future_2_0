# Задание 1. Модульная инфраструктура

## Назначение

Модуль `modules/vm` создаёт в Yandex Cloud:
- виртуальную машину с загрузочным диском;
- отдельный дополнительный диск;
- сетевой интерфейс в существующей подсети;
- настройку доступа по публичному SSH-ключу.

Окружения dev, stage и prod используют один модуль.
Различия задаются через отдельные файлы `.tfvars`.

## Параметры модуля

| Параметр | Назначение | Значение по умолчанию |
|---|---|---|
| name | Имя ВМ | Обязательный |
| zone | Зона доступности | Обязательный |
| cores | Количество vCPU | Обязательный |
| memory | RAM, ГБ | Обязательный |
| image_id | ID образа ОС | Обязательный |
| boot_disk_size | Загрузочный диск, ГБ | 20 |
| disk_size | Дополнительный диск, ГБ | Обязательный |
| disk_type | Тип дисков | network-ssd |
| subnet_id | ID существующей подсети | Обязательный |
| ssh_key | Публичный SSH-ключ | Обязательный |
| ssh_user | Пользователь для SSH | ubuntu |
| platform_id | Аппаратная платформа | standard-v3 |
| nat | Назначение публичного IP | false |

## Конфигурации окружений

| Окружение | vCPU | RAM, ГБ | Дополнительный диск, ГБ | Публичный IP |
|---|---|---|---|---|
| dev | 2 | 2 | 20 | Да |
| stage | 4 | 4 | 50 | Да |
| prod | 8 | 16 | 100 | Нет |

## Выходы

Модуль возвращает:
- `vm_id` — ID ВМ;
- `vm_name` — имя ВМ;
- `private_ip` — внутренний IP;
- `public_ip` — публичный IP при включённом NAT;
- `disk_id` — ID дополнительного диска.

В окружениях эти значения доступны через output `vm`.

## Подготовка

1. Установить Terraform и Yandex Cloud CLI.
2. Настроить CLI командой `yc init`.
3. Подготовить подсети для окружений.
4. Заменить заглушки в `.tfvars` реальными ID и публичным SSH-ключом.

Получить ID образа Ubuntu:

```bash
yc compute image get-latest-from-family ubuntu-2204-lts \
  --folder-id standard-images
```

Использовать поле `id` из результата.

Настроить аутентификацию:

```bash
export YC_TOKEN="$(yc iam create-token)"
export YC_CLOUD_ID="$(yc config get cloud-id)"
export YC_FOLDER_ID="$(yc config get folder-id)"
```

## Проверка и запуск

Команды выполняются из корня репозитория.

Проверка форматирования:

```bash
terraform fmt -recursive Task1Advanced
```

Dev:

```bash
terraform -chdir=Task1Advanced/envs/dev init
terraform -chdir=Task1Advanced/envs/dev validate
terraform -chdir=Task1Advanced/envs/dev plan -var-file=dev.tfvars
terraform -chdir=Task1Advanced/envs/dev apply -var-file=dev.tfvars
```

Stage:

```bash
terraform -chdir=Task1Advanced/envs/stage init
terraform -chdir=Task1Advanced/envs/stage validate
terraform -chdir=Task1Advanced/envs/stage plan -var-file=stage.tfvars
terraform -chdir=Task1Advanced/envs/stage apply -var-file=stage.tfvars
```

Prod:

```bash
terraform -chdir=Task1Advanced/envs/prod init
terraform -chdir=Task1Advanced/envs/prod validate
terraform -chdir=Task1Advanced/envs/prod plan -var-file=prod.tfvars
terraform -chdir=Task1Advanced/envs/prod apply -var-file=prod.tfvars
```

Просмотр выходов, например для dev:

```bash
terraform -chdir=Task1Advanced/envs/dev output
```

## Особенности

- У каждого окружения собственный локальный Terraform state.
- Подсеть, ВМ и дополнительный диск должны находиться в одной зоне.
- Дополнительный диск подключается без форматирования и монтирования в ОС.
- Для доступа к prod по SSH требуется доступ к внутренней сети.
- Удаление через Terraform destroy удаляет также дополнительный диск,
  поскольку он управляется этим модулем.