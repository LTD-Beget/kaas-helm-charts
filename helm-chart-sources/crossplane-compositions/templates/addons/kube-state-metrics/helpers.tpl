{{- define "addons.kubestatemetrics" }}
name: KubeStateMetrics
debug: false
path: helm-chart-sources/kube-state-metrics
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "kubestatemetrics" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: kustomize-helm-with-values
default: |
  kube-state-metrics:
    kubeRBACProxy:
      enabled: false
    prometheusScrape: false

    prometheus:
      monitor:
        enabled: false

    customLabels:
      in-cloud.io/clusterName: ""

    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"

    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 50m
        memory: 128Mi

    priorityClassName: system-cluster-critical
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
{{- end }}
