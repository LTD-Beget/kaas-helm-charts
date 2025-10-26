{{- define "addons.incloudui" }}
name: IncloudUi
debug: false
path: helm-chart-sources/incloud-ui
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
pluginName: kustomize-helm-with-values
default: |
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
{{- end }}
