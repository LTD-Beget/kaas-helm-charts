{{- define "addons.victoriametricsinsert" }}
name: VictoriaMetricsInsert
debug: false
path: helm-chart-sources/victoria-metrics-cluster
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/vmcluster
immutable: |
  victoria-metrics-cluster:
    vmselect:
      enabled: false
    vminsert:
      enabled: true
    vmauth:
      enabled: false
    vmstorage:
      enabled: false
    vmbackupmanager:
      enabled: false
{{- end }}
