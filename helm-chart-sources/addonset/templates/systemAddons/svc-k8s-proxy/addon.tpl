{{- define "svc-k8s-proxy.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: svc-k8s-proxy
spec:
  path: .
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/k8s-charts-public/svc-k8s-proxy.git"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-svc-k8s-proxy"
  variables:
    cluster_name: in-cluster
    dependency: "True"
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
        addons.in-cloud.io/addon: svc-k8s-proxy
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: svc-k8s-proxy
{{- end }}
