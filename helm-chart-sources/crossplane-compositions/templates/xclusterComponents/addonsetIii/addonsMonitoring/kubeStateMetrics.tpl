{{- define "xclusterComponents.addonsetIii.kubeStateMetrics" -}}
  {{- printf `
kubeStateMetrics:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsKubeStateMetrics
  namespace: beget-kube-state-metrics
  version: v1alpha1
  dependsOn:
    - vmOperator
  values:
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
