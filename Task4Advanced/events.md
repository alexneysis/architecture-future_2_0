# Каталог доменных событий — «Будущее 2.0»

## Общий контракт события

События означают уже произошедший факт, публикуются после фиксации транзакции (например, через Transactional Outbox + CDC). События доставляются асинхронно через Kafka.

```json
{
  "event_id": "uuid",
  "event_type": "InvoiceIssued",
  "schema_version": 1,
  "occurred_at": "2026-11-03T10:00:00Z",
  "producer": "billing",
  "aggregate_id": "invoice-123",
  "correlation_id": "uuid",
  "payload": {"invoice_id": "invoice-123", "amount": 5000, "currency": "RUB"}
}
```

Обязательные поля контракта: `event_id`, `event_type`, `schema_version`, `occurred_at`, `producer`, `aggregate_id`, `correlation_id`, `payload`. Поле `payload` зависит от конкретного события.

## События и подписчики

| Событие | Bounded context — источник | Что произошло / минимальный `payload` | Подписчики | Доступ |
|---|---|---|---|---|
| `PatientRegistered` | Patient Registry | Зарегистрирован пациент; `{patient_ref, registration_source}` | Clinical Care | Защищённый, без ФИО |
| `AIStudyCompleted` | AI Diagnostics | Обработка исследования завершена; `{analysis_id, encounter_ref, processing_status}` | Clinical Care | Защищённый, без снимка/диагноза |
| `EncounterCompleted` | Clinical Care | Приём завершён; `{encounter_ref, billable_item_refs}` | Billing | Защищённый, без медицинской карты |
| `InvoiceIssued` | Billing | Выставлен счёт; `{invoice_id, amount, currency}` | Payments; Analytics **только через Privacy Projection** | Финансовый, ограниченный |
| `PaymentReceived` | Payments | Платёж подтверждён; `{payment_id, invoice_id, amount, currency}` | Billing; Analytics **через Privacy Projection** | Финансовый, ограниченный |
| `CreditContractCreated` | Lending | Кредитный договор активирован; `{contract_id, principal, currency, term_months}` | Payments; Analytics **через Privacy Projection** | Банковский, ограниченный |
| `MedicationOrderPlaced` | Clinical Care | Создано назначение для исполнения; `{order_id, authorized_item_refs, quantity}` | Pharmacy Orders (при наличии правового основания) | Защищённый, минимально необходимый |
| `StockBelowThreshold` | Inventory | Остаток ниже порога; `{stock_item_id, sku, location_id, remaining_quantity}` | Pharmacy Orders | Внутренний |
| `PharmacyOrderCreated` | Pharmacy Orders | Заказ поставщику создан; `{pharmacy_order_id, sku_refs, quantities}` | Inventory | Внутренний |
| `DeviceTelemetryReceived` | Medical Devices | Получена порция телеметрии; `{device_id, session_id, telemetry_ref}` | AI Diagnostics | Защищённый, без сырых показаний |
| `ClinicalVisitsAggregated` | Clinical Care | Рассчитаны агрегированные показатели посещений; `{day, region_code, visits_count}` | Analytics через Privacy Projection | Аналитический, без пациента |
| `AIUsageAggregated` | AI Diagnostics | Рассчитана обезличенная статистика использования ИИ; `{day, region_code, analyses_count}` | Analytics через Privacy Projection | Аналитический, без пациента |
