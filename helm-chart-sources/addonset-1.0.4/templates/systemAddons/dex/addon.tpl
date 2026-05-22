{{- define "dex.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: dex
spec:
  chart: "dex"
  pluginName: helm-with-values
  repoURL: {{ .Values.companyExternalChartRegistry }}
  version: "0.23.0-1"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-dex"
  variables:
    cluster_name: in-cluster
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: dexStaticPasswordsAdmin
          jsonPath: .data.dexStaticPasswordsAdmin
        - as: clusterName
          jsonPath: .data.clusterName
        - as: systemIstioGwDomain
          jsonPath: .data.systemIstioGwDomain
        - as: systemIstioGwVip
          jsonPath: .data.systemIstioGwVip
        - as: systemIstioGwDomainInternal
          jsonPath: .data.systemIstioGwDomainInternal
        - as: systemIstioGwVipInternal
          jsonPath: .data.systemIstioGwVipInternal
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
        - as: companyAdminUser
          jsonPath: .data.companyAdminUser
  initDependencies:
    - name: cert-manager
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
        addons.in-cloud.io/addon: dex
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: dex
{{- end }}
