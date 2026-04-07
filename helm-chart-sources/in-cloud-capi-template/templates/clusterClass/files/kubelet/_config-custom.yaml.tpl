{{- define "in-cloud-capi-template.files.kubelet.configCustom.yaml" -}}
- path: /var/lib/kubelet/config-custom.yaml
  owner: root:root
  permissions: '0644'
  content: |
    ---
    apiVersion: kubelet.config.k8s.io/v1beta1
    authentication:
      anonymous:
          enabled: false
      webhook:
          cacheTTL: 0s
          enabled: true
      x509:
        clientCAFile: "/etc/kubernetes/pki/ca.crt"
    authorization:
      mode: Webhook
      webhook:
        cacheAuthorizedTTL: 0s
        cacheUnauthorizedTTL: 0s
    cgroupDriver: systemd

    # Для того, что бы сделать эту часть конфигурации статичной
    # все динамичные части будут определены через переменные окружения 
    # systemd Unit kubelet
    # >>>>>>
    clusterDNS:
    - {{`{{ .clusterDnsSvc }}`}}
    clusterDomain: {{`{{ .internalClusterName }}.{{ .internalClusterDomain }}`}}
    # TODO нужны только при hardway
    # tlsCertFile: "/var/lib/kubelet/pki/kubelet-server-current.pem"
    # tlsPrivateKeyFile: "/var/lib/kubelet/pki/kubelet-server-current.pem"
    
    containerLogMaxSize: "50Mi"
    containerRuntimeEndpoint: "{{ .Values.capi.k8s.containerRuntime.socket }}"
    cpuManagerReconcilePeriod: 0s
    evictionPressureTransitionPeriod: 5s
    fileCheckFrequency: 0s
    healthzBindAddress: 127.0.0.1
    healthzPort: 10248
    httpCheckFrequency: 0s
    imageGCHighThresholdPercent: 55
    imageGCLowThresholdPercent: 50
    imageMaximumGCAge: 0s
    imageMinimumGCAge: 0s
    kind: KubeletConfiguration
    logging:
      flushFrequency: 0
      options:
        json:
          infoBufferSize: "0"
        text:
          infoBufferSize: "0"
      verbosity: 0
    kubeAPIQPS: 50
    kubeAPIBurst: 100
    maxPods: 250
    memorySwap: {}
    nodeStatusReportFrequency: 1s
    nodeStatusUpdateFrequency: 1s
    podPidsLimit: 4096
    registerNode: true
    resolvConf: /run/systemd/resolve/resolv.conf
    rotateCertificates: true
    runtimeRequestTimeout: 0s
    serializeImagePulls: false
    serverTLSBootstrap: true
    shutdownGracePeriod: 15s
    shutdownGracePeriodCriticalPods: 5s
    staticPodPath: /etc/kubernetes/manifests
    streamingConnectionIdleTimeout: 0s
    syncFrequency: 0s
    tlsMinVersion: "VersionTLS12"
    volumeStatsAggPeriod: 0s
    featureGates:
      RotateKubeletServerCertificate: true
    tlsCipherSuites:
      - "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
      - "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      - "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
      - "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
      - "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
      - "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
{{- end }}
