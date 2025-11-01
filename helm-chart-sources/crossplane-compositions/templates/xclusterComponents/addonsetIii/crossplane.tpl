{{- define "xclusterComponents.addonsetIii.crossplane" -}}
  {{- printf `
crossplane:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplane
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  targetRevision: 1.20.1
  dependsOn:
    - istioGW
  values:
  {{- if $systemEnabled }}
    args:
      - '--enable-realtime-compositions'
      - '--enable-composition-webhook-schema-validation'
      - '--enable-composition-functions'
      - '--enable-usages'
      - '--leader-elect'
      - '--max-reconcile-rate=30'
      - '--poll-interval=5s'
      - '--sync-interval=1m'
    resources:
      requests: { cpu: "1", memory: "1Gi" }
      limits:   { cpu: "4", memory: "4Gi" }
  {{- end }}
  ` }}
{{- end -}}