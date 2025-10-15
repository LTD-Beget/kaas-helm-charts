{{- define "addons.victoriametricsalertmanager" }}
name: VictoriaMetricsAlertmanager
debug: false
chart: victoria-metrics-k8s-stack
repoURL: https://victoriametrics.github.io/helm-charts/
targetRevision: 0.52.0
default: |
  alertmanager:
    ingress:
      enabled: false
    config:
      global:
        resolve_timeout: 5m
      route:
        receiver: blackhole
        routes:
          # - receiver: mattermost-critical
          #   matchers:
          #     - severity =~ "critical"
          #     - in-cloud_metrics =~ "infra"
          #   group_by: ["cluster","alertname"]
          #   group_interval: 3m
          #   group_wait: 30s
          #   repeat_interval: 60m
          #   continue: false

          # - receiver: mattermost-warning
          #   matchers:
          #     - severity =~ "warning"
          #     - in-cloud_metrics =~ "infra"
          #   group_by: ["cluster","alertname"]
          #   group_interval: 3m
          #   group_wait: 30s
          #   repeat_interval: 60m
          #   continue: false

          - receiver: blackhole
            matchers:
              - alertname="Watchdog"
      receivers:
        - name: 'blackhole'
    monzoTemplate:
      enabled: true
    spec:
      selectAllByDefault: false
      priorityClassName: system-cluster-critical
      configSelector: {}
        # matchLabels:
        #   in-cloud-metrics: "infra"
      configNamespaceSelector: {}
      resources:
        requests:
          cpu: '100m'
          memory: 128Mi
        limits:
          cpu: '500m'
          memory: 512Mi
      extraEnvs:
        - name: GOMAXPROCS
          value: '1'
      # extraArgs:
      #   "cluster.label": "infra"
      podMetadata: {}
        # labels:
        #   in-cloud-metrics: "infra"
immutable: |
  alertmanager:
    enabled: true
  defaultRules:
    create: false
  defaultDashboards:
    enabled: false
  prometheus-node-exporter:
    enabled: false
  serviceAccount:
    create: false
  victoria-metrics-operator:
    enabled: false
  vmagent:
    enabled: false
  vmalert:
    enabled: false
  vmcluster:
    enabled: false
  vmsingle:
    enabled: false
  coreDns:
    enabled: false
  kubeDns:
    enabled: false
  grafana:
    enabled: false
  kube-state-metrics:
    enabled: false
  kubeApiServer:
    enabled: false
  kubeControllerManager:
    enabled: false
  kubeEtcd:
    enabled: false
  kubeProxy:
    enabled: false
  kubeScheduler:
    enabled: false
  kubelet:
    enabled: false
{{- end }}
