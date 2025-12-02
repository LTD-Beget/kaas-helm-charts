{{- define "addons.commoncrds" }}
name: CommonCrds
debug: false
path: helm-chart-sources/common-crds
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
pluginName: helm-with-values
default: |
  argocd:
    enabled: true
{{- end }}
