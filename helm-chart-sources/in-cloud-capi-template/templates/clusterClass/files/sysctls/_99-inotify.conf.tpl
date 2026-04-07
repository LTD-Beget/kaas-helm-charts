{{- define "in-cloud-capi-template.files.sysctls.99-inotify.conf" -}}
- path: /etc/sysctl.d/99-inotify.conf
  owner: root:root
  permissions: '0644'
  content: |
    fs.inotify.max_user_instances = 1024
    fs.inotify.max_user_watches = 524288
{{- end }}
