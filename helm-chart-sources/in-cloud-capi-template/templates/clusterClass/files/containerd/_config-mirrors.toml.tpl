{{- define "in-cloud-capi-template.files.containerd.configMirrors.toml" -}}
{{- $mirrors      := $.Values.capi.k8s.containerRuntime.mirrors }}
{{- $defaultArgs  := $mirrors.default.args }}
{{- if $mirrors.enabled }}
{{- range $mirrorName, $mirrorValue := $mirrors.repos }}
- path: /etc/containerd/certs.d/{{ $mirrorName }}/hosts.toml
  owner: root:root
  permissions: "0644"
  content: |
    server = {{ $mirrorValue.server | quote }}
    {{- range $mirror := $mirrorValue.mirrors }}
    [host.{{ $mirror.mirror | quote }}]
      {{ toToml (mergeOverwrite (deepCopy $defaultArgs) $mirror.args) | nindent 6 }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
