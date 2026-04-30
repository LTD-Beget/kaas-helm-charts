{{- define "certificate-set.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: certificate-set
spec:
  chart: "certificate-set"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.1.0"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-certificate-set"
  variables:
    cluster_name: in-cluster
    dependency: "True"
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
        addons.in-cloud.io/addon: certificate-set
{{- end }}
