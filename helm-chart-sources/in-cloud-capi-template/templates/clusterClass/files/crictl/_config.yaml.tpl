{{- define "in-cloud-capi-template.files.crictl.crictl.yaml" -}}
- path: /etc/crictl.yaml
  owner: root:root
  permissions: '0644'
  content: |
    runtime-endpoint: {{ .Values.capi.k8s.containerRuntime.socket }}
{{- end }}
