{{- define "addons-operator.addon" }}
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: addons-operator
spec:
  path: "helm-chart-sources/addons-operator"
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "feat/addon"
  targetCluster: in-cluster
  targetNamespace: "beget-addons-operator"
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
        addons.in-cloud.io/addon: addons-operator
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: addons-operator
{{- end }}
