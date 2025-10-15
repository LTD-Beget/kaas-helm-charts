{{- define "addons.prometheusadapter" }}
name: PrometheusAdapter
debug: false
chart: prometheus-adapter
repoURL: https://prometheus-community.github.io/helm-charts
targetRevision: 4.14.1
default: |
  prometheus:
    url: http://prometheus-server.beget-prometheus.svc
    port: 80
  rules:
    resource:
      cpu:
        containerQuery: |
          sum by (<<.GroupBy>>) (
            rate(container_cpu_usage_seconds_total{container!="",<<.LabelMatchers>>}[3m])
          )
        nodeQuery: |
          sum  by (<<.GroupBy>>) (
            rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal",<<.LabelMatchers>>}[3m])
          )
        resources:
          overrides:
            node:
              resource: node
            namespace:
              resource: namespace
            pod:
              resource: pod
        containerLabel: container
      memory:
        containerQuery: |
          sum by (<<.GroupBy>>) (
            avg_over_time(container_memory_working_set_bytes{container!="",<<.LabelMatchers>>}[3m])
          )
        nodeQuery: |
          sum by (<<.GroupBy>>) (
            avg_over_time(node_memory_MemTotal_bytes{<<.LabelMatchers>>}[3m])
            -
            avg_over_time(node_memory_MemAvailable_bytes{<<.LabelMatchers>>}[3m])
          )
        resources:
          overrides:
            node:
              resource: node
            namespace:
              resource: namespace
            pod:
              resource: pod
        containerLabel: container
      window: 3m
  replicas: 1
  tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule"
    - key: "node-role.kubernetes.io/master"
      operator: "Exists"
      effect: "NoSchedule"
{{- end }}
