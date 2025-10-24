{{- define "xclusterComponents.addonsetIii.capi" -}}
  {{- printf `
capi:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapi
  namespace: beget-capi
  version: v1alpha1
  ` }}
{{- end -}}