{{- define "in-cloud-capi-template.files.controllerManager.aggregate.controlPlane" -}}
    {{- if $.Values.capi.externalSecrets.controllerManager.enabled }}
        {{ include "in-cloud-capi-template.files.common.tlsCrt" (dict "name" "controller-manager") | nindent 0 }}
        {{ include "in-cloud-capi-template.files.common.tlsKey" (dict "name" "controller-manager") | nindent 0 }}
    {{- else }}
        # Предпочтительнее использовать этот подход тк всегда можем быть уверены что ttl сертификата начнет тикать сразу после создания ноды
        {{ include "in-cloud-capi-template.files.controllerManager.controllerManagerServer.cnf" $ | nindent 0 }}
    {{- end }}
{{- end -}}
