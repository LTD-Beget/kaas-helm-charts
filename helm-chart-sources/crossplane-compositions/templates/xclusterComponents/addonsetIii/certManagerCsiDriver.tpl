{{- define "xclusterComponents.addonsetIii.certManagerCsiDriver" -}}
  {{- printf `
certManagerCsiDriver:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManagerCsiDriver
  namespace: beget-certmanager-csi-driver
  version: v1alpha1
  dependsOn: 
  - cilium
  {{ if $infraVMOperatorReady }}
  values:
    monitoring:
      enabled: true
  {{ end }}
  ` }}
{{- end -}}
