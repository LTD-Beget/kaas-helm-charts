{{- define "in-cloud-capi-template.files.scheduler.aggregate.controlPlane" -}}
    {{- if $.Values.capi.externalSecrets.scheduler.enabled }}
        {{ include "in-cloud-capi-template.files.common.tlsCrt" (dict "name" "scheduler") | nindent 0 }}
        {{ include "in-cloud-capi-template.files.common.tlsKey" (dict "name" "scheduler") | nindent 0 }}
    {{- else }}
        # Предпочтительнее использовать этот подход тк всегда можем быть уверены что ttl сертификата начнет тикать сразу после создания ноды
        {{ include "in-cloud-capi-template.files.scheduler.schedulerServer.cnf" $ | nindent 0 }}
    {{- end }}
{{- end -}}
