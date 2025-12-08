{{- define "xclusterComponents.addonsetIii.grafanaDashboards" -}}
  {{- printf `
grafanaDashboards:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsGrafanaDashboards
  namespace: beget-grafana
  version: v1alpha1
  dependsOn: 
  - grafanaOperator
  values:
    grafanaDashboards:
      argocd:
        enabled: true
      ciliumAgent:
        enabled: true
      cpu:
        enabled: true
      crossplaneCustom:
        enabled: true
      processLA:
        enabled: true
      processExporter:
        enabled: true
      metallb:
        enabled: true
      vector:
        enabled: true
      vmagent:
        enabled: true
      k8s:
        coredns:
          enabled: true
        etcd:
          enabled: true
        timex:
          enabled: true
        viewsGlobal:
          enabled: true
        viewsNamespaces:
          enabled: true
        viewsNodes:
          enabled: true
        viewsPods:
          enabled: true
  ` }}
{{- end -}}