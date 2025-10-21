{{- define "xclusterComponents.addonsetIii.capiKubeadmControlPlane" -}}
  {{- printf `
capiKubeadmControlPlane:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiKubeadmControlPlane
  namespace: beget-capi
  version: v1alpha1
  values:
    fullnameOverride: "capi-kcp"
  ` }}
{{- end -}}