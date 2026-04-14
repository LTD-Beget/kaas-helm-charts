{{- define "incloud-web-resources.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: incloud-web-resources
spec:
  chart: "incloud-web-resources"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "1.2.0-1"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-incloud-web-chart"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources:  []
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
{{- if .Values.clientClusterEnabled }}
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
    - name: incloud-web-chart
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
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: incloud-web-resources
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: incloud-web-resources
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: incloud-web-resources
{{- end }}
