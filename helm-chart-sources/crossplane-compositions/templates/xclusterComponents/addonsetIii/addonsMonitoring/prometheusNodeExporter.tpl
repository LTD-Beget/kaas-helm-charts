{{- define "xclusterComponents.addonsetIii.prometheusNodeExporter" -}}
  {{- printf `
prometheusNodeExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsPrometheusNodeExporter
  namespace: beget-prometheus-node-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    prometheus-node-exporter:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      {{ if $systemEnabled }}
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
      {{ end }}
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
