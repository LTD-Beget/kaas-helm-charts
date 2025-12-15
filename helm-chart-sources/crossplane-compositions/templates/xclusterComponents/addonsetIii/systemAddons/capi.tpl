{{- define "xclusterComponents.addonsetIii.capi" -}}
  {{- printf `
capi:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapi
  namespace: beget-capi
  version: v1alpha1
  dependsOn:
  - certManager
  values:
    certificates:
      useExternalIssuer: true
      externalIssuer:
        name: selfsigned-cluster-issuer

    {{ if $infraVMOperatorReady }}
    monitoring:
      vmServiceScrape:
        enabled: true
    {{ end }}
  ` }}
{{- end -}}
