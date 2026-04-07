{{- define "in-cloud-capi-template.files.sysctls.99-br-netfilter.conf" -}}
- path: /etc/sysctl.d/99-br-netfilter.conf
  owner: root:root
  permissions: '0644'
  content: |
    net.bridge.bridge-nf-call-iptables=1
    net.bridge.bridge-nf-call-ip6tables=1
{{- end }}
