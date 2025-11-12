{{- define "addons.victoriametricscluster" }}
name: VictoriaMetricsCluster
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/vmcluster
immutable: |
  victoria-metrics-k8s-stack:
    alertmanager:
      enabled: false
    defaultDashboards:
      enabled: false
    defaultRules:
      create: false
    grafana:
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
      enabled: true
    vmsingle:
      enabled: false
{{- end }}
