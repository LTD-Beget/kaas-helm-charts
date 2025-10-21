{{- define "addons.crossplanefunctions" }}
name: CrossplaneFunctions
debug: false
path: helm-chart-sources/crossplane-functions
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/crossplane
manifest:
  spec:
    forProvider:
      manifest:
        spec:
          syncPolicy:
            retry:
              limit: 100
              backoff:
                duration: 5s
                factor: 1
                maxDuration: 3m0s
{{- end }}
