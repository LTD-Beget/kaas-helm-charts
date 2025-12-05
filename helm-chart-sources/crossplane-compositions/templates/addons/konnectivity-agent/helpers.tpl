{{- define "addons.konnectivityagent" }}
name: KonnectivityAgent
debug: false
path: helm-chart-sources/konnectivity-agent
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "konnectivityagent" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
