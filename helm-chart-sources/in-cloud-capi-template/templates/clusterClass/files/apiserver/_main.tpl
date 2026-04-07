{{- define "in-cloud-capi-template.files.apiserver.aggregate.controlPlane" -}}
    {{ (include "in-cloud-capi-template.files.apiserver.caOidc.crt"  $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.apiserver.kubeApiserver0Strategic.yaml"  $ | nindent 0  ) }}
{{- end -}}