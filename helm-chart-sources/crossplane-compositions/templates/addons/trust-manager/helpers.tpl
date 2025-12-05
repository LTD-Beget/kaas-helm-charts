{{- define "addons.trustmanager" }}
name: TrustManager
debug: false
path: helm-chart-sources/trustmanager
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "trustmanager" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
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
