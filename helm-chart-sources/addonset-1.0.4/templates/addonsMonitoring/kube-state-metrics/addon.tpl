{{- define "kube-state-metrics.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: kube-state-metrics
spec:
  chart: "kube-state-metrics"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "6.1.0-4"
  pluginName: helm-with-values
  releaseName: kube-state-metrics
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-kube-state-metrics"
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
        addons.in-cloud.io/addon: kube-state-metrics
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: kube-state-metrics
{{- end }}
