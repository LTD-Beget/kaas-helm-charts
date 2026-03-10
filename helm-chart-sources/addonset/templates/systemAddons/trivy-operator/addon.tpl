{{- define "trivy-operator.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: trivy-operator
spec:
  chart: "trivy-operator"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts/"
  version: "0.29.0-1"
  targetCluster: in-cluster
  targetNamespace: "beget-trivy-operator"
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
        addons.in-cloud.io/addon: trivy-operator
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: trivy-operator
{{- end }}
