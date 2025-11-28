{{- define "xclusterComponents.addonsetIii.crossplaneCompositions" -}}
  {{- printf `
crossplaneCompositions:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplaneCompositions
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  targetRevision: feat/xclusterComponents
  values:
    xclusterComponents:
      client:
        enabled: {{ $xAddonSetClientEnabled }}

  ` }}
{{- end -}}