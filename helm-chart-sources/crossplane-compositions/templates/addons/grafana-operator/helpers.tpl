{{- define "addons.grafanaoperator" }}
name: GrafanaOperator
debug: false
path: helm-chart-sources/grafana-operator
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "grafanaoperator" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: kustomize-helm-with-values
default: |
  grafana-operator:
    namespaceScope: false
    priorityClassName: system-cluster-critical
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
    resources:
      requests:
        cpu: 50m
        memory: 100Mi
      limits:
        cpu: 500m
        memory: 750Mi
  monitoring:
    secureService:
      enabled: true
      issuer:
        name: selfsigned-cluster-issuer
manifest:
  spec:
    syncPolicy:
      syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true


{{- end }}
