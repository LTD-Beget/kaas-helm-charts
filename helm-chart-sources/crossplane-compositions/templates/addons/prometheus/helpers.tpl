{{- define "addons.prometheus" }}
name: Prometheus
debug: false
path: helm-chart-sources/prometheus
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "prometheus" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: kustomize-helm-with-values
default: |
  prometheus:
    server:
      persistentVolume:
        enabled: false
      emptyDir:
        sizeLimit: "500Mi"
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      resources:
        limits:
          cpu: 512m
          memory: 768Mi
        requests:
          cpu: 100m
          memory: 128Mi
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
immutable: |
  prometheus:
    server:
      image:
        repository: prompp/prompp
        tag: "2.53.2-0.3.1"
    alertmanager:
      enabled: false
    prometheus-node-exporter:
      enabled: false
    kube-state-metrics:
      enabled: false
    prometheus-pushgateway:
      enabled: false
{{- end }}
