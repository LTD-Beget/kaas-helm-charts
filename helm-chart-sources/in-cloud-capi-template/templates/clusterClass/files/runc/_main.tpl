{{- define "in-cloud-capi-template.files.runc.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "runc"
              "bin"         $components.runc.bin
              "versionExpr" "{{ .runcVersion }}"
              "body"        "in-cloud-capi-template.files.runc.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
{{- end -}}
