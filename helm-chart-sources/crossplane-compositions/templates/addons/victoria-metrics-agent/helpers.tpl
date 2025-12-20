{{- define "addons.victoriametricsagent" }}
name: VictoriaMetricsAgent
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "victoriametricsagent" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  victoria-metrics-k8s-stack:
    vmagent:
      ingress:
        enabled: false
      spec:
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
            ephemeral-storage: "1Gi"
          limits:
            cpu: "500m"
            memory: "500Mi"
            ephemeral-storage: "1Gi"
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
        extraEnvs:
          - name: GOMAXPROCS
            value: '1'
        extraArgs:
          remoteWrite.tlsInsecureSkipVerify: "true"
          remoteWrite.label: remotewrite_cluster=cluster #namespace-cluster_name
          promscrape.streamParse: "true"
          promscrape.maxScrapeSize: "33554432"
          remoteWrite.maxDiskUsagePerURL: "67108864"
          remoteWrite.queues: "24"
          remoteWrite.shardByURL: "true"
          remoteWrite.shardByURLReplicas: "3"
        replicaCount: 1
        shardCount: 1
        updateStrategy: RollingUpdate
        rollingUpdate:
          maxSurge: 10%
          maxUnavailable: 0
        remoteWriteSettings:
          queues: 24
        statefulMode: false
        serviceScrapeSelector: {}
        serviceScrapeNamespaceSelector: {}
        podScrapeSelector: {}
        podScrapeNamespaceSelector: {}
        nodeScrapeSelector: {}
        nodeScrapeNamespaceSelector: {}
        staticScrapeSelector: {}
        staticScrapeNamespaceSelector: {}
        podMetadata: {}
        scrapeInterval: 30s
        minScrapeInterval: 15s
        maxScrapeInterval: 60s
        remoteWrite:
          - url: https://vminsert-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8480/insert/0/prometheus/api/v1/write
            tlsConfig:
              caFile: /etc/ssl/certs/ca.crt
        externalLabels:
          cluster_full_name: "cluster" #namespace-cluster_name
          remotewrite_cluster: cluster #namespace-cluster_name
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                      - key: app.kubernetes.io/name
                        operator: In
                        values:
                          - vmagent
                      - key: app.kubernetes.io/instance
                        operator: In
                        values:
                          - vmagent
                  topologyKey: failure-domain.beta.kubernetes.io/region
                weight: 100
        probeNamespaceSelector: {}
        priorityClassName: system-cluster-critical

    kubeApiServer:
      enabled: true
      vmScrape:
        spec:
          endpoints:
            - port: https
              scheme: https
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
                serverName: kubernetes
          namespaceSelector:
            matchNames:
              - default
          selector:
            matchLabels:
              component: apiserver
              provider: kubernetes
          jobLabel: component
    kubeControllerManager:
      enabled: true
      vmScrape:
        spec:
          endpoints:
            - port: "http-metrics"
              scheme: "https"
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                serverName: "localhost"
    kubeEtcd:
      enabled: true
      service:
        port: 2381
        targetPort: 2381
      vmScrape:
        spec:
          endpoints:
            - scheme: "http"
              port: http-metrics
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                serverName: "localhost"
                insecureSkipVerify: true
    kubeProxy:
      enabled: false
    kubeScheduler:
      enabled: true
      vmScrape:
        spec:
          endpoints:
            - port: "http-metrics"
              scheme: "https"
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
          jobLabel: "jobLabel"
    kubelet:
      enabled: true
immutable: |
  victoria-metrics-k8s-stack:
    coreDns:
      enabled: false
    kubeDns:
      enabled: false
    kube-state-metrics:
      enabled: false
    alertmanager:
      enabled: false
    defaultDashboards:
      enabled: false
    defaultRules:
      create: false
    grafana:
      enabled: false
    prometheus-node-exporter:
      enabled: false
    serviceAccount:
      create: false
    victoria-metrics-operator:
      enabled: false
    vmagent:
      enabled: true
    vmalert:
      enabled: false
    vmcluster:
      enabled: false
    vmsingle:
      enabled: false
{{- end }}
