{{- define "addons.kubeadmResources" }}
name: KubeadmResources
debug: false
path: helm-chart-sources/kubeadm-resources-client-cp
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "kubeadmResources" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
immutable: |
  clusterInfo:
    clusterApiUrl: {{ "https://{{ .host }}:{{ .port }}" }}
    clusterName: {{ "{{ .clusterName }}" }}
  kubeadmConfig:
    namespace: kube-system
    clusterConfiguration:
      clusterName: {{ "{{ .clusterName }}" }}
      controlPlaneEndpoint: {{ "{{ .host }}:{{ .port }}" }}
  rbac:
    authExtraGroups: "system:bootstrappers:kubeadm:default-node-token"
{{- end }}
