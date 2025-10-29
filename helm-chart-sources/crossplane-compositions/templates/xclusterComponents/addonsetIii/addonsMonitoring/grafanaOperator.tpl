{{- define "xclusterComponents.addonsetIii.grafanaOperator" -}}
  {{- printf `
grafanaOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsGrafanaOperator
  namespace: beget-grafana-operator
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