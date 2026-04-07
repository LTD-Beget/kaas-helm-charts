{{- define "in-cloud-capi-template.files.helm.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "helm"
              "bin"         $components.helm.bin
              "versionExpr" $components.helm.bin.version
              "body"        "in-cloud-capi-template.files.helm.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
{{- end -}}
