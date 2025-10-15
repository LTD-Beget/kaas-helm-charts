{{- define "addons.victoriametricsalertrules" }}
name: VictoriaMetricsAlertRules
debug: false
chart: victoria-metrics-k8s-stack
repoURL: https://victoriametrics.github.io/helm-charts/
targetRevision: 0.52.0
default: |
  {{- include "addons.victoriametricsalertrules.default.values" . | nindent 2 }}
immutable: |
  defaultRules:
    create: true
  alertmanager:
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
  defaultDashboards:
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
