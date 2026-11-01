# Задание 1. Модульная инфраструктура AWS

## Назначение

Переиспользуемый модуль `modules/vm` создаёт EC2, загрузочный диск gp3,
отдельный EBS-диск gp3, подключение дополнительного диска, EC2 Key Pair и
Security Group. Модуль получает существующий `subnet_id`; VPC и зона
доступности определяются по этой подсети. CPU и RAM задаются переменными,
внутри модуля поддерживаемая пара преобразуется в тип EC2.

Каждое окружение самостоятельно создаёт VPC, подсеть, Internet Gateway,
таблицу маршрутов и подключает один и тот же модуль. Состояния окружений
разделены рабочими директориями. Идентификаторы облачных ресурсов вручную
подставлять не требуется; Ubuntu 24.04 LTS выбирается из AMI Canonical.

## Структура

- `modules/vm/main.tf` — ресурсы модуля и подбор типа EC2.
- `modules/vm/variables.tf` — интерфейс модуля.
- `modules/vm/outputs.tf` — выходы модуля.
- `envs/dev`, `envs/stage`, `envs/prod` — одинаковые корневые конфигурации,
  в каждой `main.tf`, `variables.tf`, `outputs.tf` и свой `.tfvars`.

## Параметры модуля

| Параметр | Назначение | Значение по умолчанию |
|---|---|---|
| name | Имя ВМ и префикс ресурсов | Обязательный |
| cores | Количество vCPU | Обязательный |
| memory | RAM в GiB | Обязательный |
| disk_size | Размер дополнительного диска в GiB | Обязательный |
| subnet_id | ID существующей подсети | Обязательный |
| ssh_key | Содержимое публичного SSH-ключа | Обязательный |
| ssh_cidr | IPv4 CIDR, которому разрешён SSH | Обязательный |
| image_id | ID AMI, совместимого с x86_64 и T3 | Обязательный |
| boot_disk_size | Загрузочный диск в GiB | 8 |
| public_ip | Назначить публичный IPv4 | true |

Типы gp3 и семейство T3 — общие технические решения модуля. Значения dev,
stage и prod в нём не зашиты. Для другого семейства расширяется таблица
сопоставления; произвольные сочетания CPU и RAM модуль не поддерживает.

| cores | memory | Тип EC2 |
|---|---|---|
| 2 | 1 | t3.micro |
| 2 | 2 | t3.small |
| 2 | 4 | t3.medium |
| 2 | 8 | t3.large |
| 4 | 16 | t3.xlarge |
| 8 | 32 | t3.2xlarge |

Неподдерживаемая пара вызывает понятную ошибку precondition до создания ВМ.

## Конфигурации окружений

| Окружение | vCPU | RAM, GiB | Корневой диск, GiB | Дополнительный диск, GiB |
|---|---|---|---|---|
| dev | 2 | 1 | 8 | 10 |
| stage | 2 | 2 | 8 | 20 |
| prod | 2 | 2 | 16 | 30 |

Все конфигурации намеренно маленькие для учебной работы. Название prod
не означает полноценную отказоустойчивую промышленную архитектуру. Публичный
IPv4 включён для подключения с ноутбука; порт 22 разрешён только из ssh_cidr.
NAT Gateway, балансировщики и резервные копии не создаются.

## Выходы

Корневой output `vm` содержит `vm_id`, `vm_name`, `private_ip`, `public_ip`,
`disk_id` и `instance_type`. Дополнительно возвращается `subnet_id`.

## Переход с Yandex Cloud

Не распаковывать архив поверх старой рабочей папки: старые файлы и state
не должны смешиваться с новой конфигурацией AWS.

Из корня репозитория переместить прежнюю директорию в резервную копию
вне репозитория. Убедиться, что целевая папка ещё не существует:

```bash
test ! -e ../Task1Advanced-yandex-backup && mv Task1Advanced ../Task1Advanced-yandex-backup
```

Затем распаковать архив в корень репозитория. В нём появится новая папка
`Task1Advanced`. Резервная копия содержит старые .tfvars, state и конфигурацию
для отдельного управления оставшимися ресурсами Yandex Cloud. Созданный
там диск не переносится в AWS и сам не удаляется.

## Подготовка AWS

Нужен активный AWS-аккаунт и доступ к EC2 в выбранном регионе. Для учебного
IAM-пользователя можно назначить AWS-managed policy `AmazonEC2FullAccess`:
все создаваемые ресурсы и запросы Describe относятся к EC2. Эта политика
широкая; здесь она используется для изолированного учебного аккаунта.

