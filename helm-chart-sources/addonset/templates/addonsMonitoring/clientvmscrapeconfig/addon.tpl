{{- define "clientvmscrapeconfig.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: client-vm-scrape-config
spec:
  path: "helm-chart-sources/helm-inserter"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-vmagent"
  variables:
    cluster_name: in-cluster
  initDependencies:
    - name: vm-operator
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
    - name: extra-resources-client
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
      managedNamespaceMetadata:
        labels:
          in-cloud.io/caBundle: approved
          in-cloud.io/clusterName: infra
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: initialized
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: initialized
        addons.in-cloud.io/addon: client-vm-scrape-config
  valuesSources:
    - name: parameters-client
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-client
        namespace: beget-system
      extract:
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.port
          jsonPath: .data.clusterPort
        - as: cluster.customer
          jsonPath: .data.customer
{{- end }}
