{{- define "xclusterComponents.addonsetIii.istioGw" -}}
  {{- printf `
istioGW:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIstioGw
  namespace: beget-istio-gw
  version: v1alpha1
  dependsOn:
    - istioBase
  values:
    gateway:
      service:
        type: LoadBalancer
        annotations:
          {{- if $systemEnabled }}
          lb.beget.com/type: "internal"
          {{- else }}
          lb.beget.com/type: "external"
          {{- end }}
          lb.beget.com/algorithm: "round_robin" # or "least_conns"
          lb.beget.com/healthcheck-interval-seconds: "60"
          lb.beget.com/healthcheck-timeout-seconds: "5"
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
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
      {{ if $certManagerReady }}
        enabled: true
      {{ end }}
        issuer:
          name: selfsigned-cluster-issuer
    {{- if $systemEnabled }}
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
          - {{ $systemIstioGwVip }}
    {{- else }}
    tls:
      enabled: true
      issuer:
        kind: ClusterIssuer
        name: selfsigned-cluster-issuer
      certificate:
        name: {{ $clusterName }}-gateway
        secretName: {{ $clusterName }}-gateway
        commonName: infra-gateway
        dnsNames:
          - "*"
        ipAddresses:
          - 127.0.0.1
    {{- end }}
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
