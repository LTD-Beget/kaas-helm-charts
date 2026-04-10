{{- define "argocd.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: argocd
spec:
  chart: "argo-cd"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "9.4.15-3"
  pluginName: helm-with-values
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-argocd"
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
        - as: argocdServerAdminPassword
          jsonPath: .data.argocdServerAdminPassword
        - as: dataCreationTimestamp
          jsonPath: .metadata.creationTimestamp
        - as: systemIstioGwDomain
          jsonPath: .data.systemIstioGwDomain
        - as: istioGwVip
          jsonPath: .data.systemIstioGwVip
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
        - as: companyInternalGitRepository
          jsonPath: .data.companyInternalGitRepository
        - as: companyAdminUser
          jsonPath: .data.companyAdminUser
  initDependencies:
    - name: cilium
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
        addons.in-cloud.io/addon: argocd
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: argocd
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: argocd
{{- end }}
