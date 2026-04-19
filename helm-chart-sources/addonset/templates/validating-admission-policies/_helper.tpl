{{- define "validating-admission-policies.addon-spec" }}
repoURL: https://github.com/LTD-Beget/kaas-helm-charts.git
path: helm-chart-sources/validating-admission-policies
version: feature/add-pdb-limits

# chart: "validating-admission-policies"
# repoURL: "{{ .Values.companyExternalChartRegistry }}"
# version: "0.1.0"
pluginName: helm-with-values
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
