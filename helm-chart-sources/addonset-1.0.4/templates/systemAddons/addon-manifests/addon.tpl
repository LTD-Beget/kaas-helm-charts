{{- define "addon-manifests.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: addon-manifests
spec:
  chart: "addon-manifests"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.1.0"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-addons-operator"
  variables:
    cluster_name: in-cluster
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
        - as: companyExternalChartRegistry
          jsonPath: .data.companyExternalChartRegistry
  initDependencies: 
    - name: addons-operator
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
        addons.in-cloud.io/addon: addon-manifests
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: addon-manifests
{{- end }}
