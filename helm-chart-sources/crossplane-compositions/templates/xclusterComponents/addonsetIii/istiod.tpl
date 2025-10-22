{{- define "xclusterComponents.addonsetIii.istiod" -}}
  {{- printf `
istiod:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstiod
  namespace: beget-istio
  version: v1alpha1
  dependsOn:
  - istioBase
  values:
    istiod:
      replicaCount: {{ $controlPlaneReplicas }}
      autoscaleMin: "1"
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
                  app.kubernetes.io/name: istiod
                  app.kubernetes.io/instance: istiod
              topologyKey: kubernetes.io/hostname
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{- end }}
  ` }}
{{- end -}}