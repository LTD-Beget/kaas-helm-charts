{{- define "worker-group-claim-operator.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: worker-group-claim-operator
spec:
  chart: "worker-group-claim-operator"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.1.1"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-worker-group-claim-operator"
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
        addons.in-cloud.io/addon: worker-group-claim-operator
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: worker-group-claim-operator
{{- end }}
