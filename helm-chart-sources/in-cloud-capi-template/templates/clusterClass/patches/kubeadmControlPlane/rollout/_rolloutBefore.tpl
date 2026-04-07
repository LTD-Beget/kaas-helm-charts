{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.rollout.rolloutBefore" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/rollout/before/certificatesExpiryDays
      value: 180
{{- end -}}