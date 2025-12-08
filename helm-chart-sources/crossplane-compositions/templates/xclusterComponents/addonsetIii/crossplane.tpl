{{- define "xclusterComponents.addonsetIii.crossplane" -}}
  {{- printf `
crossplane:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplane
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  dependsOn:
    - istioGW
  values:
  {{- if and $systemEnabled $crossplaneReady }}
    args:
      - '--enable-realtime-compositions'
      - '--enable-composition-webhook-schema-validation'
      - '--enable-composition-functions'
      - '--enable-usages'
      - '--leader-election'
      - '--max-reconcile-rate=50'
      - '--poll-interval=5s'
      - '--sync-interval=1m'
    resourcesCrossplane:
      requests: { cpu: "4",  memory: "4Gi" }
      limits:   { cpu: "16", memory: "16Gi" }
    nodeSelector:
        node-role.kubernetes.io/crossplane: ''
    tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/crossplane	
        operator: Exists	
      - effect: NoSchedule
        key: node-role.kubernetes.io/control-plane
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
  {{- end }}
  ` }}
{{- end -}}