{{- define "addons.victoriametricsstorage" }}
name: VictoriaMetricsStorage
debug: false
path: helm-chart-sources/victoria-metrics-cluster
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/vmcluster
default: |
  victoria-metrics-cluster:
    vmselect:
      enabled: false
    vminsert:
      enabled: false
immutable: |
  victoria-metrics-cluster:
    vmauth:
      enabled: false
    vmstorage:
      enabled: true
    vmbackupmanager:
      enabled: false
{{- end }}
