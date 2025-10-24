{{- define "xclusterComponents.addonsetIii.cilium" -}}
  {{- printf `
cilium:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCilium
  namespace: beget-cilium
  version: v1alpha1
  {{ if $infraVMOperatorReady }}
  values:
    monitoring:
      enabled: true
  {{ end }}
  ` }}
{{- end -}}
