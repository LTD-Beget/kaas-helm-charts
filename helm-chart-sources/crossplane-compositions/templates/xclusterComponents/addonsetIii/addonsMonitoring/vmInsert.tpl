{{- define "xclusterComponents.addonsetIii.vmInsert" -}}
  {{- printf `
vmInsert:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsInsert
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vminsert
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-cluster:
      vminsert:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
  ` }}
{{- end -}}