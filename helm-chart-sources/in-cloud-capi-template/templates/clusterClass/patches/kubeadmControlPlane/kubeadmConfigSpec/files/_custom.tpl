{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.files" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/files
      valueFrom:
        template: |
          {{- (include "in-cloud-capi-template.files.all.aggregate.controlPlane" .) | nindent 10  }}
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/files/-
      value:
        path: /etc/default/kubelet/extra-args.env
        owner: root:root
        permissions: '0644'
        content: |
          KUBELET_EXTRA_ARGS="--provider-id={{ $.Values.companyPrefix }}:///{{`{{ ds.meta_data.instance_id.split(':')[0] }}`}}"
{{- end -}}
