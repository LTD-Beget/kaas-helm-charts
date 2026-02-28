{{- define "appSpec.application.containersVolumes.csi" -}}

  {{- $volumeName  := index $ 0 -}}
  {{- $volumeValue := index $ 1 -}}

  {{- if and (hasKey $volumeValue.volume "mode") (eq $volumeValue.volume.mode "csi") -}}
- name: {{ $volumeName | lower }}
  csi:
    driver: {{ $volumeValue.volume.driver | default "csi.cert-manager.io" }}
    readOnly: {{ $volumeValue.volume.readOnly | default true }}
    volumeAttributes:
      {{- range $k, $v := $volumeValue.volume.volumeAttributes }}
      {{ $k }}: {{ $v | quote }}
      {{- end }}
  {{- end -}}

{{- end -}}