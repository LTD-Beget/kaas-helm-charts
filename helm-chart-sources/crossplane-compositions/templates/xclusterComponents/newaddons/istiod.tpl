{{- define "newaddons.istiod" -}}
  {{- printf `
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: {{ $clusterName }}-istiod
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonIstiod
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  chart: ""
  path: "helm-chart-sources/istiod" ## path вместо chart
  repoURL: "https://github.com/LTD-Beget/kaas-helm-charts"
  version: "HEAD"
  targetCluster: "{{ $clusterName }}" # targetCluster по имени 
  targetNamespace: "beget-istio"
  variables:
    cluster_name: {{ $clusterName }}
  valuesSources: []
  initDependencies:
    - name: {{ $clusterName }}-istio-base
      criteria:
        - jsonPath: /status/phase
          operator: Equal
          value: Ready
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
        addons.in-cloud.io/addon: istiod
status: {}

---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonValue
metadata:
  name: istiod-default
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonValueIstiod
    gotemplating.fn.crossplane.io/ready: "True"
  labels:
    addons.in-cloud.io/values: default
    addons.in-cloud.io/addon: istiod
spec:
  values:
    istiod:
      base:
        validationCABundle: ""
      pilot:
        autoscaleMin: 2
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
      global:
        priorityClassName: system-cluster-critical
        istioNamespace: beget-istio-test
        proxy:
          tracer: zipkin

  ` }}
{{- end -}}
