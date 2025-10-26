{{- define "addons.dex" }}
name: Dex
debug: false
path: helm-chart-sources/dex
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
pluginName: kustomize-helm-with-values
default: |
  dex:
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
{{- end }}
