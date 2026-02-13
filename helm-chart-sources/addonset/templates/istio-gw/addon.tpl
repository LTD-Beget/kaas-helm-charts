{{- define "istio-gw.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: istio-gw
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonIstioGw
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  path: "helm-chart-sources/istio-gw"
  pluginName: helm-with-values
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: in-cluster
  targetNamespace: "beget-istio-gw"
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
  initDependencies:
    - name: cert-manager
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
    - name: istio-base
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
  backend: 
    type: "argocd"
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
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
        addons.in-cloud.io/addon: istio-gw
    - name: immutable
      priority: 10
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: istio-gw
{{- end }}

