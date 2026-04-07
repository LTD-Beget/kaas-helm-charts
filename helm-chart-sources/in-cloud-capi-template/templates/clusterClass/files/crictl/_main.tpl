{{- define "in-cloud-capi-template.files.crictl.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "crictl"
              "bin"         $components.crictl.bin
              "versionExpr" "{{ .crictlVersion }}"
              "body"        "in-cloud-capi-template.files.crictl.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
    {{ include "in-cloud-capi-template.files.crictl.crictl.yaml"             .root | nindent 0 }}
{{- end -}}
