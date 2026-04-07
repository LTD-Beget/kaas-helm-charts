{{- define "in-cloud-capi-template.files.sysctls.99-network.conf" -}}
- path: /etc/sysctl.d/99-network.conf
  owner: root:root
  permissions: '0644'
  content: |
    net.ipv4.ip_forward=1
{{- end }}
