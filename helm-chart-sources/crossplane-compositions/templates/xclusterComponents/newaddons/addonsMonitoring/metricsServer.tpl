{{- define "newaddons.metricsServer" -}}
  {{- printf `
metricsServer:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsMetricsServer
  namespace: beget-metrics-server
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
