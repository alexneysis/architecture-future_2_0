# Проверка

- Версия Terraform при подготовке: 1.13.4.
- Установлен AWS provider 6.71.0, исходный пакет проверен init по подписи HashiCorp.
- `terraform fmt -recursive -check` — успешно для всех .tf, .tfvars и тестов.
- Полный `terraform validate` и mock-тесты не выполнены: среда запуска
  запрещает Unix-сокеты, необходимые для связи Terraform с плагином.
  Диагностика: `listen unix /tmp/plugin...: socket: operation not permitted`.
- Это ограничение среды проверки, а не результат успешного validate.
- Реальный AWS plan/apply не запускался; AWS-аккаунт пользователя не подключён.

На Mac выполнить init и validate по README, затем plan/apply для выбранного
окружения. Mock-тесты можно выполнить отдельно через `terraform test`
из `modules/vm` (Terraform >= 1.7).

В архив не включены локальные .terraform, state и lock-файлы среды проверки.
На Mac init получит провайдер из официального Registry и сформирует свои
.terraform.lock.hcl — их следует добавить в Git.
