{{- define "addons.clickhousevmstorage" }}
name: ClickhouseVmstorage
debug: false
path: helm-chart-sources/clickhouse-vmstorage
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "clickhousevmstorage" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
{{- end }}
