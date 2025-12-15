{{- define "addons.istiogw" }}
name: IstioGw
debug: false
path: helm-chart-sources/istio-gw
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "istiogw" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  gateway:
    priorityClassName: system-cluster-critical
    service:
      type: NodePort
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
manifest:
  spec:
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
{{- end }}
