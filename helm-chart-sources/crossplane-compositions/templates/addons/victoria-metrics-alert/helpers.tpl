{{- define "addons.victoriametricsalert" }}
name: VictoriaMetricsAlert
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
default: |
  victoria-metrics-k8s-stack:
    fullnameOverride: "vmalert"
    vmalert:
      spec:
        selectAllByDefault: false
        ruleNamespaceSelector: {}
        resources:
          limits:
            cpu: '1'
            memory: 1Gi
          requests:
            cpu: '100m'
            memory: 128Mi
        replicaCount: 1
        updateStrategy: RollingUpdate
        rollingUpdate:
          maxSurge: 10%
          maxUnavailable: 0

        remoteWrite:
          url: "http://prometheus-server.beget-prometheus.svc:80/api/v1/write"
          concurrency: 4
        remoteRead:
          url: "http://prometheus-server.beget-prometheus.svc:80"
        datasource:
          url: "http://prometheus-server.beget-prometheus.svc:80"
        notifiers:
          - url: "http://vmalertmanager-alertmanager.beget-alertmanager.svc:9093"
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
immutable: |
  victoria-metrics-k8s-stack:
    alertmanager:
      enabled: false
    defaultRules:
      create: false
    prometheus-node-exporter:
      enabled: false
    serviceAccount:
      create: false
    victoria-metrics-operator:
      enabled: false
    vmagent:
      enabled: false
    vmalert:
      enabled: true
    vmcluster:
      enabled: false
    vmsingle:
      enabled: false
    coreDns:
      enabled: false
    defaultDashboards:
      enabled: false
    kubeDns:
      enabled: false
    grafana:
      enabled: false
    kube-state-metrics:
      enabled: false
    kubeApiServer:
      enabled: false
    kubeControllerManager:
      enabled: false
    kubeEtcd:
      enabled: false
    kubeProxy:
      enabled: false
    kubeScheduler:
      enabled: false
    kubelet:
      enabled: false
{{- end }}
