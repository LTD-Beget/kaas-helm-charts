{{- define "addons.crossplanecompositions" }}
name: CrossplaneCompositions
debug: false
path: helm-chart-sources/crossplane-compositions
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "crossplanecompositions" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
