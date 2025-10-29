{{- define "xclusterComponents.addonsetIii.prometheusNodeExporter" -}}
  {{- printf `
prometheusNodeExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsPrometheusNodeExporter
  namespace: beget-prometheus-node-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  values:
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}