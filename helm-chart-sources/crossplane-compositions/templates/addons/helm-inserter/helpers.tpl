{{- define "addons.helminserter" }}
name: HelmInserter
debug: false
path: .
path: helm-chart-sources/helm-inserter
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "helminserter" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
