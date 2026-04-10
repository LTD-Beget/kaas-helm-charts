{{- define "clientkubestatemetrics.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: client-kube-state-metrics
spec:
  chart: "kube-state-metrics"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "6.1.0-5"
  pluginName: helm-with-values
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-client-kube-state-metrics"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources:
    - name: parameters-client
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-client
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.customer
          jsonPath: .data.customer
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
  initDependencies:
{{- if .Values.clientClusterEnabled }}
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
    - name: client-vm-scrape-config
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
    - name: cert-manager
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
  backend:
    finalizer: true
    type: "argocd"
    namespace: "{{ .Values.companyPrefix }}-argocd"
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
        addons.in-cloud.io/addon: client-kube-state-metrics
{{- end }}
