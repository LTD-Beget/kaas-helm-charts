{{- define "addons.dex" }}
name: Dex
debug: false
path: helm-chart-sources/dex
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
plugin:
  name: kustomize-helm-with-values
default: |
  dex:
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
{{- end }}
