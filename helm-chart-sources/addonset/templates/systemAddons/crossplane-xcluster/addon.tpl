{{- define "crossplane-xcluster.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: crossplane-xcluster
spec:
  path: .
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/cloud/k8s/charts/crossplane-xcluster.git"
  version: "v0.0.5"
  targetCluster: in-cluster
  targetNamespace: "beget-crossplane"
  variables:
    cluster_name: in-cluster
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters
        namespace: beget-system
      extract:
        - as: clusterHost
          jsonPath: .data.clusterHost
        - as: istioGwVip
          jsonPath: .data.systemIstioGwVip
        - as: systemVmInsertVIP
          jsonPath: .data.systemVmInsertVIP
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
        addons.in-cloud.io/addon: crossplane-xcluster
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: crossplane-xcluster
{{- end }}
