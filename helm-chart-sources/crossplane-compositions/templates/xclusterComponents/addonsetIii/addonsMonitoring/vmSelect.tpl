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
    loadBalancerService:
      enabled: false
  ` }}
{{- end -}}