{{- define "addons.victoriametricsselect" }}
name: VictoriaMetricsSelect
debug: false
path: helm-chart-sources/victoria-metrics-cluster
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/vmcluster
immutable: |
  victoria-metrics-cluster:
    vmselect:
      enabled: true
    vminsert:
      enabled: false
    vmauth:
      enabled: false
    vmstorage:
      enabled: false
    vmbackupmanager:
      enabled: false
{{- end }}
