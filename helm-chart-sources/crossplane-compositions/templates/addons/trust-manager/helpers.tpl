{{- define "addons.trustmanager" }}
name: TrustManager
debug: false
path: helm-chart-sources/trustmanager
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
pluginName: kustomize-helm-with-values
default: |
  trust-manager:
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
