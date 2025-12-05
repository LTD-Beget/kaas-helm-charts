{{- define "xclusterComponents.addonsetIii.prometheus" -}}
  {{- printf `
prometheus:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsPrometheus
  namespace: beget-prometheus
  version: v1alpha1
  dependsOn:
  - grafanaOperator
  values:
    prometheus:
      server:
        emptyDir:
          sizeLimit: "2048Mi"
        extraFlags:
          - web.enable-remote-write-receiver
    monitoring:
      enabled: true
      namespace: beget-prometheus
      grafana:
        datasource:
          enabled: true
          name: {{ printf "prometheus-%%s" $clusterName }}
          namespace: beget-grafana #should be the same as grafana-dashboards
          selector: grafana
          type: prometheus
          isDefault: false
          url: "http://prometheus-server.beget-prometheus.svc:80"
          jsonData:
            tlsSkipVerify: true
            timeInterval: 5s
  ` }}
{{- end -}}