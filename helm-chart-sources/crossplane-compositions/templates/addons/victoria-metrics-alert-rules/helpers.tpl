{{- define "addons.victoriametricsalertrules" }}
name: VictoriaMetricsAlertRules
debug: false
path: helm-chart-sources/alert-rules
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "victoriametricsalertrules" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
