{{- define "addons.vaultSecrets" }}
name: VaultSecrets
debug: false
path: helm-chart-sources/vault-secrets
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
pluginName: argocd-vault-plugin-helm-with-values

{{- end }}
