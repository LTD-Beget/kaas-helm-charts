{{- define "svc-hub.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: svc-hub
spec:
  chart: "svc-hub"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.1.0"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-svc-hub"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: svcHubRabbitUsername
          jsonPath: .data.svcHubRabbitUsername
        - as: svcHubRabbitPassword
          jsonPath: .data.svcHubRabbitPassword
        - as: svcHubRabbitHost
          jsonPath: .data.svcHubRabbitHost
        - as: svcHubRabbitVirtualHost
          jsonPath: .data.svcHubRabbitVirtualHost
        - as: companyInternalDockerRegistry
          jsonPath: .data.companyInternalDockerRegistry
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
        addons.in-cloud.io/addon: svc-hub
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: svc-hub
{{- end }}
