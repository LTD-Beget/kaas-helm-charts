# in-cloud-capi-template

Helm-чарт для описания инфраструктуры Kubernetes-кластеров на базе [Cluster API](https://cluster-api.sigs.k8s.io/) (CAPI) с использованием механизма **ClusterClass**.

## Назначение

Чарт генерирует набор ресурсов CAPI (ClusterClass, KubeadmControlPlaneTemplate, KubeadmConfigTemplate, MachineTemplate, ClusterTemplate и др.), которые описывают типовую конфигурацию Kubernetes-кластера, включая:

- Установку компонентов (containerd, kubelet, kubeadm, kubectl, etcd, runc, crictl, helm) через systemd oneshot-сервисы
- Настройку control plane (API Server, Controller Manager, Scheduler, etcd) с TLS, аудитом и OIDC
- Bootstrap-установку аддонов (Cilium, CoreDNS, ArgoCD, addon-operator) на первой control-plane ноде
- Поддержку нескольких инфраструктурных провайдеров

## Архитектура

```
ClusterClass
├── controlPlane
│   ├── KubeadmControlPlaneTemplate
│   │   └── kubeadmConfigSpec (патчи через ClusterClass patches)
│   │       ├── clusterConfiguration (apiServer, etcd, controllerManager, scheduler)
│   │       ├── initConfiguration / joinConfiguration (nodeRegistration, patches)
│   │       ├── files (cloud-init файлы компонентов)
│   │       └── preKubeadmCommands / postKubeadmCommands
│   └── MachineTemplate (Wrapper)
│
├── infrastructure
│   └── ClusterTemplate (Wrapper)
│
├── workers
│   ├── KubeadmConfigTemplate
│   └── MachineTemplate
│
├── patches (JSON patches для параметризации)
│   ├── kubeadmControlPlane/* — настройка control plane
│   ├── clusterTemplate/* — настройка инфраструктуры
│   └── machineTemplate/* — настройка VM
│
└── variables (ClusterClass variables для кастомизации)
    ├── default/ — версии компонентов, сеть, API Server
    └── wrapper/ — Wrapper-специфичные (load balancer, addon claim)
```

## Требования

| Компонент | Версия |
|-----------|--------|
| Helm | >= 3.15 |
| Cluster API | v1beta2 |
| Kubernetes | >= 1.30 |

### Поддерживаемые инфраструктурные провайдеры

| Провайдер | API Version | Статус |
|-----------|-------------|--------|
| Wrapper | `infrastructure.cluster.x-k8s.io/v1beta2` | Основной, полная поддержка |

## Установка

```bash
helm install my-cluster-class . \
  --namespace capi-system \
  --create-namespace
```

С переопределением параметров:

```bash
helm install my-cluster-class . \
  --namespace capi-system \
  --create-namespace \
  -f my-values.yaml
```

## Структура чарта

```
.
├── Chart.yaml
├── values.yaml
├── files/                          # Статические файлы (WireGuard шаблоны)
└── templates/
    ├── _helpers.tpl                # Хелперы (name, fullname)
    ├── rbac/                       # ClusterRole для addon-operator
    ├── clusterClass/
    │   ├── clusterClassInfra.yaml  # ClusterClass для infra-кластеров
    │   ├── clusterClassClient.yaml # ClusterClass для клиентских кластеров
    │   ├── commands/               # preKubeadmCommands (установка компонентов)
    │   ├── files/                  # Cloud-init файлы
    │   │   ├── _common.tpl         # Общие шаблоны (download-bundle, TLS)
    │   │   ├── _main.tpl           # Агрегация файлов для CP и DP
    │   │   ├── containerd/         # Конфиг и установка containerd
    │   │   ├── kubelet/            # Systemd unit, конфиг, установка
    │   │   ├── apiserver/          # OIDC CA, strategic merge patch
    │   │   ├── controllerManager/  # TLS-сертификаты
    │   │   ├── scheduler/          # TLS-сертификаты
    │   │   ├── audit/              # Политика аудита API Server
    │   │   └── ...                 # etcd, helm, kubeadm, kubectl, crictl, runc, sysctls, cni
    │   ├── patches/                # JSON patches для ClusterClass
    │   │   ├── kubeadmControlPlane/  # Патчи KubeadmConfigSpec
    │   │   ├── clusterTemplate/      # Патчи ClusterTemplate (Wrapper)
    │   │   ├── machineTemplate/      # Патчи MachineTemplate (Wrapper)
    │   │   └── addonClaimTemplate/   # Патчи AddonClaimTemplate
    │   └── variables/              # ClusterClass variables
    │       ├── default/            # Версии, сеть, имена
    │       └── wrapper/              # Wrapper-специфичные
    ├── clusterTemplates/           # ClusterTemplate (Wrapper)
    ├── machineTemplate/            # MachineTemplate (Wrapper)
    ├── controlPlaneTemplate/       # KubeadmControlPlaneTemplate, AddonClaimTemplate
    ├── configTemplate/             # KubeadmConfigTemplate (workers)
    └── inCloudClusterClass/        # WireGuard Bootstrap/Machine шаблоны
```

## Основные параметры (values.yaml)

### Общие

| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `capi.k8s.infrastructureType` | Инфраструктурный провайдер | `wrapper` |
| `capi.k8s.controlPlaneType` | Тип control plane (infra-кластер) | `kubeadm` |
| `capi.k8s.clientControlPlaneType` | Тип control plane (клиентский кластер) | `addon-claim` |
| `capi.k8s.containerRuntime.socket` | Сокет container runtime | `unix:///var/run/containerd/containerd.sock` |
| `capi.k8s.containerRuntime.mirrors` | Конфигурация зеркал containerd | см. values.yaml |

### Внешние секреты (TLS)

| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `capi.externalSecrets.controllerManager.enabled` | Использовать внешние секреты для TLS Controller Manager | `false` |
| `capi.externalSecrets.scheduler.enabled` | Использовать внешние секреты для TLS Scheduler | `false` |

### Компоненты

Каждый компонент (`helm`, `kubectl`, `kubeadm`, `kubelet`, `crictl`, `runc`, `containerd`, `etcd`) настраивается отдельно для control plane и data plane в секциях `capi.k8s.controlPlane.components` и `capi.k8s.dataPlane.components`.

| Параметр | Описание |
|----------|----------|
| `*.enabled` | Включить/выключить компонент |
| `*.bin.repository` | URL репозитория для скачивания |
| `*.bin.version` | Версия компонента |
| `*.bin.installPath` | Путь установки бинарника |

### Версии компонентов по умолчанию

| Компонент | Версия |
|-----------|--------|
| containerd | 1.7.19 |
| runc | v1.1.12 |
| crictl | v1.30.0 |
| etcd | v3.5.5 |
| kubeadm | v1.30.4 |
| kubectl | v1.30.4 |
| kubelet | v1.30.4 |
| Helm | v3.19.5 |

## Механизм установки компонентов

Каждый компонент устанавливается через три cloud-init файла, генерируемых шаблоном `files.common.downloadBundle`:

1. **download-script.sh** — Bash-скрипт, который скачивает бинарник, проверяет контрольную сумму SHA256, распаковывает и устанавливает. Поддерживает идемпотентность (пропускает установку, если версия совпадает).

2. **download.env** — Systemd EnvironmentFile с переменными `COMPONENT_VERSION` и `REPOSITORY`. Позволяет переопределить версию через ClusterClass variables без пересоздания шаблона.

3. **install.service** — Systemd oneshot-сервис, который запускает download-script.sh при старте узла.

## CI/CD

Проект использует GitLab CI (`.gitlab-ci.yml`) для сборки и публикации Helm-чарта в OCI-реестр:

- **Ветки**: версия формируется как `0.0.0-<branch>-<short-sha>`
- **Теги**: версия берётся из git-тега
- **Реестр**: публикация в `oci://$CI_REGISTRY/k8s-charts-public/charts`
