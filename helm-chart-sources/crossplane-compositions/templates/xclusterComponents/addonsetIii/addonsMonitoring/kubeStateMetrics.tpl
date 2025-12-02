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
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}