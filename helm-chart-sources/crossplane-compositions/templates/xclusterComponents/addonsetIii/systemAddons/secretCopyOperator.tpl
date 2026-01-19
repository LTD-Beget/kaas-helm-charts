{{- define "xclusterComponents.addonsetIii.certControllerManager" -}}
  {{- printf `
secretCopyOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsSecretCopyOperator
  namespace: beget-system
  version: v1alpha1
  ` }}
{{- end -}}
