{{- define "signalilo.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: signalilo
spec:
  chart: "signalilo"
  pluginName: helm-with-values
  repoURL: "{{ .Values.companyExternalChartRegistry }}"
  version: "0.12.1-1"
  targetCluster: in-cluster
  targetNamespace: "{{ .Values.companyPrefix }}-signalilo"
  variables:
    cluster_name: in-cluster
    dependency: "True"
  valuesSources: 
    - name: parameters
      sourceRef:
        apiVersion: v1
        kind: ConfigMap
        name: parameters-infra
        namespace: {{ .Values.companyPrefix }}-system
      extract:
        - as: companyPrefix
          jsonPath: .data.companyPrefix
        - as: signaliloUuid
          jsonPath: .data.signaliloUuid
        - as: icingaHostname
          jsonPath: .data.icingaHostname
        - as: icingaUrl
          jsonPath: .data.icingaUrl
        - as: icingaUsername
          jsonPath: .data.icingaUsername
        - as: icingaPassword
          jsonPath: .data.icingaPassword
        - as: alertmanagerSignaliloPort
          jsonPath: .data.alertmanagerSignaliloPort
        - as: alertmanagerSignaliloToken
          jsonPath: .data.alertmanagerSignaliloToken
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
          in-cloud.io/clusterName: system
      syncOptions:
        - ApplyOutOfSyncOnly=true
        - CreateNamespace=true
  valuesSelectors:
    - name: default
      priority: 0
      matchLabels:
        addons.in-cloud.io/values: default
        addons.in-cloud.io/addon: signalilo
    - name: custom
      priority: 90
      matchLabels:
        addons.in-cloud.io/values: custom
        addons.in-cloud.io/addon: signalilo
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: signalilo
{{- end }}
