{{- define "addons.dex" }}
name: Dex
debug: false
path: helm-chart-sources/dex
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
default: |
  dex:
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
{{- end }}
