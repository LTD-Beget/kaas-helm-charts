{{- define "docker-registry.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: docker-registry
spec:
  chart: "docker-registry"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts/"
  version: "3.0.0"
  targetCluster: in-cluster
  releaseName: docker-registry-cache
  targetNamespace: "beget-docker-registry"
  variables:
    cluster_name: in-cluster
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
        addons.in-cloud.io/addon: docker-registry
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: docker-registry
{{- end }}
