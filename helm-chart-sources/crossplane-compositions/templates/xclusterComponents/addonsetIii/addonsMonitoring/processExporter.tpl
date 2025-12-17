{{- define "xclusterComponents.addonsetIii.processExporter" -}}
  {{- printf `
processExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsProcessExporter
  namespace: beget-process-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    prometheus-process-exporter:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      {{- if $systemEnabled }}
        - key: "node-role.kubernetes.io/argocd"
          operator: "Exists"
          effect: "NoSchedule" 
        - key: "node-role.kubernetes.io/crossplane"
          operator: "Exists"
          effect: "NoSchedule" 
        - key: "dedicated"
          value: "vminsert"
          effect: "NoSchedule" e" 
      {{- end }}
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
