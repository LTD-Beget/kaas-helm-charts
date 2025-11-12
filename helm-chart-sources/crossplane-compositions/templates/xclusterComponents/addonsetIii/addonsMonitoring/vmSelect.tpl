{{- define "xclusterComponents.addonsetIii.vmSelect" -}}
  {{- printf `
vmSelect:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsSelect
  namespace: beget-vmstorage
  version: v1alpha1
  releaseName: vmselect
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-cluster:
      vmselect:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
  ` }}
{{- end -}}