{{- define "xclusterComponents.addonsetIii.grafanaOperator" -}}
  {{- printf `
grafanaOperator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsGrafanaOperator
  namespace: beget-grafana-operator
  version: v1alpha1
  dependsOn:
    - vmOperator
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
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
