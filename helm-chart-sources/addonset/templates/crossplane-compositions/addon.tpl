{{- define "crossplane-compositions.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: crossplane-compositions
spec:
  path: "helm-chart-sources/crossplane-compositions"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "feat/addon"
  targetCluster: in-cluster
  targetNamespace: "beget-crossplane-compositions"
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
        - as: client.enabled
          jsonPath: .data.clusterClientEnabled
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
        addons.in-cloud.io/addon: crossplane-compositions
    - name: immmutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immmutable
        addons.in-cloud.io/addon: crossplane-compositions
{{- end }}
