В icinga нужно добавить шаблон сервиса для алертов
```
template Service "signalilo-passive-service" {
  enable_active_checks = false
  enable_passive_checks = true

  max_check_attempts = 1
  check_interval = 1m
  retry_interval = 30s

  volatile = false

  enable_notifications = true
}
```
