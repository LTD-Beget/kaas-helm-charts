{{- define "in-cloud-capi-template.files.rbacProxy.rbacProxy.conf" -}}
- path: /etc/kubernetes/rbac-proxy.conf
  owner: root:root
  permissions: '0644'
  content: |
    apiVersion: v1
    kind: Config
    preferences: {}
    clusters:
    - name: my-cluster
      cluster:
        server: https://127.0.0.1:443
        certificate-authority: /etc/kubernetes/pki/ca.crt
    users:
    - name: my-user
      user:
        client-certificate: /etc/kubernetes/pki/rbac-proxy-client.crt
        client-key: /etc/kubernetes/pki/rbac-proxy-client.key
    contexts:
    - name: my-context
      context:
        cluster: my-cluster
        user: my-user
    current-context: my-context
{{- end }}
