{{- define "addons.vault" }}
name: Vault
debug: false
path: helm-chart-sources/vault
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD

{{- end }}
