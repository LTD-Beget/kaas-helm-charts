{{- define "xclusterComponents.addonsetIii.trustManager" -}}
  {{- printf `
trustManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsTrustManager
  namespace: beget-trust-manager
  version: v1alpha1
  values:
    trust-manager:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      app:
        trust:
          namespace: beget-system
    bundle:
      enabled: true
      name: "oidc-ca.crt"
      sourceSecret:
        name: {{ $clusterName }}-ca-oidc-crt
      target:
        namespaceSelector:
          matchLabels:
            in-cloud.io/clusterName: {{ $clusterName }}
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
      type: VictoriaMetrics
    {{- end }}
  ` }}
{{- end -}}