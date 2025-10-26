{{- define "addons.istiod" }}
name: Istiod
debug: false
path: helm-chart-sources/istiod
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
pluginName: kustomize-helm-with-values
default: |
  istiod:
    base:
      validationCABundle: ""
    pilot:
      autoscaleMin: 2
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        # limits:
        #   cpu: 1
        #   memory: 2048Mi
    global:
      priorityClassName: system-cluster-critical
      istioNamespace: beget-istio
      proxy:
        tracer: zipkin
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
manifest:
  spec:
    forProvider:
      manifest:
        spec:
          ignoreDifferences:
          - group: admissionregistration.k8s.io
            kind: ValidatingWebhookConfiguration
            jsonPointers:
            - /webhooks/0/failurePolicy
{{- end }}
