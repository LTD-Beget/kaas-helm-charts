{{- define "in-cloud-capi-template.files.kubeadm.aggregate" -}}
{{- $components := (index .root.Values.capi.k8s .plane).components -}}
    {{ include "in-cloud-capi-template.files.common.downloadBundle"
        (dict "name"        "kubeadm"
              "bin"         $components.kubeadm.bin
              "versionExpr" "{{ .builtin.cluster.topology.version }}"
              "body"        "in-cloud-capi-template.files.kubeadm.downloadScript.sh"
              "root"        .root)                                                 | nindent 0 }}
{{- end -}}
