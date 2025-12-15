{{- define "xclusterComponents.addonsetIii.istiod" -}}
  {{- printf `
istiod:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstiod
  namespace: beget-istio
  version: v1alpha1
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    istiod:
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
                  app.kubernetes.io/name: istiod
                  app.kubernetes.io/instance: istiod
              topologyKey: kubernetes.io/hostname
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
