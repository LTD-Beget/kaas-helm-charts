{{- define "kubeadm-resources.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: kubeadm-resources
spec:
  chart: "kubeadm-resources-client-cp"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.1.1"
  releaseName: kubeadm-resources
  targetCluster: {{ .Values.clientName }}
  targetNamespace: "{{ .Values.companyPrefix }}-kubeadm-resources"
  variables:
    cluster_name: {{ .Values.clientName }}
  valuesSources:
    - name: parameters-client
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-client
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: clientServiceCidr
          jsonPath: .data.clientServiceCidr
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.port
          jsonPath: .data.clusterPort
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.domain
          jsonPath: .data.clientClusterDomain
        - as: cluster.version
          jsonPath: .data.clientVersion
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: companyDomain
          jsonPath: .data.companyDomain
    - name: clientca
      sourceRef:
        apiVersion: v1
        kind: Secret
        name: {{ .Values.clientName }}-ca
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: cluster.kubeCaCrtBase64
          jsonPath: .data["tls.crt"]
{{- if .Values.clientClusterEnabled }}
  initDependencies:
    - name: client-cp-control-plane
      criteria:
        - jsonPath: $.status.deployed
          operator: Equal
          value: true
{{- end }}
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
          in-cloud.io/clusterName: client
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: client
      priority: 10
      matchLabels:
        addons.in-cloud.io/values: client
        addons.in-cloud.io/addon: kubeadm-resources
{{- end }}
