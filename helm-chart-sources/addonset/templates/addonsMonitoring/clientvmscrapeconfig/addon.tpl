{{- define "clientvmscrapeconfig.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: client-vm-scrape-config
spec:
  chart: "helm-inserter"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.2.5"
  targetCluster: in-cluster
  targetNamespace: "beget-vmagent"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  initDependencies:
{{- if .Values.clientClusterEnabled }}
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
    - name: extra-resources-client
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
    - name: vm-operator
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
  backend:
    finalizer: true
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
