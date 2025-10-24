{{- define "xclusterComponents.addonsetIii.certManager" -}}
  {{- printf `
certManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManager
  namespace: beget-certmanager
  version: v1alpha1
  {{ if $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    cert-manager:
      clusterResourceNamespace: beget-system
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    issuers:
      selfsignedIssuer:
        kind: Issuer
        name: selfsigned-issuer
        namespace: beget-system
        spec:
          selfSigned: {}

      selfsignedClusterIssuer:
        kind: ClusterIssuer
        name: selfsigned-cluster-issuer
        spec:
          ca:
            secretName: selfsigned-cluster-ca

    certificates:
      mainCA:
        name: selfsigned-cluster-ca
        namespace: beget-system
        spec:
          issuerRef:
            group: cert-manager.io
            kind: Issuer
            name: selfsigned-issuer
          privateKey:
            algorithm: RSA
            encoding: PKCS1
            size: 4096
          duration: 175200h
          renewBefore: 720h
          isCA: true
          commonName: root-ca
          secretName: selfsigned-cluster-ca
  ` }}
{{- end -}}
