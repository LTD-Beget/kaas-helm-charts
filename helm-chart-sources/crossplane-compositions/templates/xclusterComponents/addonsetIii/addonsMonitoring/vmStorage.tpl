{{- define "xclusterComponents.addonsetIii.vmStorage" -}}
  {{- printf `
vmStorage:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsStorage
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vmstorage
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-cluster:
      vmselect:
        enabled: true
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      vminsert:
        enabled: true
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      vmstorage:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
  ` }}
{{- end -}}