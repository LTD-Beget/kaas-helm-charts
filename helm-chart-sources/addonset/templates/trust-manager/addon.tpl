{{- define "trust-manager.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: trust-manager
spec:
  chart: "trust-manager"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.16.0-1"
  targetCluster: in-cluster
  targetNamespace: "beget-trust-manager"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters
        namespace: beget-system
      extract:
        - as: cluster.name
          jsonPath: .data.clusterName
  initDependencies:
    - name: cert-manager
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
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: trust-manager
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: trust-manager

{{- end }}
