{{- define "xclusterComponents.addonsetIii.vmStorage" -}}
  {{- printf `
vmStorage:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsStorage
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vmstorage
  dependsOn:
    - vmOperator
  ` }}
{{- end -}}