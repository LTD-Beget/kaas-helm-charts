{{- define "addons.victoriametricscluster" }}
name: VictoriaMetricsCluster
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "victoriametricscluster" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
immutable: |
  victoria-metrics-k8s-stack:
    alertmanager:
      enabled: false
    defaultRules:
      create: false
    prometheus-node-exporter:
      enabled: false
    serviceAccount:
      create: false
    victoria-metrics-operator:
      enabled: false
    # vmagent:
    #   enabled: false
    vmalert:
      enabled: false
    vmcluster:
      enabled: true
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
