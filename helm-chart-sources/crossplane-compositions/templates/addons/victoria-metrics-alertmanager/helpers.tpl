{{- define "addons.victoriametricsalertmanager" }}
name: VictoriaMetricsAlertmanager
debug: false
path: helm-chart-sources/victoria-metrics-k8s-stack
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
default: |
  victoria-metrics-k8s-stack:
    alertmanager:
      ingress:
        enabled: false
      config:
        global:
          resolve_timeout: 5m
        route:
          receiver: blackhole
          routes:
            - receiver: blackhole
              matchers:
                - alertname="Watchdog"
        receivers:
          - name: 'blackhole'
      monzoTemplate:
        enabled: true
      spec:
        selectAllByDefault: false
        priorityClassName: system-cluster-critical
        configSelector: {}
        configNamespaceSelector: {}
        resources:
          requests:
            cpu: '100m'
            memory: 128Mi
          limits:
            cpu: '500m'
            memory: 512Mi
        extraEnvs:
          - name: GOMAXPROCS
            value: '1'
        podMetadata: {}
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer

immutable: |
  victoria-metrics-k8s-stack:
    alertmanager:
      enabled: true
    defaultRules:
      create: false
    defaultDashboards:
      enabled: false
    prometheus-node-exporter:
      enabled: false
    serviceAccount:
      create: false
    victoria-metrics-operator:
      enabled: false
    vmagent:
      enabled: false
    vmalert:
      enabled: false
    vmcluster:
      enabled: false
    vmsingle:
      enabled: false
    coreDns:
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
