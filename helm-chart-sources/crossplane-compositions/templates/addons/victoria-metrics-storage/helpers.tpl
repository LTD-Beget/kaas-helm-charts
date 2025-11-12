{{- define "addons.victoriametricsstorage" }}
name: VictoriaMetricsStorage
debug: false
path: helm-chart-sources/victoria-metrics-cluster
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/vmcluster
immutable: |
  victoria-metrics-cluster:
    vmselect:
      enabled: false
    vminsert:
      enabled: false
    vmauth:
      enabled: false
    vmstorage:
      enabled: true
    vmbackupmanager:
      enabled: false
{{- end }}
