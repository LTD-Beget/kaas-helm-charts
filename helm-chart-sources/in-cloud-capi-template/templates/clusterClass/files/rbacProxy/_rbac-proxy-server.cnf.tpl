{{- define "in-cloud-capi-template.files.rbacProxy.rbacProxyServer.cnf" -}}
{{ include "in-cloud-capi-template.files.common.tlsCnf"
    (dict "name" "rbac-proxy"
          "cn"   "system:kube-rbac-proxy") }}
{{- end }}
