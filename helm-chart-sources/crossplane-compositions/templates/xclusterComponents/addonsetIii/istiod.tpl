{{- define "xclusterComponents.addonsetIii.istiod" -}}
  {{- printf `
istiod:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstiod
  namespace: beget-istio
  version: v1alpha1
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    istiod:
      replicaCount: {{ $controlPlaneReplicas }}
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
  {{- if gt $controlPlaneReplicas 1 }}
      pilot:
        autoscaleMin: 2
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: istiod
                  app.kubernetes.io/instance: istiod
              topologyKey: kubernetes.io/hostname
  {{- else }}
      pilot:
        autoscaleMin: 1
      podAnnotations:
        cluster-autoscaler.kubernetes.io/safe-to-evict: "true"
  {{- end }}
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
