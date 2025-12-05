{{- define "addons.istiobase" }}
name: IstioBase
debug: false
chart: base
repoURL: https://istio-release.storage.googleapis.com/charts
{{- $addonValue := dig "composite" "addons" "istiobase" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  global:
    istioNamespace: beget-istio
manifest:
  spec:
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
{{- end }}
