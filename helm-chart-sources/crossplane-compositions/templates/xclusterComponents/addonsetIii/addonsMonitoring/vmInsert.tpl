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
          - key: "dedicated"
            value: "monitoring"
            effect: "NoSchedule"
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: node-role.kubernetes.io/monitoring
                      operator: Exists
  ` }}
{{- end -}}