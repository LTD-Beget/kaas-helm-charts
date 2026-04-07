{{- define "in-cloud-capi-template.files.containerd.configDefault.toml" -}}
- path: /etc/containerd/config.toml
  owner: root:root
  permissions: '0644'
  content: |
    version = 2
    imports = ["/etc/containerd/conf.d/*.toml"]
{{- end }}
