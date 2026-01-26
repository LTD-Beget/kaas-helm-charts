{{- define "newaddons.vmAlertRules" -}}
  {{- printf `
vmAlertRules:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlertRules
  namespace: beget-vmalert-rules
  version: v1alpha1
  releaseName: vmalertrules
  dependsOn:
    - vmOperator
  ` }}
{{- end -}}
