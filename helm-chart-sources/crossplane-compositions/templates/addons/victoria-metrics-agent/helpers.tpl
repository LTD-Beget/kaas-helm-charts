{{- define "addons.victoriametricsagent" }}
name: VictoriaMetricsAgent
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
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
          limits:
            cpu: "500m"
            memory: "500Mi"
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
        containers:
          - name: config-reloader
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 100m
              memory: 200Mi
            securityContext:
              runAsNonRoot: true
              runAsUser: 65534
          - name: vmagent
            securityContext:
              readOnlyRootFilesystem: true
              allowPrivilegeEscalation: false
          - name: rbac-proxy
            image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
            args:
              - --secure-listen-address=0.0.0.0:11043
              - --upstream=http://127.0.0.1:8429
              - --tls-cert-file=/app/config/metrics/tls/tls.crt
              - --tls-private-key-file=/app/config/metrics/tls/tls.key
              - --v=2
            ports:
              - name: https-metrics
                containerPort: 11043
                protocol: TCP
            resources:
              requests:
                memory: "32Mi"
                cpu: "10m"
              limits:
                memory: "64Mi"
                cpu: "50m"
            volumeMounts:
              - name: rbac-proxy-tls
                mountPath: /app/config/metrics/tls
                readOnly: true
        volumeMounts:
          - name: trusted-ca-certs
            mountPath: /etc/ssl/certs
            readOnly: true
        volumes:
          - name: trusted-ca-certs
            configMap:
              name: ca
          - name: rbac-proxy-tls
            secret:
              defaultMode: 420
              secretName: vmagent-monitoring-svc-tls
        extraEnvs:
          - name: GOMAXPROCS
            value: '1'
        extraArgs:
          remoteWrite.tlsInsecureSkipVerify: "true"
          remoteWrite.label: remotewrite_cluster=cluster #namespace-cluster_name
          promscrape.streamParse: "true"
          promscrape.maxScrapeSize: "100000000"
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
          - url: http://prometheus-server.beget-prometheus.svc:80/api/v1/write
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
    coreDns:
      enabled: false
    kubeDns:
      enabled: false
    kube-state-metrics:
      enabled: false
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
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
immutable: |
  victoria-metrics-k8s-stack:
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
