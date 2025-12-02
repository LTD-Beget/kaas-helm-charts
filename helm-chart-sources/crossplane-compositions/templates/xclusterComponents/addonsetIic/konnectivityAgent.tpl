{{- define "xclusterComponents.addonsetIic.konnectivityAgent" -}}
  {{- printf `
konnectivityAgent:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsKonnectivityAgent
  namespace: beget-konnectivity-agent
  version: v1alpha1
  values:
    hostNetwork: true
    agent:
      extraArgs:
        proxy-server-host: {{ $clusterHost }}
        proxy-server-port: 8132
  ` }}
{{- end -}}