{{- define "prometheus-process-exporter.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: prometheus-process-exporter
spec:
  # chart: "prometheus-process-exporter"
  # repoURL: "https://blog.beget.com/kaas-helm-charts"
  # version: "0.5.0-2"
  path: "helm-chart-sources/prometheus-process-exporter"
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts.git"
  version: "fix/vmscrapes"
  pluginName: helm-with-values
  releaseName: prometheus-process-exporter
  targetCluster: in-cluster
  targetNamespace: "beget-prometheus-process-exporter"
  variables:
    cluster_name: in-cluster
    dependency: "True"
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
        addons.in-cloud.io/addon: prometheus-process-exporter
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: prometheus-process-exporter
{{- end }}
