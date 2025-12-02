{{- define "addons.helminserter" }}
name: HelmInserter
debug: false
path: .
path: helm-chart-sources/helm-inserter
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
{{- end }}
