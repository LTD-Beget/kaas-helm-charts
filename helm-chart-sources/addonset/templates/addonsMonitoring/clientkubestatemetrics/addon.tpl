{{- define "clientkubestatemetrics.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: client-kube-state-metrics
spec:
  chart: "kube-state-metrics"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "6.1.0-1"
  targetCluster: in-cluster
  targetNamespace: "beget-client-kube-state-metrics"
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
    - name: client-vm-scrape-config
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
        addons.in-cloud.io/addon: client-kube-state-metrics
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
