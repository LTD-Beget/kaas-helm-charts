{{- define "xclusterComponents.addonsetIii.vmAlert" -}}
  {{- printf `
vmAlert:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlert
  namespace: beget-vmalert
  version: v1alpha1
  values:
    vmalert:
      spec:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
        externalLabels:
          in-cloud-metrics: "infra"
        podMetadata:
          labels:
            in-cloud-metrics: "infra"
        evaluationInterval: 60s
        selectAllByDefault: false
        ruleNamespaceSelector: {}
        ruleSelector:
          matchLabels:
            in-cloud-metrics: "infra"
        resources:
          limits:
            cpu: 1
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 128Mi
        replicaCount: 1
        updateStrategy: RollingUpdate
        extraEnvs:
          - name: GOMAXPROCS
            value: "4"
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
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}