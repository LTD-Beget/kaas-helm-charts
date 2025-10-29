{{- define "xclusterComponents.addonsetIii.metricsServer" -}}
  {{- printf `
metricsServer:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsMetricsServer
  namespace: beget-metrics-server
  version: v1alpha1
  dependsOn:
    - certManagerCsiDriver
  values:
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}