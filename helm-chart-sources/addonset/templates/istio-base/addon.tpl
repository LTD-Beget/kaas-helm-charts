{{- define "istio-base.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: istio-base
spec:
  chart: "base"
  repoURL: "https://istio-release.storage.googleapis.com/charts"
  version: "1.26.0"
  targetCluster: in-cluster
  targetNamespace: "beget-istio"
  variables:
    cluster_name: in-cluster
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
        addons.in-cloud.io/addon: istio-base
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: istio-base
{{- end }}
