{{- define "xclusterComponents.addonsetIic.kubeadmResources" -}}
  {{- printf `
kubeadmResources:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsKubeadmResources
  namespace: beget-kubeadm-resources
  version: v1alpha1
  values:
    clusterInfo:
      kubeCaCrtBase64: "{{ $clientCa }}"
  ` }}
{{- end -}}
