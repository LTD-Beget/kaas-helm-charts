{{- define "newaddons.istioBase" -}}
  {{- printf `
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: {{ $clusterName }}-istio-base
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonIstioBase
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  chart: "base"
  # path: "helm-chart-sources/istio-base"
  repoURL: "https://istio-release.storage.googleapis.com/charts"
  version: "1.26.0"
  targetCluster: {{ $clusterName }}
  targetNamespace: "beget-istio"
  variables:
    cluster_name: {{ $clusterName }}
  valuesSources: []
  initDependencies: []
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
          in-cloud.io/clusterName: {{ $clusterName }}
      syncOptions:
        - CreateNamespace=true
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jsonPointers:
      - /webhooks/0/failurePolicy
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: istio-base
status: {}

---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonValue
metadata:
  name: istio-base-default
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonValueIstioBase
    gotemplating.fn.crossplane.io/ready: "True"
  labels:
    addons.in-cloud.io/values: default
    addons.in-cloud.io/addon: istio-base
spec:
  values:
    global:
      istioNamespace: beget-istio

  ` }}
{{- end -}}
