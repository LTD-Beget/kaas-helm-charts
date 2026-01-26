{{- define "newaddons.certControllerManager" -}}
  {{- printf `
certControllerManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertControllerManager
  namespace: beget-system
  version: v1alpha1
  ` }}
{{- end -}}

