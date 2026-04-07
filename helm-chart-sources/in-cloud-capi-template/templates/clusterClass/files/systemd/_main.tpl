{{- define "in-cloud-capi-template.files.systemd.aggregate" -}}
    {{ (include "in-cloud-capi-template.files.systemd.containerd-limits.conf"   $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.systemd.limits.conf"              $ | nindent 0  ) }}
{{- end -}}
