{{- define "in-cloud-capi-template.files.apiserver.caOidc.crt" -}}
- path: /etc/kubernetes/pki/ca-oidc.crt
  owner: root:root
  permissions: '0644'
  contentFrom:
    secret:
      name: "{{`{{ .builtin.cluster.name }}`}}-ca-oidc"
      key: ca.crt
{{- end }}


{{- define "in-cloud-capi-template.files.apiserver.caOidc.crt.dataPlane" -}}
- path: /etc/kubernetes/pki/ca-oidc.crt
  owner: root:root
  permissions: '0644'
  contentFrom:
    secret:
      name: "{{`{{ .clusterClaim }}`}}-infra-ca-oidc"
      key: ca.crt
{{- end }}