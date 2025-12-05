{{- define "addons.konnectivityserver" }}
name: KonnectivityServer
debug: false
path: helm-chart-sources/konnectivity-server
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "konnectivityserver" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
