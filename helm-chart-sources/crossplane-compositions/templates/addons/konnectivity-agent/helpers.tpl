{{- define "addons.konnectivityagent" }}
name: KonnectivityAgent
debug: false
path: helm-chart-sources/konnectivity-agent
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/konnectivity
{{- end }}
