{{- define "addons.dex" }}
name: Dex
debug: false
path: helm-chart-sources/dex
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "dex" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  dex:
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
{{- end }}
