{{- define "xclusterComponents.addonsetIii.clickhouseVmstorage" -}}
  {{- printf `
clickhouseVmstorage:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsClickhouseVmstorage
  namespace: beget-clickhouse-vmstorage
  version: v1alpha1
  dependsOn:
    - vmOperator
    - grafanaOperator
  ` }}
{{- end -}}
