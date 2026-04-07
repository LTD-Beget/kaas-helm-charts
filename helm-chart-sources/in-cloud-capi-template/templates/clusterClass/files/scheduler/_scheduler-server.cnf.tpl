{{- define "in-cloud-capi-template.files.scheduler.schedulerServer.cnf" -}}
{{ include "in-cloud-capi-template.files.common.tlsCnf"
    (dict "name"     "scheduler"
          "cn"       "system:kube-scheduler-server"
          "withFQDN" true) }}
{{- end }}
