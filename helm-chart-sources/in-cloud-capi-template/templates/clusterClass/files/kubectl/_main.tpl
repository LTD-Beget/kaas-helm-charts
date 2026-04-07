{{- define "in-cloud-capi-template.files.kubectl.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "kubectl"
              "bin"         $components.kubectl.bin
              "versionExpr" "{{ .builtin.cluster.topology.version }}"
              "body"        "in-cloud-capi-template.files.kubectl.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
{{- end -}}
