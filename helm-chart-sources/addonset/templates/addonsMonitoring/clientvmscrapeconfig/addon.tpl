{{- define "clientvmscrapeconfig.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: client-vm-scrape-config
spec:
  chart: "helm-inserter"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.2.5"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-vmagent"
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
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.port
          jsonPath: .data.clusterPort
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
    - name: extra-resources-client
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
    - name: vm-operator
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
      managedNamespaceMetadata:
        labels:
          in-cloud.io/caBundle: approved
          in-cloud.io/clusterName: infra
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: initialized
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: initialized
        addons.in-cloud.io/addon: client-vm-scrape-config
{{- end }}
