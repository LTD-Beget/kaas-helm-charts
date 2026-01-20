{{- define "xclusterComponents.addonsetIii.certManager" -}}
  {{- printf `
certManager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCertManager
  namespace: beget-certmanager
  version: v1alpha1
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    cert-manager:
  {{ if $systemEnabled }}
      cainjector:
        resources:
          limits:
            cpu: 1
      resources:
        limits:
          cpu: 1
      webhook:
        resources:
          limits:
            cpu: 1
  {{ end }}
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

      {{- if $systemEnabled }}
      selfsignedClusterIssuer:
        kind: ClusterIssuer
        name: selfsigned-cluster-issuer
        spec:
          ca:
            secretName: {{ $clusterName }}-ca-oidc
      {{- else }}
      selfsignedClusterIssuer:
        kind: ClusterIssuer
        name: selfsigned-cluster-issuer
        spec:
          ca:
            secretName: selfsigned-infra-cluster-ca

    certificates:
      mainCA:
        name: selfsigned-infra-cluster-ca
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
          secretName: selfsigned-infra-cluster-ca
      {{- end }}
  ` }}
{{- end -}}
 