{{- define "addons.commoncrds" }}
name: CommonCrds
debug: false
path: helm-chart-sources/common-crds
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "commoncrds" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  argocd:
    enabled: true
{{- end }}
