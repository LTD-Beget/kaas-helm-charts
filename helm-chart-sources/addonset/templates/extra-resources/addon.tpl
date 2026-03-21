{{- define "extra-resources.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: extra-resources{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  chart: "helm-inserter"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.2.5"
  targetCluster: in-cluster
  targetNamespace: "beget-extra-resources"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
        namespace: beget-system
      extract:
        - as: argocdServerAdminPassword
          jsonPath: .data.argocdServerAdminPassword
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.port
          jsonPath: .data.clusterPort
        - as: controlPlaneReplicas
          jsonPath: .data.controlPlaneReplicas
        - as: dataCreationTimestamp
          jsonPath: .metadata.creationTimestamp
        - as: environment
          jsonPath: .data.environment
        - as: etcdbackupAppArgsStorecontainer
          jsonPath: .data.etcdbackupAppArgsStorecontainer
        - as: etcdbackupS3AccessKey
          jsonPath: .data.etcdbackupS3AccessKey
        - as: etcdbackupS3SecretAccessKey
          jsonPath: .data.etcdbackupS3SecretAccessKey
        - as: etcdbackupS3SecretEndpoint
          jsonPath: .data.etcdbackupS3SecretEndpoint
        - as: istioGwVip
          jsonPath: .data.systemIstioGwVip
        - as: xcluster
          jsonPath: .data.xcluster
  initDependencies:
    - name: cert-manager
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
          in-cloud.io/clusterName: in-cluster
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
{{- end }}
