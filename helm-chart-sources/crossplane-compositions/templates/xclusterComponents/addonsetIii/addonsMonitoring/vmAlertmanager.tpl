{{- define "xclusterComponents.addonsetIii.vmAlertmanager" -}}
  {{- printf `
vmAlertmanager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlertmanager
  namespace: beget-alertmanager
  version: v1alpha1
  dependsOn:
  - vmOperator
  values:
    fullnameOverride: "alertmanager"
    alertmanager:
      spec:
        podMetadata:
          labels:
            in-cloud-metrics: "infra"
        configSelector:
          matchLabels:
            in-cloud-metrics: "infra"
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"

  ` }}
{{- end -}}