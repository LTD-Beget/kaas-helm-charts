{{- define "xclusterComponents.addonsetIii.clickhouseVmstorage" -}}
  {{- printf `
clickhouseVmstorage:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsClickhouseVmstorage
  namespace: beget-clickhouse-vmstorage
  version: v1alpha1
  dependsOn:
    - vmOperator
    - grafanaOperator
  values:
    appSpec:
      applications:
        carbon:
          enabled: false
          containers:
            carbon:
              enabled: false
        graphite:
          enabled: false
          containers:
            graphite:
              enabled: false

    clickhouse:
      resources:
        limits:
          cpu: 4
          memory: 8Gi

      keeper:
        resources:
          limits:
            cpu: 1
            memory: 1Gi
  ` }}
{{- end -}}
