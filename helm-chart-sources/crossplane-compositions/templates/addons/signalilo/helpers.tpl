{{- define "addons.signalilo" }}
name: Signalilo
debug: false
path: helm-chart-sources/signalilo
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "signalilo" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values

{{- end }}
