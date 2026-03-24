{{- define "ccm-csrc-controller.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: ccm-csrc-controller
spec:
  path: .
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/cloud/k8s/charts/ccm-csr-controller.git"
  version: "HEAD"
  targetCluster: in-cluster
  releaseName: system
  targetNamespace: "beget-ccm-csrc-controller"
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
        addons.in-cloud.io/addon: ccm-csrc-controller
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: ccm-csrc-controller
{{- end }}
