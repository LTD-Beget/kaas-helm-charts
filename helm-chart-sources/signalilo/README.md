В icinga нужно добавить шаблон сервиса для алертов
configuration/conf.d/hosts.d/kubernetes/signalilo-host.conf
```
object Host "signalilo" {
  import "generic-host"

  address = "127.0.0.1"

  enable_active_checks = false
  enable_passive_checks = true
  check_command = "dummy"

  vars.source = "signalilo"
}

object Service "heartbeat" {
  host_name = "signalilo"

  check_command = "dummy"

  enable_active_checks = false
  enable_passive_checks = true

}
```

/configuration/conf.d/signalilo-groups.conf
```
object ServiceGroup "k8s" {
  display_name = "Kubernetes alerts (Signalilo)"
}
```

/configuration/conf.d/templates.d/kubernetes_service_template.conf
```
template Service "signalilo-passive-service" {
  enable_active_checks = false
  enable_passive_checks = true

  max_check_attempts = 1
  check_interval = 1m
  retry_interval = 30s

  volatile = false
  enable_notifications = true

  groups = [ "k8s" ]
}
```
