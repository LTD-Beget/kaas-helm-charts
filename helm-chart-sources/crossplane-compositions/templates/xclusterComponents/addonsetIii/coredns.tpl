{{- define "xclusterComponents.addonsetIii.coredns" -}}
  {{- printf `
coredns:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCoredns
  finalizerDisabled: false
  namespace: beget-coredns
  version: v1alpha1
  dependsOn: 
    - istioGW
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    coredns:
      replicaCount: {{ $controlPlaneReplicas }}
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: coredns
                  app.kubernetes.io/instance: coredns
              topologyKey: kubernetes.io/hostname
    monitoring:
      keepKey: ""
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
    {{ if $certManagerReady }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    {{ end }}
  ` }}
{{- end -}}
