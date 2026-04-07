{{- define "in-cloud-capi-template.files.security.aggregate" -}}
    {{ (include "in-cloud-capi-template.files.security.90-high-load.conf"      $ | nindent 0  ) }}
{{- end -}}
