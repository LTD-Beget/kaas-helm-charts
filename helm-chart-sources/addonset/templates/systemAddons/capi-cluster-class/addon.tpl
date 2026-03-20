{{- define "capi-cluster-class.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: capi-cluster-class
spec:
  path: .
  repoURL: "registry.beget.ru/k8s-charts-public/charts/in-cloud-capi-template"
  version: "0.0.0-master-9506d5a"
  targetCluster: in-cluster
  targetNamespace: "bcloud-capi"
  variables:
    cluster_name: in-cluster
  valuesSources: []
  initDependencies: 
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
        addons.in-cloud.io/addon: capi-cluster-class
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: capi-cluster-class
{{- end }}
