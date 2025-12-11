{{- define "xclusterComponents.addonsetIii.istioBase" -}}
  {{- printf `
istioBase:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstioBase
  namespace: beget-istio
  version: v1alpha1
  ` }}
{{- end -}}
