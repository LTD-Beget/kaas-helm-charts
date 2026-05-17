{{- define "in-cloud-capi-template.files.controllerManager.controllerManagerServer.cnf" -}}
{{ include "in-cloud-capi-template.files.common.serverTlsCnf"
    (dict "name" "controller-manager"
          "cn"   "system:kube-controller-manager-server") }}
{{- end }}
