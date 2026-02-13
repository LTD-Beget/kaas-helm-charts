{{- define "incloud-web-chart.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: incloud-web-chart
spec:
  path: "helm-chart-sources/incloud-web-chart"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-incloud-web-chart"
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
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: incloudUICookieSecret
          jsonPath: .data.incloudUICookieSecret
        - as: system.istioGwVip
          jsonPath: .data.systemIstioGwVip
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
        addons.in-cloud.io/addon: incloud-web-chart
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: incloud-web-chart
{{- end }}
