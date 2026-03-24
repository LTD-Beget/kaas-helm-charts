{{- define "secret-copy-operator.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: secret-copy-operator
spec:
  path: "dist/chart"
  pluginName: helm-with-values
  repoURL: "https://github.com/PRO-Robotech/secret-copy-operator"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-system"
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
        addons.in-cloud.io/addon: secret-copy-operator
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: secret-copy-operator
{{- end }}
