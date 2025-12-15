{{- define "addons.istiod" }}
name: Istiod
debug: false
path: helm-chart-sources/istiod
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "istiod" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
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
manifest:
  spec:
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
{{- end }}
