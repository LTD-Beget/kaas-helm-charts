{{- define "addons.vault" }}
name: Vault
debug: false
path: helm-chart-sources/vault
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "vault" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}

{{- end }}
