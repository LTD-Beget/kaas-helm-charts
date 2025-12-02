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
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    keepKey: ""
    monitoring:
      keepKey: ""
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
    {{ if $certManagerReady }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    {{ end }}
  ` }}
{{- end -}}
