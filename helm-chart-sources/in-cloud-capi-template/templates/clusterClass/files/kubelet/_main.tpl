{{- define "in-cloud-capi-template.files.kubelet.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "kubelet"
              "bin"         $components.kubelet.bin
              "versionExpr" "{{ .builtin.cluster.topology.version }}"
              "body"        "in-cloud-capi-template.files.kubelet.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
    {{ include "in-cloud-capi-template.files.kubelet.service.conf"           .root | nindent 0 }}
    {{ include "in-cloud-capi-template.files.kubelet.service"                .root | nindent 0 }}
    {{ include "in-cloud-capi-template.files.kubelet.configCustom.yaml"     .root | nindent 0 }}
{{- end -}}
