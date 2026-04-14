{{- define "prometheus-node-exporter.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: prometheus-node-exporter
spec:
  chart: "prometheus-node-exporter"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "4.49.2-1"
  pluginName: helm-with-values
  releaseName: prometheus-node-exporter
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-prometheus-node-exporter"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources:
    - name: parameters-infra
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
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
  initDependencies:
    - name: addons-operator
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: true
    - name: addonset
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: prometheus-node-exporter
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: prometheus-node-exporter
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: prometheus-node-exporter
{{- end }}
