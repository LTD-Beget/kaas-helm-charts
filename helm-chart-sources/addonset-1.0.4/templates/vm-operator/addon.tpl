{{- define "vm-operator.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: vm-operator
spec:
  chart: "victoria-metrics-operator"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.52.0-2"
  pluginName: helm-with-values
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-vm-operator"
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
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
  initDependencies:
{{- if eq (lower (toString .Values.clientClusterEnabled)) "true" }}
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
    - name: cert-manager-csi-driver
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
        addons.in-cloud.io/addon: vm-operator
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: vm-operator
{{- end }}
