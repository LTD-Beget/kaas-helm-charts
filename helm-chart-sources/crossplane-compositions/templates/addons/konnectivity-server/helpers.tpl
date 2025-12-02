{{- define "addons.konnectivityserver" }}
name: KonnectivityServer
debug: false
path: helm-chart-sources/konnectivity-server
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
{{- end }}
