{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.initConfiguration.users" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true
  jsonPatches:
    - op: add
      path: "/spec/template/spec/kubeadmConfigSpec/users"
      valueFrom:
        template: |
          {{ .Values.capi.k8s.users | toJson }}
{{- end -}}
