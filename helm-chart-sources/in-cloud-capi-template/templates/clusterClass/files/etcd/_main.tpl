{{- define "in-cloud-capi-template.files.etcd.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "etcd"
              "bin"         $components.etcd.bin
              "versionExpr" "{{ .etcdVersion }}"
              "body"        "in-cloud-capi-template.files.etcd.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
{{- end -}}
