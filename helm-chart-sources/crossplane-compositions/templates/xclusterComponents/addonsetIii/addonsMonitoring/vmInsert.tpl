{{- define "xclusterComponents.addonsetIii.vmInsert" -}}
  {{- printf `
vmInsert:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsInsert
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vminsert
  dependsOn:
    - vmOperator
  ` }}
{{- end -}}