{{- define "addons.trivyoperator" }}
name: TrivyOperator
debug: false
path: helm-chart-sources/trivy-operator
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
pluginName: kustomize-helm-with-values
default: |
  trivy-operator:
    trivy:
      storageClassEnabled: false
      severity: HIGH,CRITICAL
      resources:
        requests:
          cpu: 100m
          memory: 128M
        limits:
          cpu: 750m
          memory: 750M
      server:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
{{- end }}
