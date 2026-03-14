{{- define "clickhouseinserter.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: clickhouse-inserter
spec:
  chart: "victoria-metrics-k8s-stack"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.52.0-1"
  targetCluster: in-cluster
  targetNamespace: "beget-clickhouse-vmstorage"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources: []
  initDependencies:
    - name: vm-cluster
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
    - name: clickhouse-vmstorage
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
          in-cloud.io/clusterName: infra
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: clickhouse-inserter
{{- end }}
