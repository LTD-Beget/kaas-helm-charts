{{- define "validating-admission-policies.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: validating-admission-policies{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  repoURL: https://github.com/LTD-Beget/kaas-helm-charts.git
  path: helm-chart-sources/validating-admission-policies
  version: feature/add-pdb-limits

  # chart: "validating-admission-policies"
  # repoURL: "{{ .Values.companyExternalChartRegistry }}"
  # version: "0.1.0"
  pluginName: helm-with-values
  {{- if eq .Values.environment "client" }}
  targetCluster: {{ .Values.clientName }}
  {{- else }}
  targetCluster: in-cluster
  {{- end }}
  targetNamespace: "{{ .Values.companyPrefix }}-system"
  variables:
    cluster_name: in-cluster
  valuesSources: []
  initDependencies: []
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
        addons.in-cloud.io/addon: validating-admission-policies
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: validating-admission-policies
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: validating-admission-policies
{{- end }}
