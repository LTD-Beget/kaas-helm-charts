{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.postKubeadmCommands" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/postKubeadmCommands
      value:
        - bash /etc/default/postKubeadmCommand/commands.sh

    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/postKubeadmCommands/-
      value: 'kubectl --kubeconfig=/etc/kubernetes/admin.conf label node $(hostname -s) node.kubernetes.io/exclude-from-external-load-balancers- --overwrite || true'
{{- end -}}
