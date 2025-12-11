{{- define "addons.processexporter" }}
name: ProcessExporter
debug: false
path: helm-chart-sources/process-exporter
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "processexporter" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  prometheus-process-exporter:
    serviceAccount:
      name: prometheus-process-exporter

    image:
      repository: ncabatoff/process-exporter
      tag: 0.8.1

    service:
      type: ClusterIP
      port: 9101
      targetPort: 9101
      nodePort:
      annotations:
        prometheus.io/scrape: "true"

    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"

    priorityClassName: system-cluster-critical

    resources:
      limits:
        memory: 256Mi
        cpu: 512m
      requests:
        memory: 128Mi
        cpu: 100m

    hostNetwork: true

    rbac:
      create: true
      pspEnabled: false

    templates:
      config.yml: |
        process_names:
          - name: {{ "\"{{ \"{{\" }}.Comm{{ \"}}\" }}\""}}
            cmdline:
            - '.+'
{{- end }}
