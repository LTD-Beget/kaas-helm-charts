{{- define "in-cloud-capi-template.files.bashrc.aggregate" -}}
    {{ (include "in-cloud-capi-template.files.bashrc.custom"          $ | nindent 0  ) }}
{{- end -}}
