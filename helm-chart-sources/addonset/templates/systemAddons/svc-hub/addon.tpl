{{- define "svc-hub.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: svc-hub
spec:
  path: ".k8s/helm"
  pluginName: helm-with-values
  repoURL: "https://gitlab.beget.ru/golang/svc-hub.git"
  version: "upd-chart"
  targetCluster: in-cluster
  targetNamespace: "beget-svc-hub"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: beget-system
      extract:
        - as: svcHubRabbitUsername
          jsonPath: .data.svcHubRabbitUsername
        - as: svcHubRabbitPassword
          jsonPath: .data.svcHubRabbitPassword
        - as: svcHubRabbitHost
          jsonPath: .data.svcHubRabbitHost
        - as: svcHubRabbitVhost
          jsonPath: .data.svcHubRabbitVirtualHost
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
        addons.in-cloud.io/addon: svc-hub
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: svc-hub
{{- end }}
