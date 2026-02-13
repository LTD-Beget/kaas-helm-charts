{{- define "etcd-backup-snapshot.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: etcd-backup-snapshot
spec:
  path: "helm-chart-sources/etcd-backup-snapshot"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-etcd-backup-snapshot"
  variables:
    cluster_name: in-cluster
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters
        namespace: beget-system
      extract:
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: etcdbackupAppArgsStorecontainer
          jsonPath: .data.etcdbackupAppArgsStorecontainer
        - as: etcdbackupS3AccessKey
          jsonPath: .data.etcdbackupS3AccessKey
        - as: etcdbackupS3SecretAccessKey
          jsonPath: .data.etcdbackupS3SecretAccessKey
        - as: etcdbackupS3SecretEndpoint
          jsonPath: .data.etcdbackupS3SecretEndpoint
  initDependencies:
    - name: vm-operator
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
  backend: 
    type: "argocd"
    namespace: "beget-argocd"
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
        addons.in-cloud.io/addon: etcd-backup-snapshot
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: etcd-backup-snapshot
{{- end }}
