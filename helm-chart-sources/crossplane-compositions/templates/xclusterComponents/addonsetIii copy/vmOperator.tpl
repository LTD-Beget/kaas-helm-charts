{{- define "newaddons.vmOperator" -}}
  {{- printf `
vmOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsOperator
  namespace: beget-vm-operator
  version: v1alpha1
  dependsOn:
    - certManagerCsiDriver
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    victoria-metrics-operator:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    monitoring:
      enabled: true
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
