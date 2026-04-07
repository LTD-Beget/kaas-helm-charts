{{- define "in-cloud-capi-template.files.postKubeadmCommands.aggregate.controlPlane" -}}
    {{ (include "in-cloud-capi-template.files.postKubeadmCommands.commands.sh"          $ | nindent 0  ) }}
{{- end -}}

{{- define "in-cloud-capi-template.files.postKubeadmCommands.aggregate.dataPlane" -}}
{{- end -}}
