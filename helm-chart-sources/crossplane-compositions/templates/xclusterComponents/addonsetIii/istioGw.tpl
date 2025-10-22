{{- define "xclusterComponents.addonsetIii.istioGw" -}}
  {{- printf `
istioGW:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstioGw
  namespace: beget-istio-gw
  version: v1alpha1
  dependsOn:
    - dex
    - istioBase
  values:
    gateway:
      service:
        type: NodePort
        ports:
          - name: status-port
            port: 15021
            protocol: TCP
            targetPort: 15021
            nodePort: 32021
          - name: http2
            port: 80
            protocol: TCP
            targetPort: 80
            nodePort: 32080
          - name: https
            port: 443
            protocol: TCP
            targetPort: 443
            nodePort: 32443
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
      type: VictoriaMetrics
      namespace: beget-istio-gw
      {{- end }}
    tls:
      enabled: true
      issuer:
        kind: ClusterIssuer
        name: oidc-ca
      certificate:
        name: {{ $clusterName }}-gateway
        secretName: {{ $clusterName }}-gateway
        commonName: infra-gateway
        dnsNames:
          - "*"
        ipAddresses:
          - 127.0.0.1
    extraGateway:
      enabled: true
      name: default
      servers:
        - hosts: ["*"]
          port:
            protocol: HTTPS
          tls:
            mode: SIMPLE
            credentialName: {{ $clusterName }}-gateway
        - hosts: ["*"]
          port:
            protocol: HTTP 
    telemetry:
      enabled: true

  ` }}
{{- end -}}