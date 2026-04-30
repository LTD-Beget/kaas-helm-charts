{{- define "istio-gw.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: istio-gw
spec:
  chart: "gateway"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "1.26.0-3"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-istio-gw"
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
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: clusterHost
          jsonPath: .data.clusterHost
        - as: systemIstioGwDomain
          jsonPath: .data.systemIstioGwDomain
        - as: systemIstioGwVip
          jsonPath: .data.systemIstioGwVip
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
  initDependencies:
    - name: cert-manager
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
    - name: istiod
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
  backend:
    finalizer: true
    type: "argocd"
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
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
        addons.in-cloud.io/addon: istio-gw
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: istio-gw
{{- end }}

