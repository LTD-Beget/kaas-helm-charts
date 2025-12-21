{{- define "xclusterComponents.addonsetIii.capiKubeadmBootstrap" -}}
  {{- printf `
capiKubeadmBootstrap:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiKubeadmBootstrap
  namespace: beget-capi
  version: v1alpha1
  dependsOn:
    - certManager
  values:
    fullnameOverride: "capi-kubeadm-bootstrap"
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
