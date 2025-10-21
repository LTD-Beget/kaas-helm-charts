{{- define "xclusterComponents.addonsetIii.crossplaneXcluster" -}}
  {{- printf `
crossplaneXcluster:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplaneXcluster
  namespace: beget-crossplane
  version: v1alpha1
  ` }}
{{- end -}}