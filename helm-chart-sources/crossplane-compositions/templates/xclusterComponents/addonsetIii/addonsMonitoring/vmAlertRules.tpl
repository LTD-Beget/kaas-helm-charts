{{- define "xclusterComponents.addonsetIii.vmAlertRules" -}}
  {{- printf `
vmAlertRules:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlertRules
  namespace: beget-vmalert-rules
  version: v1alpha1
  dependsOn:
  - vmOperator
  ` }}
{{- end -}}