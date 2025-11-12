{{- define "xclusterComponents.addonsetIii.vmSelect" -}}
  {{- printf `
vmSelect:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsSelect
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vmselect
  dependsOn:
    - vmOperator
  ` }}
{{- end -}}