{{- define "cilium.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: cilium
spec:
  chart: "cilium"
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "1.18.5-2"
  pluginName: helm-with-values
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-cilium"
  valuesSources:
    - name: parameters-infra
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: cluster.host
          jsonPath: .data.clusterHost
        - as: cluster.name
          jsonPath: .data.clusterName
        - as: cluster.port
          jsonPath: .data.clusterPort #tmp need change -> clusterPort for prod-ready (infra) or clusterClientPort
        - as: podCidr
          jsonPath: .data.podCidr
        - as: podCidrMaskSize
          jsonPath: .data.podCidrMaskSize
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
    ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: Service
      jqPathExpressions:
        - .spec.ports[]?.nodePort
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: cilium
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: cilium
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: cilium
{{- end }}
