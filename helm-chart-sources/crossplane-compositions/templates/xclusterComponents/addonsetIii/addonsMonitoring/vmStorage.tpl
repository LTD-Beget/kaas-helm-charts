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
      vmstorage:
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