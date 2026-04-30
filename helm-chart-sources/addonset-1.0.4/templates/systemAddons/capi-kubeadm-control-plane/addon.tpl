{{- define "capi-kubeadm-control-plane.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: capi-kubeadm-control-plane
spec:
  chart: "capi-kubeadm-control-plane"
  pluginName: helm-with-values
  repoURL: {{ .Values.companyExternalChartRegistry }}
  version: "1.2.0"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-capi"
  variables:
    cluster_name: in-cluster
  initDependencies: 
    - name: cert-manager
      criteria:
        - jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
        - ServerSideApply=true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: capi-kubeadm-control-plane
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: capi-kubeadm-control-plane
{{- end }}
