{{- define "addons.incloudwebresources" }}
name: IncloudWebResources
debug: false
path: helm-chart-sources/incloud-web-resources
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "incloudwebresources" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
