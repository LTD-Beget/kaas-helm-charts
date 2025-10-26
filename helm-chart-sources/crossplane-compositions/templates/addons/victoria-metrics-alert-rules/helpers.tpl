{{- define "addons.victoriametricsalertrules" }}
name: VictoriaMetricsAlertRules
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
default: |
  {{- include "addons.victoriametricsalertrules.default.values" . | nindent 2 }}
immutable: |
  victoria-metrics-k8s-stack:
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
