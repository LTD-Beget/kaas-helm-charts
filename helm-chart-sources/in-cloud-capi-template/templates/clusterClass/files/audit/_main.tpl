{{- define "in-cloud-capi-template.files.audit.aggregate.controlPlane" -}}
    {{ (include "in-cloud-capi-template.files.audit.auditPolicy.yaml"  $ | nindent 0  ) }}
{{- end -}}