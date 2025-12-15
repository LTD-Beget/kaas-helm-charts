{{- define "addons.incloudui" }}
name: IncloudUi
debug: false
path: helm-chart-sources/incloud-ui
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "incloudui" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
{{- end }}
