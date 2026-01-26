{{- define "newaddons.incloudWebResources" -}}
  {{- printf `
incloudWebResources:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIncloudWebResources
  namespace: beget-incloud-ui
  version: v1alpha1
  dependsOn:
    - incloudUi
  values:
    incloud-web-resources:
      enabled: true
      addons:
        argocd:
          enabled: true
        trivy:
          enabled: {{ $infraTrivyOperatorReady }}
  ` }}
{{- end -}}
