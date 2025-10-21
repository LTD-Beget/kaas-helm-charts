{{- define "xclusterComponents.addonsetIii.capiKubeadmBootstrap" -}}
  {{- printf `
capiKubeadmBootstrap:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiKubeadmBootstrap
  namespace: beget-capi
  version: v1alpha1
  values:
    fullnameOverride: "capi-kubeadm-bootstrap"
  ` }}
{{- end -}}