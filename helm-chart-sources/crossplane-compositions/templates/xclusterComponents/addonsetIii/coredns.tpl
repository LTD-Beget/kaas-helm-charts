{{- define "xclusterComponents.addonsetIii.coredns" -}}
  {{- printf `
coredns:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCoredns
  namespace: beget-coredns
  version: v1alpha1
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
  {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
  {{ end }}
  ` }}
{{- end -}}
