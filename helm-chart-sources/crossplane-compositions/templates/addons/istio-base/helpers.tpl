{{- define "addons.istiobase" }}
name: IstioBase
debug: false
chart: base
repoURL: https://istio-release.storage.googleapis.com/charts
targetRevision: 1.26.0
default: |
  global:
    istioNamespace: beget-istio
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
