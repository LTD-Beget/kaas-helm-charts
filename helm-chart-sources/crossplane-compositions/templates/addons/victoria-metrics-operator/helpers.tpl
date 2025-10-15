{{- define "addons.victoriametricsoperator" }}
name: VictoriaMetricsOperator
debug: false
chart: victoria-metrics-operator
repoURL: https://victoriametrics.github.io/helm-charts/
targetRevision: 0.49.2
default: |
  operator:
    disable_prometheus_converter: false
    useCustomConfigReloader: false

  logLevel: "info"

  env:
    - name: GOMAXPROCS
      value: '1'
    - name: VM_VMAGENTDEFAULT_CONFIGRELOADERMEMORY
      value: '100Mi'
    - name: VM_VMALERTMANAGER_CONFIGRELOADERMEMORY
      value: '100Mi'
    - name: VM_VMALERTDEFAULT_CONFIGRELOADERMEMORY
      value: '100Mi'

  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 250m
      memory: 320Mi

  admissionWebhooks:
    enabled: false

  serviceMonitor:
    enabled: true

  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
              - victoria-metrics-operator
            - key: app.kubernetes.io/instance
              operator: In
              values:
              - vmoperator-infra
          topologyKey: failure-domain.beta.kubernetes.io/region
        weight: 100
{{- end }}
