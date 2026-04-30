{{- define "cert-manager-csi-driver.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: cert-manager-csi-driver
spec:
  chart: "cert-manager-csi-driver"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.10.4-1"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-cert-manager-csi-driver"
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
        addons.in-cloud.io/addon: cert-manager-csi-driver
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: cert-manager-csi-driver
{{- end }}
