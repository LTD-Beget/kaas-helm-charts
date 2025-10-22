{{- define "xclusterComponents.addonsetIii.vmOperator" -}}
  {{- printf `
vmOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsOperator
  namespace: beget-vm-operator
  version: v1alpha1
  values:
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
  ` }}
{{- end -}}