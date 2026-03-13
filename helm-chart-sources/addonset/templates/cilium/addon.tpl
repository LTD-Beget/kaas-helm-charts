{{- define "cilium.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: cilium
spec:
  chart: "cilium"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "1.18.5-1"
  targetCluster: in-cluster
  targetNamespace: "beget-cilium"
  valuesSources:
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters
        namespace: beget-system
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
  backend: 
    type: "argocd"
    namespace: "beget-argocd"
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
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: cilium
{{- end }}
