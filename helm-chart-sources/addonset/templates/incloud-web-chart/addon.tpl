{{- define "incloud-web-chart.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: incloud-web-chart
spec:
  # chart: "incloud-web-chart"
  # repoURL: "https://blog.beget.com/kaas-helm-charts"
  # version: "1.3.0-2"
  path: "helm-chart-sources/incloud-web-chart"
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts.git"
  version: "fix/vmscrapes"
  pluginName: helm-with-values
  targetCluster: in-cluster
  targetNamespace: "beget-incloud-web-chart"
  variables:
    cluster_name: in-cluster
    dependency: "True"
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
{{- if .Values.clientClusterEnabled }}
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
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
        addons.in-cloud.io/addon: incloud-web-chart
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: incloud-web-chart
{{- end }}
