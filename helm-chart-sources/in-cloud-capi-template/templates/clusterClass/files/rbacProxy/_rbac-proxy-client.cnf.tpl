{{- define "in-cloud-capi-template.files.rbacProxy.rbacProxyClient.cnf" -}}
{{ include "in-cloud-capi-template.files.common.clientTlsCnf"
    (dict "name" "rbac-proxy"
          "cn"   "system:kube-rbac-proxy") }}
{{- end }}
