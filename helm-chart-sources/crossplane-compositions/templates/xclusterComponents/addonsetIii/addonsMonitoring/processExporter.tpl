{{- define "xclusterComponents.addonsetIii.processExporter" -}}
  {{- printf `
processExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsProcessExporter
  namespace: beget-process-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  values:
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}