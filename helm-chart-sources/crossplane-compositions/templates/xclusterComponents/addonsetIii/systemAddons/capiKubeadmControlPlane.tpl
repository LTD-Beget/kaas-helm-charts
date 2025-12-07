{{- define "xclusterComponents.addonsetIii.capiKubeadmControlPlane" -}}
  {{- printf `
capiKubeadmControlPlane:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiKubeadmControlPlane
  namespace: beget-capi
  version: v1alpha1
  dependsOn:
  - certManager
  values:
    fullnameOverride: "capi-kcp"
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
