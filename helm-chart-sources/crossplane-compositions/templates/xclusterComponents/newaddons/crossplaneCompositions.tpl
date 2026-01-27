{{- define "newaddons.crossplaneCompositions" -}}
  {{- printf `
crossplaneCompositions:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplaneCompositions
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  values:
    xclusterComponents:
      client:
        enabled: {{ $xAddonSetClientEnabled }}

---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: {{ $clusterName }}-crossplanecompositions
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonCrossplaneCompositions
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  chart: ""
  path: "helm-chart-sources/crossplane-compositions"
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "feat/newaddons"
  targetCluster: {{ $clusterName }}
  targetNamespace: "beget-crossplane"
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
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: crossplane-compositions
status: {}

---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonValue
metadata:
  name: crossplane-compositions-default
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonValueCrossplaneCompositions
    gotemplating.fn.crossplane.io/ready: "True"
  labels:
    addons.in-cloud.io/values: default
    addons.in-cloud.io/addon: crossplane-compositions
spec:
  values:
    xclusterComponents:
      client:
        enabled: {{ $xAddonSetClientEnabled }}
  ` }}
{{- end -}}
