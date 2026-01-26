{{- define "xclusterComponents.addonsetIii.addonsOperator" -}}
  {{- printf `
addonsOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsAddonsOperator
  namespace: beget-system
  version: v1alpha1
  ` }}
{{- end -}}

