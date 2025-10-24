{{- define "xclusterComponents.addonsetIii.certManager" -}}
  {{- printf `
certManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManager
  namespace: beget-certmanager
  version: v1alpha1
  values:
  dependsOn: 
  - cilium
    cert-manager:
      clusterResourceNamespace: beget-system
  {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
  {{ end }}
  ` }}
{{- end -}}
