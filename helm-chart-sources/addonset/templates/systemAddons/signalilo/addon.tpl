{{- define "signalilo.addon" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: Addon
metadata:
  name: signalilo
spec:
  chart: "signalilo"
  pluginName: helm-with-values
  repoURL: "https://blog.beget.com/kaas-helm-charts"
  version: "0.12.1-1"
  targetCluster: in-cluster
  targetNamespace: "beget-signalilo"
  variables:
    uuid: "da4c0b1d-da4c-4f3b-9e5d-c23f5fcd751a"
    icingaUrl: "https://1.2.3.4:25665"
    icingaHostname: "signalilo"
    icingaUsername: "signalilo"
    icingaPassword: "signalilo"
    alertmanagerSignaliloPort: 8888
    alertmanagerSignaliloToken: HrVSzDOrZthErVJwxddMJHefHYkvr/XWVc1XGcazh1I=
  valuesSources: []
  initDependencies: []
  backend: 
    type: "argocd"
    namespace: "beget-argocd"
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
    - name: immutable
      priority: 99
      matchLabels:
        addons.in-cloud.io/values: immutable
        addons.in-cloud.io/addon: signalilo
{{- end }}
