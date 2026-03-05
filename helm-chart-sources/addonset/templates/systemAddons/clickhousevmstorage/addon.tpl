{{- define "clickhousevmstorage.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: clickhouse-vmstorage
spec:
  chart: ""
  path: "helm-chart-sources/clickhouse-vmstorage"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-clickhouse-vmstorage"
  variables:
    cluster_name: in-cluster
  valuesSources: []
  initDependencies: []
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
          in-cloud.io/clusterName: infra
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: clickhouse-vmstorage
{{- end }}
