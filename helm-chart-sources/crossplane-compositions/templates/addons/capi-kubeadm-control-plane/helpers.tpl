{{- define "addons.capikubeadmcontrolplane" }}
name: CapiKubeadmControlPlane
debug: false
path: helm-chart-sources/capi-kubeadm-control-plane
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "capikubeadmcontrolplane" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
manifest:
  spec:
    syncPolicy:
      syncOptions:
      - ServerSideApply=true
{{- end }}
