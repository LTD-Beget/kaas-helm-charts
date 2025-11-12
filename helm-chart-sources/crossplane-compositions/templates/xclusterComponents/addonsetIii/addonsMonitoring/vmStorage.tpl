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
      vminsert:
        enabled: true
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
    loadBalancerService:
      enabled: true
      name: vminsert-lb
      annotations:
        lb.beget.com/algorithm: "round_robin"
        lb.beget.com/type: "internal"
        lb.beget.com/healthcheck-interval-seconds: "60"
        lb.beget.com/healthcheck-timeout-seconds: "5"
      labels:
        app: "vminsert"
      selector:
        app.kubernetes.io/name: "victoria-metrics-cluster"
        app.kubernetes.io/instance: "vmstorage"
        app: "vminsert"
  ` }}
{{- end -}}