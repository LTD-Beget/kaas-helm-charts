{{- define "in-cloud-capi-template.files.rbacProxy.aggregate.controlPlane" -}}
    {{- if $.Values.capi.externalSecrets.rbacProxy.enabled }}
        {{ include "in-cloud-capi-template.files.common.tlsCrt" (dict "name" "rbac-proxy") | nindent 0 }}
        {{ include "in-cloud-capi-template.files.common.tlsKey" (dict "name" "rbac-proxy") | nindent 0 }}
    {{- else }}
        # Предпочтительнее использовать этот подход тк всегда можем быть уверены что ttl сертификата начнет тикать сразу после создания ноды
        {{ include "in-cloud-capi-template.files.rbacProxy.rbacProxyServer.cnf" $ | nindent 0 }}
    {{- end }}
{{- end -}}
