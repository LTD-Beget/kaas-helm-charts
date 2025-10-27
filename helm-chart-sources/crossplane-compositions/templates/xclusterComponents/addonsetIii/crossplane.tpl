{{- define "xclusterComponents.addonsetIii.crossplane" -}}
  {{- printf `
crossplane:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplane
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  targetRevision: 1.20.1
  values:
    hostNetwork: true
    args:
      - '--enable-realtime-compositions'
      - '--enable-composition-webhook-schema-validation'
      - '--enable-composition-functions'
      - '--enable-usages'
      - '--poll-interval=5s'
      - '--sync-interval=1m'
      - '--max-reconcile-rate=20'
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
    rbacManager:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
  ` }}
{{- end -}}