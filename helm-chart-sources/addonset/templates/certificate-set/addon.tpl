{{- define "certificate-set.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: certificate-set
spec:
  path: "dist/chart"
  pluginName: helm-with-values
  repoURL: "https://github.com/PRO-Robotech/certificate-set"
  version: "feat/addons"
  targetCluster: in-cluster
  targetNamespace: "beget-certificate-set"
  variables:
    cluster_name: in-cluster
  initDependencies:
    - name: cilium
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
        addons.in-cloud.io/addon: certificate-set
{{- end }}
