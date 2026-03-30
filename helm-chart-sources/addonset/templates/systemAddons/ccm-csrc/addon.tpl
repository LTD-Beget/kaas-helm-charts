{{- define "ccm-csrc.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: ccm-csrc
spec:
  chart: "helm-inserter"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts/"
  version: "0.2.5"
  targetCluster: in-cluster
  targetNamespace: "beget-system"
  variables:
    cluster_name: in-cluster
  initDependencies:
    - name: ccm-csrc-controller
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: beget-system
      extract:
        - as: xcluster
          jsonPath: .data.xcluster
        - as: trackingID
          jsonPath: .data.trackingID
        - as: clusterName
          jsonPath: .data.clusterName
        - as: systemNamespace
          jsonPath: .data.systemNamespace
        - as: customer
          jsonPath: .data.customer
  initDependencies: 
    - name: helm-inserter
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
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: ccm-csrc
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: ccm-csrc
{{- end }}
