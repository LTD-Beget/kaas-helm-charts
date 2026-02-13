{{- define "crossplane-functions.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: crossplane-functions
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonCrossplaneFunctions
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  path: "helm-chart-sources/crossplane-functions"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "feat/addon"
  targetCluster: in-cluster
  targetNamespace: "beget-crossplane"
  variables:
    cluster_name: in-cluster
  initDependencies:
    - name: crossplane
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
        addons.in-cloud.io/addon: crossplane-functions
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: crossplane-functions
{{- end }}
