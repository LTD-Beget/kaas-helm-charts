{{- define "addons.prometheusnodeexporter" }}
name: PrometheusNodeExporter
debug: false
path: helm-chart-sources/prometheus-node-exporter
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "prometheusnodeexporter" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  prometheus-node-exporter:
    service:
      enabled: true
      port: 9100
      labels:
        beget.com/prometheus-job: node-exporter
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
    containerSecurityContext:
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
    serviceAccount:
      automountServiceAccountToken: true
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 512m
        memory: 256Mi
{{- end }}
