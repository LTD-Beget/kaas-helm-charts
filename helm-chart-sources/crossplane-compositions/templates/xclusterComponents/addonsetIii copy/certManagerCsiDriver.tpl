{{- define "newaddons.certManagerCsiDriver" -}}
  {{- printf `
certManagerCsiDriver:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManagerCsiDriver
  namespace: beget-certmanager-csi-driver
  version: v1alpha1
  dependsOn:
    - certManager
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
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
