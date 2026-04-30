{{- define "vm-cluster.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: vm-cluster
spec:
  chart: "victoria-metrics-k8s-stack"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.52.0-3"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-vmcluster"
  variables:
    systemIstioGwVip: ""
    dependency: "True"
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: systemVmInsertVIP
          jsonPath: .data.systemVmInsertVIP
        - as: vmClusterReplicas
          jsonPath: .data.vmClusterReplicas
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
  initDependencies:
    - name: vm-operator 
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
        addons.in-cloud.io/addon: vm-cluster
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: vm-cluster
{{- end }}
