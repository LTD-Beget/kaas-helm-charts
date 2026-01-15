{{- define "xclusterComponents.addonsetIii.cilium" -}}
  {{- printf `
cilium:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCilium
  finalizerDisabled: false
  namespace: beget-cilium
  version: v1alpha1
  dependsOn:
    - istioGW
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
      {{ if $certManagerReady }}
        enabled: true
      {{ end }}
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
