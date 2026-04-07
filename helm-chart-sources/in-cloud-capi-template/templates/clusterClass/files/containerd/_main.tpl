{{- define "in-cloud-capi-template.files.containerd.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.containerd.configCustom.toml"  .root | nindent 0 }}
    {{ include "in-cloud-capi-template.files.containerd.configMirrors.toml" .root | nindent 0 }}
    {{ include "in-cloud-capi-template.files.containerd.configDefault.toml" .root | nindent 0 }}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "containerd"
              "bin"         $components.containerd.bin
              "versionExpr" "{{ .containerdVersion }}"
              "body"        "in-cloud-capi-template.files.containerd.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
    {{ include "in-cloud-capi-template.files.containerd.service"             .root | nindent 0 }}
{{- end -}}
