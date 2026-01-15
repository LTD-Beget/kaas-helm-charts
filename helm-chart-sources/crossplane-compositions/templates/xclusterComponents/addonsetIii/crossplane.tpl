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
    - certManager
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
  # TODO: Зачем дожидаться $crossplaneReady
  {{ if and $systemEnabled $crossplaneReady }}
    crossplane:
      args:
        - '--enable-realtime-compositions'
        - '--enable-composition-webhook-schema-validation'
        - '--enable-composition-functions'
        - '--enable-function-response-cache'
        - '--enable-usages'
        - '--leader-election'
        - '--max-reconcile-rate=200'
        - '--poll-interval=5s'
        - '--sync-interval=1m'
      resourcesCrossplane:
        requests: { cpu: "4",  memory: "4Gi" }
        limits:   { cpu: "16", memory: "32Gi" }
      nodeSelector:
          node-role.kubernetes.io/crossplane-core: ''
      tolerations:
        - effect: NoSchedule
          key: node-role.kubernetes.io/crossplane
          operator: Exists
        - effect: NoSchedule
          key: node-role.kubernetes.io/crossplane-core
          operator: Exists
        - effect: NoSchedule
          key: node-role.kubernetes.io/crossplane-prov
          operator: Exists
        - effect: NoSchedule
          key: node-role.kubernetes.io/control-plane
          operator: Exists
        - effect: NoSchedule
          key: node-role.kubernetes.io/master
          operator: Exists
      functionCache:
        sizeLimit: 10Gi
  {{ end }}
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
