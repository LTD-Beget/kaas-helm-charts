{{- define "addons.incloudui" }}
name: IncloudUi
debug: false
path: helm-chart-sources/incloud-ui
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
pluginName: kustomize-helm-with-values
{{- end }}
