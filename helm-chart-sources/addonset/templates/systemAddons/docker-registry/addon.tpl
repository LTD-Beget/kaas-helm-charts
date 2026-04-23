{{- define "docker-registry.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: docker-registry
spec:
  chart: "docker-registry"
  pluginName: helm-with-values
  repoURL: {{ .Values.companyExternalChartRegistry }}
  version: "3.0.0"
  targetCluster: in-cluster
  releaseName: docker-registry-cache
  targetNamespace: "{{ .Values.companyPrefix }}-docker-registry"
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
        - as: companyDomain
          jsonPath: .data.companyDomain
        - as: companyInternalDockerRegistry
          jsonPath: .data.companyInternalDockerRegistry
        - as: dockerRegistryS3AccessKey
          jsonPath: .data.dockerRegistryS3AccessKey
        - as: dockerRegistryS3SecretKey
          jsonPath: .data.dockerRegistryS3SecretKey
        - as: dockerRegistryS3Bucket
          jsonPath: .data.dockerRegistryS3Bucket
        - as: etcdbackupS3SecretEndpoint
          jsonPath: .data.etcdbackupS3SecretEndpoint
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
        addons.in-cloud.io/addon: docker-registry
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: docker-registry
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: docker-registry
{{- end }}