В AWS Console: IAM → Users → нужный пользователь → Security credentials →
Create access key → Command Line Interface. Не создавать ключи root-пользователя.
Если аккаунт уже использует IAM Identity Center/SSO, можно использовать
существующий профиль SSO вместо создания постоянных ключей.

На Mac установить AWS CLI и настроить отдельный профиль:

```bash
brew install awscli
aws configure --profile future-training
```

Ввести Access Key ID и Secret Access Key, регион `us-east-1`, формат `json`.
Ключи сохраняются локально средствами AWS CLI и не добавляются в Terraform.

```bash
export AWS_PROFILE=future-training
aws sts get-caller-identity
```

Ожидается JSON с Account, UserId и Arn. При использовании SSO сначала
выполнить `aws sso login --profile future-training`.

## SSH

Проверить наличие публичного ключа:

```bash
ls ~/.ssh/id_ed25519.pub
```

Если ключа нет, создать пару (существующие ключи не перезаписывать):

```bash
ssh-keygen -t ed25519
```

Файл `.pub` передаётся в AWS автоматически через `ssh_key_path`.
Приватный `~/.ssh/id_ed25519` остаётся на ноутбуке.

Определить публичный IPv4 и разрешить SSH только с него:

```bash
export TF_VAR_ssh_cidr="$(curl -4 -fsS --connect-timeout 10 --max-time 20 https://checkip.amazonaws.com | tr -d '[:space:]')/32"
```

Если сеть или выходной IP VPN изменились, обновить `TF_VAR_ssh_cidr`
и повторить apply. Использовать IP, с которого будет идти SSH-подключение.
Если curl не вернул IP, установить переменную вручную, например
`export TF_VAR_ssh_cidr="203.0.113.10/32"`, заменив пример своим реальным IP.

## Проверка и запуск

Все команды ниже выполняются из корня репозитория.
В новом терминале заново установить AWS_PROFILE и TF_VAR_ssh_cidr.

```bash
terraform fmt -recursive Task1Advanced
```

Dev:

```bash
terraform -chdir=Task1Advanced/envs/dev init
terraform -chdir=Task1Advanced/envs/dev validate
terraform -chdir=Task1Advanced/envs/dev plan -var-file=dev.tfvars
terraform -chdir=Task1Advanced/envs/dev apply -var-file=dev.tfvars
terraform -chdir=Task1Advanced/envs/dev output
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

Для экономии окружения можно запускать и удалять по очереди.

Подключение к dev после успешного apply:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@PUBLIC_IP
```

Вместо PUBLIC_IP подставить `public_ip` из output `vm`.
Дополнительный диск подключён к EC2, но не форматируется и не монтируется
в ОС автоматически. В AWS задано имя `/dev/sdf`; в гостевой ОС T3 диск
может отображаться как NVMe. Посмотреть диски: `lsblk`.

## Завершение практики

После работы удалить ресурсы соответствующего окружения:

```bash
terraform -chdir=Task1Advanced/envs/dev destroy -var-file=dev.tfvars
terraform -chdir=Task1Advanced/envs/stage destroy -var-file=stage.tfvars
terraform -chdir=Task1Advanced/envs/prod destroy -var-file=prod.tfvars
```

Выполнять только для окружений, которые были созданы. Destroy удалит ВМ,
оба диска и созданные сетевые ресурсы этого окружения, включая данные дисков.
Остановка EC2 не заменяет destroy: EBS продолжает тарифицироваться.
Публичный IPv4 тоже имеет отдельную стоимость. Доступность Free Tier и
применение кредитов зависят от аккаунта; проверить их в AWS Billing.

## Сдача

Добавить `Task1Advanced` в репозиторий. State, приватные ключи и AWS credentials
не коммитить. `.terraform.lock.hcl`, созданные init для окружений, коммитить.
Открыть pull request с решением.

## Проверка перед доставкой

Результаты локальной проверки приведены в `VALIDATION.md`. Применение
к реальному AWS-аккаунту выполняется пользователем по инструкции выше.

Дополнительно включены три теста модуля с mock-провайдером (Terraform >= 1.7).
Они проверяют выбор t3.micro/t3.small, зону диска, ограничение SSH и отказ
для неподдерживаемой пары CPU/RAM. Тесты не обращаются к AWS и не создают
реальные ресурсы:

```bash
terraform -chdir=Task1Advanced/modules/vm init
terraform -chdir=Task1Advanced/modules/vm test
```

## Документация

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create
