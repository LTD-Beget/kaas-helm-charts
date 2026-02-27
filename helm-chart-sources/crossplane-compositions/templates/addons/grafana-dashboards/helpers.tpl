{{- define "addons.grafanadashboards" }}
name: GrafanaDashboards
debug: false
path: helm-chart-sources/grafana-dashboards
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "grafanadashboards" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  grafanaDashboards:
    argocd:
      enabled: false
    ciliumAgent:
      enabled: false
    cpu:
      enabled: false
    crossplaneCustom:
      enabled: false
    dockerRegistry:
      enabled: false
    processLA:
      enabled: false
    processExporter:
      enabled: false
    metallb:
      enabled: false
    vector:
      enabled: false
    vmagent:
      enabled: false
    vmalert:
      enabled: false
    vmcluster:
      enabled: false
    vmoperator:
      enabled: false
    clickhouseTSDBNodegroups:
      enabled: false
    clickhouseTSDBNodes:
      enabled: false
    clickhouseTSDBPods:
      enabled: false
    k8s:
      apiserver:
        enabled: true
      controlplane:
        enabled: true
      coredns:
        enabled: false
      etcd:
        enabled: false
      timex:
        enabled: false
      viewsGlobal:
        enabled: false
      viewsNamespaces:
        enabled: false
      viewsNodes:
        enabled: false
      viewsPods:
        enabled: false
immutable: |
  grafanaDashboards:
    k8s:
      apiserver:
        enabled: true
      controlplane:
        enabled: true
{{- end }}
