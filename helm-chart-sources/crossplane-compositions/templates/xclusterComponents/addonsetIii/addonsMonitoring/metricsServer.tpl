{{- define "xclusterComponents.addonsetIii.metricsServer" -}}
  {{- printf `
metricsServer:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsMetricsServer
  namespace: beget-metrics-server
  version: v1alpha1
  values:
    monitoring:
      enabled: true
      type: VictoriaMetrics

  ` }}
{{- end -}}