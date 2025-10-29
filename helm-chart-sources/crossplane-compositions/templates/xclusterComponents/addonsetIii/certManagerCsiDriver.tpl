{{- define "xclusterComponents.addonsetIii.certManagerCsiDriver" -}}
  {{- printf `
certManagerCsiDriver:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManagerCsiDriver
  namespace: beget-certmanager-csi-driver
  version: v1alpha1
  pluginName: kustomize-helm-with-values
  dependsOn:
    - certManager
  values:
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