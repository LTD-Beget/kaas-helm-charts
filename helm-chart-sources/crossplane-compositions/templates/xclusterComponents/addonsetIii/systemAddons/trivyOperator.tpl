{{- define "xclusterComponents.addonsetIii.trivyOperator" -}}
  {{- printf `
trivyOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsTrivyOperator
  namespace: beget-trivy-operator
  version: v1alpha1
  dependsOn:
    - vmOperator
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
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
          - key: "node-role.kubernetes.io/argocd"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/crossplane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/vm-stream"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/vm-data"
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
          - key: "node-role.kubernetes.io/argocd"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/crossplane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/vm-stream"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/vm-data"
            operator: "Exists"
            effect: "NoSchedule"
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
