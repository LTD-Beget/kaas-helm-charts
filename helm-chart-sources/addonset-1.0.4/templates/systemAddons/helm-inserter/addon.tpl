{{- define "helm-inserter.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: helm-inserter
spec:
  chart: "helm-inserter"
  pluginName: helm-with-values
  repoURL: {{ .Values.companyExternalChartRegistry }}
  version: "0.2.5"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-argocd"
  variables:
    cluster_name: in-cluster
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: xcluster
          jsonPath: .data.xcluster
        - as: trackingID
          jsonPath: .data.trackingID
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: systemNamespace
          jsonPath: .data.systemNamespace
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
  backend:
    finalizer: true
    type: "argocd"
    namespace: "{{ .Values.companyPrefix }}-argocd"
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
        addons.in-cloud.io/addon: helm-inserter
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: helm-inserter
{{- end }}
