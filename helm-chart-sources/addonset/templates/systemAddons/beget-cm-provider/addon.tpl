{{- define "beget-cm-provider.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: beget-cm-provider
spec:
  path: "."
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/cloud/k8s/charts/capi-provider-beget-controller-manager.git"
  version: "v0.0.4"
  targetCluster: in-cluster
  targetNamespace: "beget-cm-provider"
  variables:
    cluster_name: in-cluster
  initDependencies: 
    - name: cert-manager
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
        addons.in-cloud.io/addon: beget-cm-provider
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: beget-cm-provider
{{- end }}
