{{- define "xclusterComponents.addonsetIii.grafanaOperator" -}}
  {{- printf `
grafanaOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsGrafanaOperator
  namespace: beget-grafana-operator
  version: v1alpha1
  dependsOn: 
  - cilium
  values:
    monitoring:
      enabled: true
      type: VictoriaMetrics
  ` }}
{{- end -}}