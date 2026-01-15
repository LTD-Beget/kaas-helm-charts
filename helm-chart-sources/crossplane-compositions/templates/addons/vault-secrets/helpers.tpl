{{- define "addons.vaultSecrets" }}
name: VaultSecrets
debug: false
path: helm-chart-sources/vault-secrets
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "vaultSecrets" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
values:
  argocdPlugins:
    vault: true
{{- end }}
