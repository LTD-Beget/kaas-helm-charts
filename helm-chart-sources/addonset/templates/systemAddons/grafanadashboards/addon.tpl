{{- define "grafanadashboards.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: grafana-dashboards
spec:
  chart: ""
  path: "helm-chart-sources/grafana-dashboards"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-grafana"
  variables:
    cluster_name: in-cluster
  valuesSources: []
  initDependencies:
    - name: grafana-operator
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
  backend: 
    type: "argocd"
    namespace: "beget-argocd"
    project: "default"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      managedNamespaceMetadata:
        labels:
          in-cloud.io/caBundle: approved
          in-cloud.io/clusterName: system
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: grafana-dashboards
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: grafana-dashboards
{{- end }}
