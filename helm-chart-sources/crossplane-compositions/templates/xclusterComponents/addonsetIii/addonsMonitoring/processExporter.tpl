{{- define "xclusterComponents.addonsetIii.processExporter" -}}
  {{- printf `
processExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsProcessExporter
  namespace: beget-process-exporter
  version: v1alpha1
  values:
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}