{{- define "xclusterComponents.addonsetIii.trustManager" -}}
  {{- printf `
trustManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsTrustManager
  namespace: beget-trust-manager
  version: v1alpha1
  dependsOn:
    - vmOperator
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
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
      name: "ca"
      sources:
        - secret:
            name: {{ $clusterName }}-ca-oidc
            key: tls.crt
        - secret:
            name: selfsigned-cluster-ca
            key: tls.crt
      target:
        namespaceSelector:
          matchLabels:
      {{ if $systemEnabled }}
            in-cloud.io/caBundle: "approved"
      {{ else }}
            in-cloud.io/clusterName: {{ $clusterName }}
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
