{{- define "xclusterComponents.addonsetIii.capiClusterClass" -}}
  {{- printf `
capiClusterClass:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiClusterClass
  namespace: bcloud-capi
  version: v1alpha1
  dependsOn:
  - capi
  values:
    inCloud:
      serviceAccount:
        name: capi
  ` }}
{{- end -}}
