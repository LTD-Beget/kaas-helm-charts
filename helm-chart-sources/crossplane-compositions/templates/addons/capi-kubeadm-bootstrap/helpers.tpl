{{- define "addons.capikubeadmbootstrap" }}
name: CapiKubeadmBootstrap
debug: false
path: helm-chart-sources/capi-kubeadm-bootstrap
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "capikubeadmbootstrap" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
