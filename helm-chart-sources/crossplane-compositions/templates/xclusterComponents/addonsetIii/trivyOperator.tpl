{{- define "xclusterComponents.addonsetIii.trivyOperator" -}}
  {{- printf `
trivyOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsTrivyOperator
  namespace: beget-trivy-operator
  version: v1alpha1
  values:
    trivy-operator:
      trivyOperator:
        scanJobNodeSelector:
          node-role.kubernetes.io/control-plane: ""
        scanJobTolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      nodeCollector:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"            
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}