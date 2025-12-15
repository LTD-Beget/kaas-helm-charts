{{- define "xclusterComponents.addonsetIii.prometheusNodeExporter" -}}
  {{- printf `
prometheusNodeExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsPrometheusNodeExporter
  namespace: beget-prometheus-node-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
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
