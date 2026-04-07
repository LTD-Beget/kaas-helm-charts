{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.preKubeadmCommands" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/preKubeadmCommands
      valueFrom:
        template: |
          {{- include "in-cloud-capi-template.commandsCp.all.aggregate" . | nindent 10 }}
{{- end -}}
