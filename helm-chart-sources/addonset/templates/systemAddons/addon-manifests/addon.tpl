{{- define "addon-manifests.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: addon-manifests
spec:
  path: "."
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/cloud/k8s/addon-manifests.git"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-addons-operator"
  variables:
    cluster_name: in-cluster
  valuesSources: []
  initDependencies: 
    - name: addons-operator
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
        addons.in-cloud.io/addon: addon-manifests
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: addon-manifests
{{- end }}
