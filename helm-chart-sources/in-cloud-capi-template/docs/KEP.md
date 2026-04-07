# KEP: in-cloud-capi-template — Helm-чарт инфраструктуры ClusterClass

## Метаданные

| Поле | Значение |
|------|----------|
| **KEP номер** | KEP-0001 |
| **Название** | in-cloud-capi-template |
| **Статус** | provisional |
| **Авторы** | PRO-Robotech |
| **Дата создания** | 2026-03-16 |
| **Последнее обновление** | 2026-03-16 |
| **Версия чарта** | 0.1.0 |
| **Целевой Kubernetes** | >= 1.30 |
| **Целевой CAPI** | v1beta2 |

---

## Содержание

- [Резюме](#резюме)
- [Мотивация](#мотивация)
  - [Цели](#цели)
  - [Не-цели](#не-цели)
- [Предложение](#предложение)
  - [Архитектура](#архитектура)
  - [Компоненты кластера](#компоненты-кластера)
  - [Механизм установки компонентов](#механизм-установки-компонентов)
  - [Bootstrap аддонов](#bootstrap-аддонов)
  - [ClusterClass Patches и Variables](#clusterclass-patches-и-variables)
  - [Поддержка провайдеров](#поддержка-провайдеров)
- [Детали проектирования](#детали-проектирования)
  - [API и Values](#api-и-values)
  - [Сетевая конфигурация](#сетевая-конфигурация)
  - [TLS и сертификаты](#tls-и-сертификаты)
  - [Аудит API Server](#аудит-api-server)
  - [Container Runtime](#container-runtime)
- [Риски и меры по их снижению](#риски-и-меры-по-их-снижению)
- [План тестирования](#план-тестирования)
- [Критерии зрелости](#критерии-зрелости)
- [История реализации](#история-реализации)
- [Альтернативы](#альтернативы)

---

## Резюме

Проект `in-cloud-capi-template` представляет собой Helm-чарт, генерирующий полный набор ресурсов Cluster API (CAPI) для декларативного создания и управления Kubernetes-кластерами через механизм ClusterClass. Чарт описывает типовую конфигурацию кластера, включая установку системных компонентов, настройку control plane, bootstrap аддонов и интеграцию с инфраструктурным провайдером Wrapper.

Единая параметризованная конфигурация позволяет создавать как инфраструктурные (infra) кластеры с полноценным KubeadmControlPlane, так и клиентские (client) кластеры с управлением через AddonClaim.

---

## Мотивация

### Проблема

Ручная настройка Kubernetes-кластеров в мультиоблачной среде приводит к:
- Дрейфу конфигурации между кластерами
- Невоспроизводимости окружений
- Высокой стоимости операционной поддержки
- Отсутствию единого стандарта для control plane и data plane

### Решение

Единый Helm-чарт, генерирующий ClusterClass с полным набором patches и variables, позволяющий:
- Параметризованно описать конфигурацию кластера
- Использовать ClusterClass для порождения типовых кластеров
- Управлять версиями компонентов через ClusterClass variables
- Поддерживать несколько инфраструктурных провайдеров из одного шаблона

### Цели

1. Обеспечить декларативное создание Kubernetes-кластеров через CAPI ClusterClass
2. Поддержать полный lifecycle компонентов: containerd, kubelet, kubeadm, kubectl, etcd, runc, crictl, helm
3. Автоматизировать bootstrap аддонов (Cilium, CoreDNS, ArgoCD, addon-operator) на первой control-plane ноде
4. Поддержать два типа кластеров: infra (KubeadmControlPlane) и client (AddonClaim)
5. Обеспечить параметризацию через ClusterClass variables (версии, сеть, TLS, провайдер)
6. Предоставить единый механизм установки бинарников через systemd oneshot-сервисы с SHA256-верификацией

### Не-цели

1. Управление жизненным циклом самого management-кластера
2. Реализация собственного инфраструктурного провайдера
3. Управление DNS-записями и внешними load balancer'ами
4. Мониторинг и observability (выносится в отдельные аддоны)
5. Поддержка архитектур, отличных от amd64

---

## Предложение

### Архитектура

Чарт генерирует два типа ClusterClass:

```
┌──────────────────────────────────────────────┐
│            Helm Chart (values.yaml)          │
└──────────────┬───────────────┬───────────────┘
               │               │
    ┌──────────▼──────┐ ┌──────▼──────────┐
    │ ClusterClass    │ │ ClusterClass     │
    │ (Infra)         │ │ (Client)         │
    │                 │ │                  │
    │ ┌─────────────┐ │ │ ┌──────────────┐ │
    │ │ Kubeadm     │ │ │ │ AddonClaim   │ │
    │ │ ControlPlane│ │ │ │ Template     │ │
    │ └─────────────┘ │ │ └──────────────┘ │
    │ ┌─────────────┐ │ │ ┌──────────────┐ │
    │ │ Machine     │ │ │ │ Cluster      │ │
    │ │ Template    │ │ │ │ Template     │ │
    │ └─────────────┘ │ │ └──────────────┘ │
    │ ┌─────────────┐ │ │                  │
    │ │ Cluster     │ │ │ Patches:         │
    │ │ Template    │ │ │  - addonClaim    │
    │ └─────────────┘ │ │  - clusterTmpl   │
    │ ┌─────────────┐ │ │                  │
    │ │ Config      │ │ │ Variables:       │
    │ │ Template    │ │ │  - wrapper.*       │
    │ └─────────────┘ │ │                  │
    │                 │ └──────────────────┘
    │ Patches:        │
    │  - apiServer    │
    │  - etcd         │
    │  - scheduler    │
    │  - ctrlMgr      │
    │  - files        │
    │  - commands     │
    │  - nodeReg      │
    │  - rollout      │
    │  - machineTempl │
    │  - clusterTempl │
    │                 │
    │ Variables:      │
    │  - versions     │
    │  - network      │
    │  - names        │
    │  - apiserver    │
    │  - wrapper.*      │
    └─────────────────┘
```

### Компоненты кластера

| Компонент | Control Plane | Data Plane | Версия по умолчанию |
|-----------|:---:|:---:|-----|
| containerd | + | + | 1.7.19 |
| runc | + | + | v1.1.12 |
| crictl | + | + | v1.30.0 |
| kubelet | + | + | v1.30.4 |
| kubeadm | + | + | v1.30.4 |
| kubectl | + | + | v1.30.4 |
| etcd | + | - | v3.5.5 |
| helm | + | + | v3.19.5 |

### Механизм установки компонентов

Каждый компонент устанавливается через триаду cloud-init файлов:

```
download-script.sh          # Скачивание, проверка SHA256, установка
  ├── Идемпотентность:      # Пропуск если версия совпадает
  ├── Верификация:          # sha256sum -c
  └── Атомарность:          # install -m 755 в INSTALL_PATH

download.env                # Systemd EnvironmentFile
  ├── COMPONENT_VERSION     # Из ClusterClass variable
  └── REPOSITORY            # URL репозитория

<component>-install.service # Systemd oneshot
  ├── After=network.target
  ├── EnvironmentFile=download.env
  └── ExecStart=download-script.sh
```

Версии компонентов переопределяются через ClusterClass variables без пересоздания шаблона. Systemd EnvironmentFile подхватывает переменные при старте.

### Bootstrap аддонов

На первой control-plane ноде (определяется по количеству CP-нод == 1) запускается postKubeadmCommand, который последовательно устанавливает:

1. **Cilium** (CNI) — kubeProxyReplacement, IPAM с параметризованным CIDR
2. **CoreDNS** — с привязкой к `clusterDnsSvc` через ClusterClass variable
3. **ArgoCD** — с CMP-плагином helm-with-values, avp-config для Vault
4. **addon-operator** — оператор управления аддонами
5. **Addon CR** — AddonSet и client-cp-control-plane с зависимостями

### ClusterClass Patches и Variables

**Patches** реализованы как JSON patches (RFC6902) и сгруппированы по области применения:

| Группа | Назначение |
|--------|-----------|
| `kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.*` | apiServer, etcd, controllerManager, scheduler (extraArgs, extraVolumes, certSANs) |
| `kubeadmControlPlane.kubeadmConfigSpec.initConfiguration.*` | nodeRegistration, patches directory, users |
| `kubeadmControlPlane.kubeadmConfigSpec.joinConfiguration.*` | nodeRegistration, patches directory |
| `kubeadmControlPlane.kubeadmConfigSpec.files` | Полный набор cloud-init файлов |
| `kubeadmControlPlane.kubeadmConfigSpec.preKubeadmCommands` | Установка компонентов, sysctl, containerd |
| `kubeadmControlPlane.kubeadmConfigSpec.postKubeadmCommands` | Bootstrap аддонов, labeling |
| `kubeadmControlPlane.rollout` | certificatesExpiryDays: 180 |
| `clusterTemplate.wrapper.*` | Wrapper-специфичная конфигурация кластера |
| `machineTemplate.wrapper.*` | Wrapper-специфичная конфигурация VM |
| `addonClaimTemplate.*` | Конфигурация client-кластера через AddonClaim |

**Variables** (ClusterClass) для параметризации:

| Категория | Примеры переменных |
|-----------|-------------------|
| Версии | `containerdVersion`, `kubeletVersion`, `etcdVersion`, `pauseVersion` |
| Сеть | `clusterPodCidr`, `clusterServiceSubnet`, `clusterDnsSvc` |
| Имена | `externalClusterDomain`, `internalClusterName` |
| API Server | `watchCache`, `oidcIssuerUrl` |
| Компоненты | `containerdMirrorUrl` |
| Wrapper | `wrapperClusterClaimName`, `wrapperClusterRegion`, load balancer настройки |

### Поддержка провайдеров

| Провайдер | API Version | Control Plane | Client | Patches | Variables |
|-----------|-------------|:---:|:---:|:---:|:---:|
| Wrapper | `v1beta2` | + | + | clusterTemplate, machineTemplate | base, loadBalancer, infra, addonClaim |

---

## Детали проектирования

### API и Values

Корневой ключ `capi.k8s` содержит:

```yaml
capi:
  externalSecrets:              # TLS через ExternalSecrets или openssl
    controllerManager:
      enabled: false
    scheduler:
      enabled: false

  k8s:
    infrastructureType: wrapper
    controlPlaneType: kubeadm   # kubeadm
    clientControlPlaneType: addon-claim

    containerRuntime:
      socket: unix:///var/run/containerd/containerd.sock
      mirrors:                  # Зеркала containerd registry

    users:                      # SSH-пользователи для cloud-init
    controlPlane:
      components:               # Конфигурация CP-компонентов
    dataPlane:
      components:               # Конфигурация DP-компонентов
```

### Сетевая конфигурация

| Параметр | Значение по умолчанию | Описание |
|----------|----------------------|----------|
| `clusterPodCidr` | `10.0.0.0/16` | CIDR для подов |
| `clusterPodCidrMaskSize` | `24` | Размер маски для нод |
| `clusterServiceSubnet` | Настраивается | CIDR для сервисов |
| `clusterDnsSvc` | Настраивается | IP CoreDNS |

### TLS и сертификаты

- **API Server**: стандартный PKI через kubeadm (`/etc/kubernetes/pki/`)
- **Controller Manager**: опциональный TLS — через ExternalSecrets (`contentFrom.secret`) или генерация openssl в preKubeadmCommands
- **Scheduler**: аналогично Controller Manager
- **etcd**: mutual TLS (peer + client cert auth)
- **OIDC**: CA-сертификат монтируется из файла (`ca-oidc.crt`)

### Аудит API Server

Политика аудита задаётся через cloud-init файл `audit-policy.yaml` и монтируется как extraVolume. Логи пишутся в `/var/log/kubernetes/audit/` в batch-режиме с ротацией (maxsize: 1000MB, maxbackup: 10, maxage: 30 дней).

### Container Runtime

containerd настраивается через:
- `config.toml` (version=2, SystemdCgroup, pause image)
- Зеркала registry (10 предконфигурированных: docker.io, gcr.io, ghcr.io, quay.io, registry.k8s.io и др.)
- Systemd unit с зависимостью от `containerd-install.service`

---

## Риски и меры по их снижению

### R1. Захардкоженные секреты в шаблонах

**Риск**: bcrypt-хеш пароля ArgoCD и SHA-512 хеш пароля пользователя `capv` находятся непосредственно в values.yaml и шаблонах.

**Мера**: Вынести секреты в ExternalSecret/SealedSecret. Дефолтные values должны содержать только placeholder'ы с документацией о необходимости переопределения.

### R2. Монолитный bootstrap-скрипт

**Риск**: postKubeadmCommands (`_commands.sh.tpl`, ~690 строк) содержит inline Helm values для Cilium, CoreDNS, ArgoCD и addon-operator. Сложно отлаживать и модифицировать.

**Мера**: Разбить на отдельные скрипты по аддону. Вынести Helm values в параметризуемые шаблоны.

### R3. Несоответствие путей бинарников

**Риск**: systemd unit kubelet ссылается на `/usr/bin/kubelet`, а бинарник устанавливается в `/usr/local/bin/kubelet`.

**Мера**: Привести путь в systemd unit в соответствие с `installPath` из values.

### R4. Хардкод сетевого интерфейса

**Риск**: `ADVERTISE_ADDRESS` определяется через `eth1` в preKubeadmCommands. На инфраструктуре с другим именованием интерфейсов это не работает.

**Мера**: Параметризовать имя интерфейса через ClusterClass variable с дефолтом `eth1`.

### R5. Deprecated флаги API Server

**Риск**: `allow-privileged: "true"` deprecated в Kubernetes 1.25+ и не имеет эффекта в 1.30.

**Мера**: Удалить deprecated флаги. Настроить `anonymous-auth: "false"` по умолчанию.

### R6. Образы из персональных registry

**Риск**: Образ `dmkolbin/argocd-with-utils` из личного Docker Hub и `prorobotech/addons-operator:feature-*` из feature-ветки используются в production.

**Мера**: Перенести образы в корпоративный реестр. Использовать стабильные теги.

### R7. etcd metrics без TLS

**Риск**: `listen-metrics-urls: http://0.0.0.0:2381` открывает метрики etcd без аутентификации на всех интерфейсах.

**Мера**: Ограничить `127.0.0.1:2381` или добавить TLS для metrics endpoint.

### R8. Отсутствие валидации values

**Риск**: Нет `values.schema.json`. Пользователь не получает обратную связь при невалидных значениях.

**Мера**: Создать JSON Schema для values с валидацией типов, enum-ограничениями, обязательными полями.

---

## План тестирования

### Уровень 1: Статический анализ

- [ ] `helm lint .` проходит без ошибок
- [ ] `helm template .` генерирует валидный YAML для каждого провайдера
- [ ] `helm template . --set capi.k8s.infrastructureType=wrapper` — полный набор ресурсов

### Уровень 2: Валидация ресурсов

- [ ] Все сгенерированные ресурсы проходят `kubectl apply --dry-run=server`
- [ ] ClusterClass patches применяются без конфликтов
- [ ] ClusterClass variables имеют корректные default и schema
- [ ] JSON patches (RFC6902) синтаксически валидны

### Уровень 3: Интеграционное тестирование

- [ ] Кластер создаётся из ClusterClass Infra (Wrapper)
- [ ] Кластер создаётся из ClusterClass Client (AddonClaim)
- [ ] Bootstrap аддонов завершается (Cilium, CoreDNS, ArgoCD)
- [ ] Control plane масштабируется (1 -> 3 ноды)
- [ ] Rolling update компонентов через изменение ClusterClass variables
- [ ] Data plane масштабируется через MachineDeployment

### Уровень 4: Security

- [ ] Отсутствуют захардкоженные секреты в templates/
- [ ] API Server hardening (anonymous-auth, admission plugins)
- [ ] etcd mutual TLS корректно настроен
- [ ] RBAC ClusterRole минимально необходим

---

## Критерии зрелости

### Alpha (текущий — v0.1.0)

- [x] Базовая генерация ClusterClass для Wrapper
- [x] Установка компонентов через systemd oneshot
- [x] Bootstrap аддонов (Cilium, CoreDNS, ArgoCD)
- [x] Поддержка ExternalSecrets для TLS
- [x] CI/CD pipeline (GitLab CI -> OCI registry)
- [ ] `helm lint` в CI pipeline

### Beta (v0.2.0)

- [ ] Удаление захардкоженных секретов
- [ ] `values.schema.json` с валидацией
- [ ] Рефакторинг bootstrap-скрипта (разделение по аддонам)
- [ ] Исправление пути kubelet в systemd unit
- [ ] Параметризация сетевого интерфейса
- [ ] Удаление deprecated флагов API Server
- [ ] Образы из корпоративного реестра
- [ ] Интеграционные тесты с kind/CAPD

### GA (v1.0.0)

- [ ] Поддержка arm64
- [ ] Полное покрытие интеграционными тестами
- [ ] Security audit
- [ ] Документация для конечных пользователей
- [ ] SLA для control plane operations

---

## История реализации

| Дата | Версия | Изменение |
|------|--------|-----------|
| 2025-XX | 0.0.1 | Начальная реализация с поддержкой Wrapper |
| 2026-03-16 | 0.1.0 | Рефакторинг нейминга (camelCase), создание README, исправление опечаток |

---

## Альтернативы

### 1. ClusterResourceSet вместо postKubeadmCommands для аддонов

**Рассмотрено**: ClusterResourceSet позволяет применять манифесты к новым кластерам автоматически.

**Отклонено**: Не поддерживает Helm-чарты нативно. Требует предварительной генерации манифестов. Не решает проблему зависимостей между аддонами (Cilium -> CoreDNS -> ArgoCD).

### 2. Helmfile / ArgoCD ApplicationSet для управления чартом

**Рассмотрено**: Вынос управления на уровень GitOps.

**Отклонено на данном этапе**: Добавляет дополнительный слой абстракции. Helm-чарт должен быть самодостаточным. GitOps интеграция планируется на уровне addon-operator.

### 3. Kustomize вместо Helm для генерации ClusterClass

**Рассмотрено**: Kustomize с overlays для разных провайдеров.

**Отклонено**: ClusterClass требует сложной параметризации (versions, network, TLS), которая в Kustomize решается через generators и transformers. Helm templates обеспечивают более гибкую условную логику и повторное использование шаблонов.

### 4. Отдельный чарт на каждый провайдер

**Отклонено**: При добавлении новых провайдеров большая часть конфигурации (kubeadmConfigSpec, files, commands, variables) будет общей. Разделение приведёт к дублированию кода и дрейфу конфигурации.
