{{- define "konnectivity-agent.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: konnectivity-agent
spec:
  chart: "konnectivity-agent"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.1.0"
  releaseName: konnectivity-agent
  targetCluster: {{ .Values.clientName }}
  targetNamespace: "beget-konnectivity-agent"
  variables:
    cluster_name: {{ .Values.clientName }}
{{- if .Values.clientClusterEnabled }}
  initDependencies:
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-client
        namespace: beget-system
      extract:
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.name
          jsonPath: .data.clusterName
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
          in-cloud.io/clusterName: client
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: client
      priority: 10
      matchLabels:
        addons.in-cloud.io/values: client
        addons.in-cloud.io/addon: konnectivity-agent
{{- end }}
