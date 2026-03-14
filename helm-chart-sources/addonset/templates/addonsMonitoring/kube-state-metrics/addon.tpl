{{- define "kube-state-metrics.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: kube-state-metrics
spec:
  chart: "kube-state-metrics"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "6.1.0-1"
  releaseName: kube-state-metrics
  targetCluster: in-cluster
  targetNamespace: "beget-kube-state-metrics"
  variables:
    cluster_name: in-cluster
    dependency: "True"
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
        addons.in-cloud.io/addon: kube-state-metrics
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: kube-state-metrics
{{- end }}
