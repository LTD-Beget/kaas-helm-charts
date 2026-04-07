{{- define "in-cloud-capi-template.files.cni.99-loopback.conf" -}}
- path: /etc/cni/net.d/99-loopback.conf
  owner: root:root
  permissions: '0644'
  content: |
    {
        "cniVersion": "0.4.0",
        "name": "lo",
        "type": "loopback"
    }
{{- end }}
