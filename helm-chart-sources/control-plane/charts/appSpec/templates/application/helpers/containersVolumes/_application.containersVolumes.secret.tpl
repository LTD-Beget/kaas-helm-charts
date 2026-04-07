{{- define "appSpec.application.containersVolumes.secret" -}}

  {{- $volumeName   := index $ 0 -}}
  {{- $volumeValue  := index $ 1 -}}
  {{- $releaseName  := index $ 2 -}}

  {{- if and (hasKey $volumeValue.volume "mode") (eq $volumeValue.volume.mode "secret") -}}
- name: {{ $volumeName | lower }}
  secret:
    {{- if hasKey $volumeValue.volume "items"}}
    items:
    {{- toYaml $volumeValue.volume.items | nindent 4 }}
    {{- end }}
    secretName: {{ if hasKey $volumeValue.volume "secretName" }}{{ $volumeValue.volume.secretName }}{{- else }}{{ $releaseName }}-{{ $volumeValue.volume.name }}{{- end }}
  {{- end -}}

{{- end -}}
